function p = params()
% PARAMS Parâmetros comuns do Mini-Projeto 1.
%   p = params() devolve uma struct com os dados do enunciado.

    p.C     = 10;          % capacidade da ligação (Mbps)
    p.P     = 1e5;         % critério de paragem (pacotes transmitidos)
    p.N     = 50;          % número de corridas
    p.alfa  = 0.10;        % IC a 90%
    p.f     = 1e6;         % tamanho da fila (Bytes)

    % Tamanhos de pacote por fluxo (Bytes) - uniforme discreto
    p.minSize = [100  100  500];
    p.maxSize = [1500 150 1000];

    % Taxas de chegada (pps) por caso: linhas = casos, colunas = fluxos
    p.cases  = {'A','B','C','D'};
    p.lambda = [ 400  400  600;
                 600  600  600;
                 800  800  600;
                1000 1000 1000];
end
