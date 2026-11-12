% TASK 2.d - Atraso médio e máximo do Fluxo 3 nos casos A, B e C, com prioridades
%   f1 = f2 = 1.000.000 B, 50 corridas do Sim3FlowsPrio, média e IC a 90%.
%   Sim3FlowsPrio(lambda, C, f, P) é a nova versão do Sim2FlowsPrio:
%   f = [f1 f2] -> f1 = fila de prioridade 1 (Fluxo 3),
%                  f2 = fila de prioridade 2 (Fluxos 1 e 2).

clear; close all;
addpath('simuladores', 'utils');
p = params();

casos = 1:3;                % A, B, C
f     = [p.f p.f];          % [f1 f2] = tamanho de cada fila (Bytes)
nC    = numel(casos);
APD3  = zeros(1,nC);  APD3ci = zeros(1,nC);
MPD3  = zeros(1,nC);  MPD3ci = zeros(1,nC);

for k = 1:nC
    lambda = p.lambda(casos(k),:);
    [m, ci] = runSims(@() simRowF3(lambda, f, p), p.N, p.alfa);
    APD3(k) = m(1);  APD3ci(k) = ci(1);
    MPD3(k) = m(2);  MPD3ci(k) = ci(2);
end

fprintf('\nTask 2.d - Fluxo 3 com prioridade, f1 = %d B, f2 = %d B\n', f);
fprintf('%-6s %26s %26s\n', 'Caso', 'Av. delay (ms)', 'Max. delay (ms)');
for k = 1:nC
    fprintf('%-6s %14.4f +- %8.4f %14.4f +- %8.4f\n', p.cases{casos(k)}, ...
            APD3(k), APD3ci(k), MPD3(k), MPD3ci(k));
end

save(fullfile('results', 'task2d.mat'), 'APD3', 'APD3ci', 'MPD3', 'MPD3ci');

plotBarsCI([APD3' MPD3'], [APD3ci' MPD3ci'], p.cases(casos), 'Delay (ms)', ...
           'Task 2.d - Packet delay of Flow 3 (priority)', ...
           {'Average delay', 'Maximum delay'}, ...
           fullfile('results', 'task2d.png'));

% Comparação com a FIFO da 1.d (precisa de results/task1d.mat,
% que o task1d guarda). Também se pode correr sozinho: task2d_vs_1d
if isfile(fullfile('results', 'task1d.mat'))
    task2d_vs_1d;
else
    fprintf('\n(corre o task1d e depois o task2d_vs_1d para comparar com a FIFO)\n');
end

function r = simRowF3(lambda, f, p)
    [~, APD, MPD] = Sim3FlowsPrio(lambda, p.C, f, p.P);
    r = [APD(3) MPD(3)];
end
