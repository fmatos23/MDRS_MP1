% TASK 2.d - Atraso médio e máximo do Fluxo 3 nos casos A, B e C, com prioridades
%   f1 = f2 = 1.000.000 B, 50 corridas do Sim3FlowsPrio, média e IC a 90%.

clear; close all;
addpath('simuladores', 'utils');
p = params();

casos = 1:3;                % A, B, C
nC    = numel(casos);
APD3  = zeros(1,nC);  APD3ci = zeros(1,nC);
MPD3  = zeros(1,nC);  MPD3ci = zeros(1,nC);

for k = 1:nC
    lambda = p.lambda(casos(k),:);
    [m, ci] = runSims(@() simRowF3(lambda, p), p.N, p.alfa);
    APD3(k) = m(1);  APD3ci(k) = ci(1);
    MPD3(k) = m(2);  MPD3ci(k) = ci(2);
end

fprintf('\nTask 2.d - Fluxo 3 com prioridade, f1 = f2 = %d B\n', p.f);
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

% Comparação com a FIFO da 1.d, se os resultados da 1.d tiverem sido
% guardados em results/task1d.mat (com as mesmas variáveis)
f1d = fullfile('results', 'task1d.mat');
if isfile(f1d)
    s = load(f1d);
    plotBarsCI([s.APD3' APD3'], [s.APD3ci' APD3ci'], p.cases(casos), 'Delay (ms)', ...
               'Average packet delay of Flow 3: FIFO vs priority', ...
               {'FIFO (1.d)', 'Priority (2.d)'}, ...
               fullfile('results', 'task2d_vs_1d_apd.png'));
    plotBarsCI([s.MPD3' MPD3'], [s.MPD3ci' MPD3ci'], p.cases(casos), 'Delay (ms)', ...
               'Maximum packet delay of Flow 3: FIFO vs priority', ...
               {'FIFO (1.d)', 'Priority (2.d)'}, ...
               fullfile('results', 'task2d_vs_1d_mpd.png'));
end

function r = simRowF3(lambda, p)
    [~, APD, MPD] = Sim3FlowsPrio(lambda, p.C, p.f, p.f, p.P);
    r = [APD(3) MPD(3)];
end
