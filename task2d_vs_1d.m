% TASK 2.d (comparação) - Fluxo 3: FIFO (1.d) vs prioridades (2.d)
%   Lê results/task1d.mat e results/task2d.mat e desenha os gráficos de
%   comparação, sem voltar a correr as simulações.

addpath('utils');
p = params();
casos = 1:3;                % A, B, C

f1d = fullfile('results', 'task1d.mat');
f2d = fullfile('results', 'task2d.mat');
if ~isfile(f1d) || ~isfile(f2d)
    error('Faltam resultados: corre primeiro o task1d e o task2d.');
end
s1 = load(f1d);   % FIFO
s2 = load(f2d);   % prioridades

fprintf('\nFluxo 3: FIFO (1.d) vs prioridades (2.d)\n');
fprintf('%-6s %24s %24s %24s %24s\n', 'Caso', 'APD FIFO (ms)', 'APD Prio (ms)', ...
        'MPD FIFO (ms)', 'MPD Prio (ms)');
for k = 1:numel(casos)
    fprintf('%-6s %12.4f +- %8.4f %12.4f +- %8.4f %12.4f +- %8.4f %12.4f +- %8.4f\n', ...
            p.cases{casos(k)}, s1.APD3(k), s1.APD3ci(k), s2.APD3(k), s2.APD3ci(k), ...
            s1.MPD3(k), s1.MPD3ci(k), s2.MPD3(k), s2.MPD3ci(k));
end

plotBarsCI([s1.APD3' s2.APD3'], [s1.APD3ci' s2.APD3ci'], p.cases(casos), 'Delay (ms)', ...
           'Average packet delay of Flow 3: FIFO vs priority', ...
           {'FIFO (1.d)', 'Priority (2.d)'}, ...
           fullfile('results', 'task2d_vs_1d_apd.png'));
plotBarsCI([s1.MPD3' s2.MPD3'], [s1.MPD3ci' s2.MPD3ci'], p.cases(casos), 'Delay (ms)', ...
           'Maximum packet delay of Flow 3: FIFO vs priority', ...
           {'FIFO (1.d)', 'Priority (2.d)'}, ...
           fullfile('results', 'task2d_vs_1d_mpd.png'));
