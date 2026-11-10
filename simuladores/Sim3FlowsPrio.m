function [PL , APD , MPD , TT] = Sim3FlowsPrio(lambda,C,f1,f2,P)
% INPUT PARAMETERS:
%  lambda - row vector with the packet rate of each flow (packets/sec)
%  C      - link bandwidth (Mbps)
%  f1     - size of the queue of priority 1, highest priority (Bytes)
%  f2     - size of the queue of priority 2, lowest priority (Bytes)
%  P      - number of packets (stopping criterium)
% OUTPUT PARAMETERS:
%  PL   - row vector with the packet loss (%) of each flow
%  APD  - row vector with the average packet delay (milliseconds) of each flow
%  MPD  - maximum packet delay (milliseconds) of each flow
%  TT   - transmitted throughput (Mbps) of each flow

%Events:
ARRIVAL= 0;       % Arrival of a packet
DEPARTURE= 1;     % Departure of a packet

% CHANGED: priority of each flow (1 = highest priority, 2 = second highest).
% Flow 3 has the highest priority; Flows 1 and 2 have the second highest.
nFlows= 3;
PRIO= [2 2 1];

%State variables:
STATE = 0;            % 0 - connection is free; 1 - connection is occupied
% CHANGED: one queue per priority level instead of a single queue
QUEUEOCCUPATION= [0 0];  % Occupation of each queue (in Bytes): [priority 1, priority 2]
QUEUE1= [];           % Priority 1 queue: size, arriving time instant and flowID of each packet
QUEUE2= [];           % Priority 2 queue: size, arriving time instant and flowID of each packet
QSIZE= [f1 f2];       % CHANGED: maximum size of each queue (Bytes)

% Initializing the required Statistical Counters:
TOTALPACKETS= zeros(1,nFlows);     % No. of packets of each flow arrived to the system
LOSTPACKETS= zeros(1,nFlows);      % No. of packets of each flow lost due to buffer fulness
TRANSPACKETS= zeros(1,nFlows);     % No. of transmitted packets of each flow
TRANSBYTES= zeros(1,nFlows);       % Sum of the Bytes of all transmitted packets of each flow
DELAYS= zeros(1,nFlows);           % Sum of the delays of all transmitted packets of each flow
MAXDELAY= zeros(1,nFlows);         % Maximum delay among all transmitted packets of each flow

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
EventList= [];
for i= 1:nFlows
    tmp= Clock + exprnd(1/lambda(i));
    EventList = [EventList; ARRIVAL, tmp, GenerateSize(i), i, tmp];
end

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
            nextPacketSize= GenerateSize(Flow);
            EventList = [EventList; ARRIVAL, tmp, nextPacketSize, Flow, tmp];
            if STATE==0
                STATE= 1;
                EventList = [EventList; DEPARTURE, Clock + 8*PacketSize/(C*1e6), PacketSize, Flow, Clock];
            else
                % CHANGED: the packet goes to the queue of its priority level
                q= PRIO(Flow);
                if QUEUEOCCUPATION(q) + PacketSize <= QSIZE(q)
                    if q==1
                        QUEUE1= [QUEUE1; PacketSize , Clock, Flow];
                    else
                        QUEUE2= [QUEUE2; PacketSize , Clock, Flow];
                    end
                    QUEUEOCCUPATION(q)= QUEUEOCCUPATION(q) + PacketSize;
                else
                    LOSTPACKETS(Flow)= LOSTPACKETS(Flow) + 1;
                end
            end
        case DEPARTURE          % If event is a DEPARTURE
            TRANSBYTES(Flow)= TRANSBYTES(Flow) + PacketSize;
            TRANSPACKETS(Flow)= TRANSPACKETS(Flow) + 1;
            DELAYS(Flow)= DELAYS(Flow) + (Clock - ArrInstant);
            if Clock - ArrInstant > MAXDELAY(Flow)
                MAXDELAY(Flow)= Clock - ArrInstant;
            end
            % CHANGED: the next packet comes from the priority 1 queue if it
            % is not empty; only otherwise from the priority 2 queue
            if QUEUEOCCUPATION(1) > 0
                QSz= QUEUE1(1,1);
                QInstant= QUEUE1(1,2);
                QFlow= QUEUE1(1,3);
                EventList = [EventList; DEPARTURE, Clock + 8*QSz/(C*1e6), QSz, QFlow, QInstant];
                QUEUEOCCUPATION(1)= QUEUEOCCUPATION(1) - QSz;
                QUEUE1(1,:)= [];
            elseif QUEUEOCCUPATION(2) > 0
                QSz= QUEUE2(1,1);
                QInstant= QUEUE2(1,2);
                QFlow= QUEUE2(1,3);
                EventList = [EventList; DEPARTURE, Clock + 8*QSz/(C*1e6), QSz, QFlow, QInstant];
                QUEUEOCCUPATION(2)= QUEUEOCCUPATION(2) - QSz;
                QUEUE2(1,:)= [];
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

% Each flow has a packet size uniformly distributed (all integer values
% with equal probability) between minSize(Flow) and maxSize(Flow) Bytes.
function out= GenerateSize(Flow)
    minSize= [100  100  500];
    maxSize= [1500 150 1000];
    out= randi([minSize(Flow) maxSize(Flow)]);
end
