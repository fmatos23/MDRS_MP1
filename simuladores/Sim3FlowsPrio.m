function [PL , APD , MPD , TT] = Sim3FlowsPrio(lambda,C,f,P,prio)
% INPUT PARAMETERS:
%  lambda - row vector with the packet rate of each flow (packets/sec)
%  C      - link bandwidth (Mbps)
%  f      - row vector with the size of the queue of each priority level   % CHANGED
%           (Bytes): f(1) for priority 1 (highest), f(2) for priority 2, ...
%  P      - number of packets (stopping criterium)
%  prio   - row vector with the priority level of each flow                % CHANGED
%           (1 = highest priority, 2 = second highest, ...)
%           Mini-project: prio = [2 2 1] -> Flow 3 has the highest priority
%           and Flows 1 and 2 have the second highest priority
% OUTPUT PARAMETERS:
%  PL   - row vector with the packet loss (%) of each flow
%  APD  - row vector with the average packet delay (milliseconds) of each flow
%  MPD  - maximum packet delay (milliseconds) of each flow
%  TT   - transmitted throughput (Mbps) of each flow

%Events:
ARRIVAL= 0;       % Arrival of a packet
DEPARTURE= 1;     % Departure of a packet

nFlows= 3;              % CHANGED: number of flows (was 2)
nQueues= max(prio);     % CHANGED: number of priority levels (one queue per level)

%State variables:
STATE = 0;                         % 0 - connection is free; 1 - connection is occupied
% CHANGED: one queue per priority level (in Sim2FlowsPrio it was one queue
% per flow); Flows 1 and 2 share the queue of priority 2
QUEUEOCCUPATION= zeros(1,nQueues); % Occupation of the queue of each priority level (in Bytes)
QUEUE= cell(1,nQueues);            % QUEUE{q}: size, arriving time instant and flowID of each
                                   % packet in the queue of priority q

% CHANGED: order in which the queues are served (priority 1 first, then 2, ...)
ORDER= 1:nQueues;

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
% CHANGED: one initial ARRIVAL per flow, generated in a loop
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
            nextPacketSize= GenerateSize(Flow);   % CHANGED: size depends on the flow
            EventList = [EventList; ARRIVAL, tmp, nextPacketSize, Flow, tmp];
            if STATE==0
                STATE= 1;
                EventList = [EventList; DEPARTURE, Clock + 8*PacketSize/(C*1e6), PacketSize, Flow, Clock];
            else
                % CHANGED: the packet goes to the queue of its priority level
                % (and not to the queue of its flow), and is lost only if that
                % queue has no space for it
                q= prio(Flow);
                if QUEUEOCCUPATION(q) + PacketSize <= f(q)
                    QUEUE{q}= [QUEUE{q}; PacketSize , Clock, Flow];
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
            % The next packet is the first packet of the highest priority queue
            % that is not empty (non-preemptive priority: the packet in
            % transmission is never interrupted); within each queue the order
            % is FIFO, so Flows 1 and 2 are served by order of arrival
            q= ORDER(find(QUEUEOCCUPATION(ORDER) > 0, 1));
            if ~isempty(q)
                QSize= QUEUE{q}(1,1);
                QInstant= QUEUE{q}(1,2);
                QFlow= QUEUE{q}(1,3);
                EventList = [EventList; DEPARTURE, Clock + 8*QSize/(C*1e6), QSize, QFlow, QInstant];
                QUEUEOCCUPATION(q)= QUEUEOCCUPATION(q) - QSize;
                QUEUE{q}(1,:)= [];
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

% CHANGED: GenerateSize1/GenerateSize2 replaced by a single function.
% Each flow has a packet size uniformly distributed (all integer values
% with equal probability) between minSize(Flow) and maxSize(Flow) Bytes.
function out= GenerateSize(Flow)
    minSize= [100  100  500];
    maxSize= [1500 150 1000];
    out= randi([minSize(Flow) maxSize(Flow)]);
end
