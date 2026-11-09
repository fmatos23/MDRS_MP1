% TASK 1.d - Atraso médio e máximo do Fluxo 3 nos casos A, B e C
%   f = 1.000.000 B, 50 corridas do Sim3Flows, média e IC a 90%.

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

fprintf('\nTask 1.d - Fluxo 3, f = %d B\n', p.f);
fprintf('%-6s %26s %26s\n', 'Caso', 'Av. delay (ms)', 'Max. delay (ms)');
for k = 1:nC
    fprintf('%-6s %14.4f +- %8.4f %14.4f +- %8.4f\n', p.cases{casos(k)}, ...
            APD3(k), APD3ci(k), MPD3(k), MPD3ci(k));
end

plotBarsCI([APD3' MPD3'], [APD3ci' MPD3ci'], p.cases(casos), 'Delay (ms)', ...
           'Task 1.d - Packet delay of Flow 3 (FIFO)', ...
           {'Average delay', 'Maximum delay'}, ...
           fullfile('results', 'task1d.png'));

function r = simRowF3(lambda, p)
    [~, APD, MPD] = Sim3Flows(lambda, p.C, p.f, p.P);
    r = [APD(3) MPD(3)];
end
