% TASK 3.b - Parâmetros de desempenho de cada fluxo, caso C, DRR
%   Quantum = 1500 B para cada fluxo, f1 = f2 = f3 = 1.000.000 B,
%   50 corridas do Sim3FlowsDRR, média e IC a 90%.

clear; close all;
addpath('simuladores', 'utils');
p = params();

lambda = p.lambda(3,:);     % caso C: [800 800 600] pps
Q      = [1500 1500 1500];  % Quantum de cada fluxo (Bytes)
f      = [p.f p.f p.f];     % tamanho da fila de cada fluxo (Bytes)

[m, ci] = runSims(@() simRow(lambda, f, Q, p), p.N, p.alfa);

% cada corrida devolve [PL APD MPD TT] -> 4 linhas x 3 fluxos
m  = reshape(m,  3, 4)';
ci = reshape(ci, 3, 4)';

nomes    = {'Packet loss (%)', 'Av. packet delay (ms)', ...
            'Max. packet delay (ms)', 'Throughput (Mbps)'};
fprintf('\nTask 3.b - DRR, caso C (lambda = [%d %d %d] pps), Q = [%d %d %d] B\n', lambda, Q);
fprintf('%-24s %18s %18s %18s\n', '', 'Fluxo 1', 'Fluxo 2', 'Fluxo 3');
for k = 1:4
    fprintf('%-24s', nomes{k});
    fprintf(' %8.3f +- %6.3f', [m(k,:); ci(k,:)]);
    fprintf('\n');
end

save(fullfile('results', 'task3b.mat'), 'm', 'ci', 'lambda', 'Q');

% Comparação com a FIFO (1.b) e as prioridades (2.b), se já tiverem sido corridas
outros = {'task1b.mat', 'FIFO'; 'task2b.mat', 'Prio'};
fprintf('\nComparação com 1.b (FIFO) e 2.b (prioridades):\n');
fprintf('%-30s %18s %18s %18s\n', '', 'Fluxo 1', 'Fluxo 2', 'Fluxo 3');
for k = 1:4
    for j = 1:size(outros, 1)
        fx = fullfile('results', outros{j,1});
        if isfile(fx)
            s = load(fx);
            fprintf('%-30s', [nomes{k} ' ' outros{j,2}]);
            fprintf(' %8.3f +- %6.3f', [s.m(k,:); s.ci(k,:)]);
            fprintf('\n');
        end
    end
    fprintf('%-30s', [nomes{k} ' DRR']);
    fprintf(' %8.3f +- %6.3f', [m(k,:); ci(k,:)]);
    fprintf('\n');
end

function r = simRow(lambda, f, Q, p)
    [PL, APD, MPD, TT] = Sim3FlowsDRR(lambda, p.C, f, p.P, Q);
    r = [PL APD MPD TT];
end
