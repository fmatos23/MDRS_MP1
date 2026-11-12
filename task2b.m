% TASK 2.b - Parâmetros de desempenho de cada fluxo, caso C, com prioridades
%   Fluxo 3 com prioridade 1 (mais alta), Fluxos 1 e 2 com prioridade 2.
%   f1 = f2 = 1.000.000 B, 50 corridas do Sim3FlowsPrio, média e IC a 90%.
%   Sim3FlowsPrio(lambda, C, f, P) é a nova versão do Sim2FlowsPrio:
%   f = [f1 f2] -> f1 = fila de prioridade 1 (Fluxo 3),
%                  f2 = fila de prioridade 2 (Fluxos 1 e 2).

clear; close all;
addpath('simuladores', 'utils');
p = params();

lambda = p.lambda(3,:);     % caso C: [800 800 600] pps
f      = [p.f p.f];         % [f1 f2] = tamanho de cada fila (Bytes)

[m, ci] = runSims(@() simRow(lambda, f, p), p.N, p.alfa);

% cada corrida devolve [PL APD MPD TT] -> 4 linhas x 3 fluxos
m  = reshape(m,  3, 4)';
ci = reshape(ci, 3, 4)';

nomes    = {'Packet loss (%)', 'Av. packet delay (ms)', ...
            'Max. packet delay (ms)', 'Throughput (Mbps)'};
fprintf('\nTask 2.b - Prioridades, caso C (lambda = [%d %d %d] pps), f1 = %d B, f2 = %d B\n', lambda, f);
fprintf('%-24s %18s %18s %18s\n', '', 'Fluxo 1', 'Fluxo 2', 'Fluxo 3');
for k = 1:4
    fprintf('%-24s', nomes{k});
    fprintf(' %8.3f +- %6.3f', [m(k,:); ci(k,:)]);
    fprintf('\n');
end

% guardado para comparar com a teoria na 2.c
save(fullfile('results', 'task2b.mat'), 'm', 'ci', 'lambda');

% Comparação com a FIFO da 1.b (se já tiver sido corrida)
f1b = fullfile('results', 'task1b.mat');
if isfile(f1b)
    s = load(f1b);
    fprintf('\nComparação com a FIFO (1.b):\n');
    fprintf('%-30s %18s %18s %18s\n', '', 'Fluxo 1', 'Fluxo 2', 'Fluxo 3');
    for k = 1:4
        fprintf('%-30s', [nomes{k} ' FIFO']);
        fprintf(' %8.3f +- %6.3f', [s.m(k,:); s.ci(k,:)]);
        fprintf('\n%-30s', [nomes{k} ' Prio']);
        fprintf(' %8.3f +- %6.3f', [m(k,:); ci(k,:)]);
        fprintf('\n');
    end
end

function r = simRow(lambda, f, p)
    [PL, APD, MPD, TT] = Sim3FlowsPrio(lambda, p.C, f, p.P);
    r = [PL APD MPD TT];
end
