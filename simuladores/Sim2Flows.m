function [PL , APD , MPD , TT] = Sim2Flows(lambda,C,f,P)
% INPUT PARAMETERS:
%  lambda - row vector with the packet rate of each flow (packets/sec)
%  C      - link bandwidth (Mbps)
%  f      - queue size (Bytes)
%  P      - number of packets (stopping criterium)
% OUTPUT PARAMETERS:
%  PL   - row vector with the packet loss (%) of each flow
%  APD  - row vector with the average packet delay (milliseconds) of each flow
%  MPD  - maximum packet delay (milliseconds) of each flow
%  TT   - transmitted throughput (Mbps) of each flow

%Events:
ARRIVAL= 0;       % Arrival of a packet            
DEPARTURE= 1;     % Departure of a packet

%State variables:
STATE = 0;          % 0 - connection is free; 1 - connection is occupied
QUEUEOCCUPATION= 0; % Occupation of the queue (in Bytes)
QUEUE= [];          % Size, arriving time instant and flowID of each packet in the queue

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
            tmp= Clock + exprnd(1/lambda(Flow)); %calcula quando chega o proximo pacote do fluxo
            if Flow==1 
                nextPacketSize= GenerateSize1();
            else
                nextPacketSize= GenerateSize2();
            end
            EventList = [EventList; ARRIVAL, tmp, nextPacketSize, Flow, tmp]; %agenda a proxima chegada do fluxo
            if STATE==0 %verifica se a ligação está livre
                STATE= 1; %se está livre passa a ocupada
                EventList = [EventList; DEPARTURE, Clock + 8*PacketSize/(C*1e6), PacketSize, Flow, Clock]; %começa a transmitir o pacote
            else
                if QUEUEOCCUPATION + PacketSize <= f %verifica se o pacote cabe na fila, total nao pode passar f
                    QUEUE= [QUEUE; PacketSize , Clock, Flow]; %cabendo poe no fim da fila com os dados
                    QUEUEOCCUPATION= QUEUEOCCUPATION + PacketSize; %ocupação aumenta
                else
                    LOSTPACKETS(Flow)= LOSTPACKETS(Flow) + 1; %o pacote nao cabendo é descartado e conta como perdido
                end
            end
        case DEPARTURE          % If event is a DEPARTURE
            TRANSBYTES(Flow)= TRANSBYTES(Flow) + PacketSize;
            TRANSPACKETS(Flow)= TRANSPACKETS(Flow) + 1; %conta mais um pacote transmitido
            DELAYS(Flow)= DELAYS(Flow) + (Clock - ArrInstant); %calcula o delay (instante em que saiu menos o instante em que chegou) e soma-o ao total do fluxo
            if Clock - ArrInstant > MAXDELAY(Flow)
                MAXDELAY(Flow)= Clock - ArrInstant;  %se o atraso for o maior até agora guarda-o como novo maximo
            end
            if QUEUEOCCUPATION > 0 %ligação estando livre verifica se há pacotes na fila
                QSize= QUEUE(1,1);
                QInstant= QUEUE(1,2);
                QFlow= QUEUE(1,3);
                EventList = [EventList; DEPARTURE, Clock + 8*QSize/(C*1e6), QSize, QFlow, QInstant];
                QUEUEOCCUPATION= QUEUEOCCUPATION - QSize;
                QUEUE(1,:)= [];
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