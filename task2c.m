% TASK 2.c - Caso C modelado por M/G/1 com prioridades (sem preempção):
%   atraso médio teórico de cada fluxo.
%   Classe 1 (mais prioritária) = Fluxo 3; classe 2 = Fluxos 1 e 2.

clear;
addpath('utils');
p = params();

lambda = p.lambda(3,:);     % caso C: [800 800 600] pps
prio   = [2 2 1];           % classe de prioridade de cada fluxo (1 = mais alta)
a = p.minSize;  b = p.maxSize;

% Tamanho de pacote uniforme discreto em [a, b] (Bytes)
EB  = (a + b) / 2;                  % E[B]
VB  = ((b - a + 1).^2 - 1) / 12;    % Var[B]
EB2 = VB + EB.^2;                   % E[B^2]

% Tempo de transmissão S = 8B/C (segundos)
ES  = 8 * EB  / (p.C * 1e6);        % E[S]   de cada fluxo
ES2 = (8 / (p.C * 1e6))^2 * EB2;    % E[S^2] de cada fluxo

% Tempo residual médio: o que falta transmitir ao pacote em serviço
% (soma sobre TODOS os fluxos, porque não há preempção)
W0  = sum(lambda .* ES2) / 2;

% Carga de cada classe e carga acumulada (classes de prioridade >= k)
nClasses = max(prio);
rhoClasse = zeros(1, nClasses);
for k = 1:nClasses
    rhoClasse(k) = sum(lambda(prio == k) .* ES(prio == k));
end
sigma = cumsum(rhoClasse);          % sigma(k) = rho_1 + ... + rho_k

% Espera na fila de cada classe: Wq_k = W0 / ((1 - sigma_{k-1}) (1 - sigma_k))
sigmaAnt = [0 sigma(1:end-1)];      % sigma_{k-1}, com sigma_0 = 0
WqClasse = W0 ./ ((1 - sigmaAnt) .* (1 - sigma));

% Atraso médio de cada fluxo = espera da sua classe + transmissão própria
APDt = 1000 * (WqClasse(prio) + ES);   % ms

fprintf('\nTask 2.c - M/G/1 com prioridades, caso C\n');
fprintf('  rho classe 1 (Fluxo 3) = %.4f, rho total = %.4f\n', sigma(1), sigma(end));
fprintf('  Wq classe 1 = %.4f ms, Wq classe 2 = %.4f ms\n', 1000*WqClasse);
fprintf('%-24s %10s %10s %10s\n', '', 'Fluxo 1', 'Fluxo 2', 'Fluxo 3');
fprintf('%-24s %10.4f %10.4f %10.4f\n', 'Av. packet delay (ms)', APDt);

% Comparação com a simulação da 2.b (se já tiver sido corrida)
f2b = fullfile('results', 'task2b.mat');
if isfile(f2b)
    s = load(f2b);
    fprintf('\nComparação com a simulação (2.b):\n');
    fprintf('%-24s %18s %18s %18s\n', '', 'Fluxo 1', 'Fluxo 2', 'Fluxo 3');
    fprintf('%-24s', 'APD simulado (ms)');
    fprintf(' %8.4f +- %6.4f', [s.m(2,:); s.ci(2,:)]);
    fprintf('\n%-24s', 'APD teórico (ms)');
    fprintf(' %18.4f', APDt);
    fprintf('\n');
else
    fprintf('\n(corre o task2b para comparar com a simulação)\n');
end
