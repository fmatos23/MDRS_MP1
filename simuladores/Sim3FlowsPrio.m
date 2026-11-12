function [PL , APD , MPD , TT] = Sim3FlowsPrio(lambda,C,f,P)
% Sim3FlowsPrio - new version of Sim2FlowsPrio supporting 3 flows, where
% Flow 3 has the highest priority and Flows 1 and 2 have the second
% highest priority. Changes relative to Sim2FlowsPrio are marked with
% "CHANGED (vs Sim2FlowsPrio)".
%
% INPUT PARAMETERS:
%  lambda - row vector with the packet rate of each flow (packets/sec)
%  C      - link bandwidth (Mbps)
%  f      - row vector with the size of each queue (Bytes):
%           CHANGED (vs Sim2FlowsPrio): one queue per priority level
%           f(1) - queue of priority 1 (highest; Flow 3)
%           f(2) - queue of priority 2 (Flows 1 and 2)
%  P      - number of packets (stopping criterium)
%  CHANGED (vs Sim2FlowsPrio): input parameter prio removed, since the
%  priorities are fixed by the problem statement (see PRIO below)
% OUTPUT PARAMETERS:
%  PL   - row vector with the packet loss (%) of each flow
%  APD  - row vector with the average packet delay (milliseconds) of each flow
%  MPD  - maximum packet delay (milliseconds) of each flow
%  TT   - transmitted throughput (Mbps) of each flow

%Events:
ARRIVAL= 0;       % Arrival of a packet
DEPARTURE= 1;     % Departure of a packet

% CHANGED (vs Sim2FlowsPrio): 3 flows instead of 2
nFlows= 3;

% CHANGED (vs Sim2FlowsPrio): instead of one queue per flow, each flow is
% mapped to the queue of its priority level (1 = highest, 2 = second highest).
% Flow 3 -> priority 1; Flows 1 and 2 -> priority 2 (they share that queue).
PRIO= [2 2 1];

% Order in which the queues are served (highest priority first).
% CHANGED (vs Sim2FlowsPrio): fixed, it no longer depends on the input prio
ORDER= [1 2];

%State variables:
STATE = 0;              % 0 - connection is free; 1 - connection is occupied
QUEUEOCCUPATION= [0 0]; % Occupation of each queue (in Bytes): [priority 1, priority 2]
QUEUE= {[], []};        % Queue of each priority level: size, arriving time instant and flowID of each packet

% Initializing the required Statistical Counters:
% CHANGED (vs Sim2FlowsPrio): vectors of size nFlows (3) instead of 2
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
% CHANGED (vs Sim2FlowsPrio): loop over the 3 flows instead of 2 explicit lines
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
            % CHANGED (vs Sim2FlowsPrio): one generic size generator for all flows
            nextPacketSize= GenerateSize(Flow);
            EventList = [EventList; ARRIVAL, tmp, nextPacketSize, Flow, tmp];
            if STATE==0
                STATE= 1;
                EventList = [EventList; DEPARTURE, Clock + 8*PacketSize/(C*1e6), PacketSize, Flow, Clock];
            else
                % CHANGED (vs Sim2FlowsPrio): the packet goes to the queue of
                % its priority level q = PRIO(Flow), whose size is f(q)
                q= PRIO(Flow);
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
            % The next packet comes from the priority 1 queue if it is not
            % empty; only otherwise from the priority 2 queue (non-preemptive)
            if QUEUEOCCUPATION(ORDER(1)) > 0
                q= ORDER(1);
            elseif QUEUEOCCUPATION(ORDER(2)) > 0
                q= ORDER(2);
            else
                q= 0;
            end
            if q > 0
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

% CHANGED (vs Sim2FlowsPrio): GenerateSize1/GenerateSize2 replaced by a single
% function. Each flow has a packet size uniformly distributed (all integer
% values with equal probability) between minSize(Flow) and maxSize(Flow) Bytes.
function out= GenerateSize(Flow)
    minSize= [100  100  500];
    maxSize= [1500 150 1000];
    out= randi([minSize(Flow) maxSize(Flow)]);
end
