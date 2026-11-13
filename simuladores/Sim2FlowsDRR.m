function [PL , APD , MPD , TT] = Sim2FlowsDRR(lambda,C,f,P,Q,Inv)
% INPUT PARAMETERS:
%  lambda - row vector with the packet rate of each flow (packets/sec)
%  C      - link bandwidth (Mbps)
%  f      - row vector with the size of the queue of each flow (Bytes)
%  P      - number of packets (stopping criterium)
%  Q      - row vector with the Quantum of each flow (Bytes)            % CHANGED
%  Inv    - false: each round-robin round is by the order of the flow  % CHANGED
%           ID; true: by the inverse order of the flow ID
% OUTPUT PARAMETERS:
%  PL   - row vector with the packet loss (%) of each flow
%  APD  - row vector with the average packet delay (milliseconds) of each flow
%  MPD  - maximum packet delay (milliseconds) of each flow
%  TT   - transmitted throughput (Mbps) of each flow

%Events:
ARRIVAL= 0;       % Arrival of a packet
DEPARTURE= 1;     % Departure of a packet

%State variables:
STATE = 0;              % 0 - connection is free; 1 - connection is occupied
QUEUEOCCUPATION= [0 0]; % Occupation of the queue of each flow (in Bytes)
QUEUE= cell(1,2);       % QUEUE{i}: size, arriving time instant and flowID of each
                        % packet in the queue of flow i

% CHANGED: DRR state (replaces the priority order of Sim2FlowsPrio)
if Inv
    ORDER= [2 1];       % order of the queues in each round-robin round
else
    ORDER= [1 2];
end
DC= [0 0];              % Deficit Counter of each flow (Bytes)
ptr= 1;                 % position in ORDER of the queue being visited
visiting= false;        % true if the Quantum was already added in this visit

% Initializing the required Statistical Counters:
TOTALPACKETS= zeros(1,2);     % No. of packets of each flow arrived to the system
LOSTPACKETS= zeros(1,2);      % No. of packets of each flow lost due to buffer fulness
TRANSPACKETS= zeros(1,2);     % No. of transmitted packets of each flow
TRANSBYTES= zeros(1,2);       % Sum of the Bytes of all transmitted packets of each flow
DELAYS= zeros(1,2);           % Sum of the delays of all transmitted packets of each flow
MAXDELAY= zeros(1,2);         % Maximum delay among all transmitted packets of each flow

% Initializing the Simulation Clock:
Clock= 0;

% Each row of Event List:
% Row 1: Event Type
% Row 2: Time instant of event occurrence
% Row 3: Packet size
% Row 4: Flow ID of the packet
% Row 5: Time instant of the packet arrival to the system
%
% Initializing the List of Events with the first ARRIVAL of each flow:
tmp= Clock + exprnd(1/lambda(1));
EventList = [ARRIVAL, tmp, GenerateSize1(), 1, tmp];
tmp= Clock + exprnd(1/lambda(2));
EventList = [EventList; ARRIVAL, tmp, GenerateSize2(), 2, tmp];

% Simulation loop:
while sum(TRANSPACKETS)<P       % Simulation stopping criterion
    EventList= sortrows(EventList,2); % Order EventList by 2nd column (the time instant)
    Event= EventList(1,1);            % Get event
    Clock= EventList(1,2);            % Get the time instant of the event
    PacketSize= EventList(1,3);       % Get the packet size of the event
    Flow= EventList(1,4);             % Get the flow ID of the packet
    ArrInstant= EventList(1,5);       % Get the arriving instant of the packet
    EventList(1,:)= [];               % Eliminate first event from the EventList
    switch Event
        case ARRIVAL         % If event is an ARRIVAL
            TOTALPACKETS(Flow)= TOTALPACKETS(Flow)+1;
            tmp= Clock + exprnd(1/lambda(Flow));
            if Flow==1
                nextPacketSize= GenerateSize1();
            else
                nextPacketSize= GenerateSize2();
            end
            EventList = [EventList; ARRIVAL, tmp, nextPacketSize, Flow, tmp];
            % the packet goes to the queue of its own flow and is lost only
            % if that queue has no space for it
            if QUEUEOCCUPATION(Flow) + PacketSize <= f(Flow)
                QUEUE{Flow}= [QUEUE{Flow}; PacketSize , Clock, Flow];
                QUEUEOCCUPATION(Flow)= QUEUEOCCUPATION(Flow) + PacketSize;
            else
                LOSTPACKETS(Flow)= LOSTPACKETS(Flow) + 1;
            end
            % CHANGED: if the link is free, the packet just queued is chosen
            % by the DRR scheduler (so that its Deficit Counter is updated)
            if STATE==0
                [pkt,QUEUE,QUEUEOCCUPATION,DC,ptr,visiting]= NextPacketDRR(QUEUE,QUEUEOCCUPATION,Q,DC,ptr,visiting,ORDER);
                STATE= 1;
                EventList = [EventList; DEPARTURE, Clock + 8*pkt(1)/(C*1e6), pkt(1), pkt(3), pkt(2)];
            end
        case DEPARTURE          % If event is a DEPARTURE
            TRANSBYTES(Flow)= TRANSBYTES(Flow) + PacketSize;
            TRANSPACKETS(Flow)= TRANSPACKETS(Flow) + 1;
            DELAYS(Flow)= DELAYS(Flow) + (Clock - ArrInstant);
            if Clock - ArrInstant > MAXDELAY(Flow)
                MAXDELAY(Flow)= Clock - ArrInstant;
            end
            % CHANGED: the next packet is chosen by the DRR scheduler
            [pkt,QUEUE,QUEUEOCCUPATION,DC,ptr,visiting]= NextPacketDRR(QUEUE,QUEUEOCCUPATION,Q,DC,ptr,visiting,ORDER);
            if ~isempty(pkt)
                EventList = [EventList; DEPARTURE, Clock + 8*pkt(1)/(C*1e6), pkt(1), pkt(3), pkt(2)];
            else
                STATE= 0;
            end
    end
end

% Performance parameters determination:
PL= 100*LOSTPACKETS./TOTALPACKETS;  % in percentage
APD= 1000*DELAYS./TRANSPACKETS;     % in milliseconds
MPD= 1000*MAXDELAY;                % in milliseconds
TT= 1e-6*TRANSBYTES*8/Clock;       % in Mbps

end

% CHANGED: Deficit Round Robin scheduler.
% Visits the queues by the order in ORDER. At the start of each visit to a
% non-empty queue, its Quantum is added to its Deficit Counter (DC); the
% head packet is transmitted if its size is not larger than DC (and DC is
% decreased by that size); otherwise the visit ends and the next queue is
% visited. When a queue becomes empty, its DC is reset to 0 and the visit
% ends. Returns pkt = [size, arriving instant, flowID] of the packet to
% transmit, or [] if all queues are empty.
function [pkt,QUEUE,QUEUEOCCUPATION,DC,ptr,visiting]= NextPacketDRR(QUEUE,QUEUEOCCUPATION,Q,DC,ptr,visiting,ORDER)
    pkt= [];
    if all(QUEUEOCCUPATION == 0)
        return;
    end
    nQ= length(ORDER);
    while true
        i= ORDER(ptr);
        if QUEUEOCCUPATION(i) == 0              % empty queue: skip it
            DC(i)= 0;
            visiting= false;
            ptr= mod(ptr,nQ) + 1;
            continue;
        end
        if ~visiting                            % start of the visit
            DC(i)= DC(i) + Q(i);
            visiting= true;
        end
        if QUEUE{i}(1,1) <= DC(i)               % head packet can be sent
            pkt= QUEUE{i}(1,:);
            DC(i)= DC(i) - pkt(1);
            QUEUE{i}(1,:)= [];
            QUEUEOCCUPATION(i)= QUEUEOCCUPATION(i) - pkt(1);
            if QUEUEOCCUPATION(i) == 0          % queue became empty
                DC(i)= 0;
                visiting= false;
                ptr= mod(ptr,nQ) + 1;
            end
            return;
        end
        visiting= false;                        % not enough deficit:
        ptr= mod(ptr,nQ) + 1;                   % go to the next queue
    end
end

function out= GenerateSize1()
    aux= rand();
    aux2= [65:109 111:1517];
    if aux <= 0.19
        out= 64;
    elseif aux <= 0.19 + 0.23
        out= 110;
    elseif aux <= 0.19 + 0.23 + 0.17
        out= 1518;
    else
        out = aux2(randi(length(aux2)));
    end
end

function out= GenerateSize2()
    out= randi([110 130]);
end
