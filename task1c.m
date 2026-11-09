% TASK 1.c - Caso C modelado por M/G/1: atraso médio e throughput teóricos
%   Os 3 fluxos partilham uma fila FIFO única. O agregado é Poisson
%   (soma de Poisson) e o tempo de serviço é a mistura dos 3 fluxos.

clear;
addpath('utils');
p = params();

lambda = p.lambda(3,:);     % caso C: [800 800 600] pps
a = p.minSize;  b = p.maxSize;

% Tamanho de pacote uniforme discreto em [a, b] (Bytes)
EB  = (a + b) / 2;                  % E[B]
VB  = ((b - a + 1).^2 - 1) / 12;    % Var[B]
EB2 = VB + EB.^2;                   % E[B^2]

% Tempo de transmissão S = 8B/C (segundos)
ES  = 8 * EB  / (p.C * 1e6);        % E[S]   de cada fluxo
ES2 = (8 / (p.C * 1e6))^2 * EB2;    % E[S^2] de cada fluxo

% Pollaczek-Khinchine: sum(lambda_i E[S_i^2]) = lambda_total E[S^2] da mistura
rho = sum(lambda .* ES);
Wq  = sum(lambda .* ES2) / (2 * (1 - rho));   % espera na fila (igual p/ todos)

APDt = 1000 * (Wq + ES);            % atraso médio de cada fluxo (ms)
TTt  = lambda .* EB * 8 / 1e6;      % throughput de cada fluxo (Mbps), sem perdas

fprintf('\nTask 1.c - M/G/1, caso C (rho = %.4f, Wq = %.4f ms)\n', rho, 1000*Wq);
fprintf('%-24s %10s %10s %10s\n', '', 'Fluxo 1', 'Fluxo 2', 'Fluxo 3');
fprintf('%-24s %10.4f %10.4f %10.4f\n', 'Av. packet delay (ms)', APDt);
fprintf('%-24s %10.4f %10.4f %10.4f\n', 'Throughput (Mbps)', TTt);

% Comparação com a simulação da 1.b (se já tiver sido corrida)
f1b = fullfile('results', 'task1b.mat');
if isfile(f1b)
    s = load(f1b);
    fprintf('\nComparação com a simulação (1.b):\n');
    fprintf('%-24s %18s %18s %18s\n', '', 'Fluxo 1', 'Fluxo 2', 'Fluxo 3');
    fprintf('%-24s', 'APD simulado (ms)');
    fprintf(' %8.4f +- %6.4f', [s.m(2,:); s.ci(2,:)]);
    fprintf('\n%-24s', 'APD teórico (ms)');
    fprintf(' %18.4f', APDt);
    fprintf('\n%-24s', 'TT simulado (Mbps)');
    fprintf(' %8.4f +- %6.4f', [s.m(4,:); s.ci(4,:)]);
    fprintf('\n%-24s', 'TT teórico (Mbps)');
    fprintf(' %18.4f', TTt);
    fprintf('\n');
else
    fprintf('\n(corre o task1b para comparar com a simulação)\n');
end
