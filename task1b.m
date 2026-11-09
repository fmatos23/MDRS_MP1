% TASK 1.b - Parâmetros de desempenho de cada fluxo, caso C, f = 1.000.000 B
%   50 corridas do Sim3Flows, média e IC a 90%.

clear; close all;
addpath('simuladores', 'utils');
p = params();

lambda = p.lambda(3,:);     % caso C: [800 800 600] pps

[m, ci] = runSims(@() simRow(lambda, p), p.N, p.alfa);

% cada corrida devolve [PL APD MPD TT] -> 4 linhas x 3 fluxos
m  = reshape(m,  3, 4)';
ci = reshape(ci, 3, 4)';

nomes    = {'Packet loss (%)', 'Av. packet delay (ms)', ...
            'Max. packet delay (ms)', 'Throughput (Mbps)'};
fprintf('\nTask 1.b - Caso C (lambda = [%d %d %d] pps), f = %d B\n', lambda, p.f);
fprintf('%-24s %18s %18s %18s\n', '', 'Fluxo 1', 'Fluxo 2', 'Fluxo 3');
for k = 1:4
    fprintf('%-24s', nomes{k});
    fprintf(' %8.3f +- %6.3f', [m(k,:); ci(k,:)]);
    fprintf('\n');
end

% guardado para comparar com a teoria na 1.c
save(fullfile('results', 'task1b.mat'), 'm', 'ci', 'lambda');

function r = simRow(lambda, p)
    [PL, APD, MPD, TT] = Sim3Flows(lambda, p.C, p.f, p.P);
    r = [PL APD MPD TT];
end
