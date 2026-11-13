% TASK 3.c - Parâmetros de desempenho de cada fluxo, caso D (congestionado), DRR
%   Quantum = 1500 B para cada fluxo, f1 = f2 = f3 = 1.000.000 B,
%   50 corridas do Sim3FlowsDRR, média e IC a 90%.

clear; close all;
addpath('simuladores', 'utils');
p = params();

lambda = p.lambda(4,:);     % caso D: [1000 1000 1000] pps
Q      = [1500 1500 1500];  % Quantum de cada fluxo (Bytes)
f      = [p.f p.f p.f];     % tamanho da fila de cada fluxo (Bytes)

[m, ci] = runSims(@() simRow(lambda, f, Q, p), p.N, p.alfa);

% cada corrida devolve [PL APD MPD TT] -> 4 linhas x 3 fluxos
m  = reshape(m,  3, 4)';
ci = reshape(ci, 3, 4)';

nomes    = {'Packet loss (%)', 'Av. packet delay (ms)', ...
            'Max. packet delay (ms)', 'Throughput (Mbps)'};
fprintf('\nTask 3.c - DRR, caso D (lambda = [%d %d %d] pps), Q = [%d %d %d] B\n', lambda, Q);
fprintf('%-24s %18s %18s %18s\n', '', 'Fluxo 1', 'Fluxo 2', 'Fluxo 3');
for k = 1:4
    fprintf('%-24s', nomes{k});
    fprintf(' %8.3f +- %6.3f', [m(k,:); ci(k,:)]);
    fprintf('\n');
end

% guardado para comparar na 3.d e com a teoria na 3.e
save(fullfile('results', 'task3c.mat'), 'm', 'ci', 'lambda', 'Q');

% Comparação com a 3.b (caso C), se já tiver sido corrida
f3b = fullfile('results', 'task3b.mat');
if isfile(f3b)
    s = load(f3b);
    fprintf('\nComparação com a 3.b (caso C):\n');
    fprintf('%-30s %18s %18s %18s\n', '', 'Fluxo 1', 'Fluxo 2', 'Fluxo 3');
    for k = 1:4
        fprintf('%-30s', [nomes{k} ' C']);
        fprintf(' %8.3f +- %6.3f', [s.m(k,:); s.ci(k,:)]);
        fprintf('\n%-30s', [nomes{k} ' D']);
        fprintf(' %8.3f +- %6.3f', [m(k,:); ci(k,:)]);
        fprintf('\n');
    end
end

function r = simRow(lambda, f, Q, p)
    [PL, APD, MPD, TT] = Sim3FlowsDRR(lambda, p.C, f, p.P, Q);
    r = [PL APD MPD TT];
end
