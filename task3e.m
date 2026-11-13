% TASK 3.e - Throughput ideal de cada fluxo segundo o princípio
%   weighted max-min fairness, para os casos da 3.c e da 3.d (caso D).
%   No DRR, o peso de cada fluxo é proporcional ao seu Quantum.

clear;
addpath('utils');
p = params();

lambda = p.lambda(4,:);             % caso D: [1000 1000 1000] pps
EB     = (p.minSize + p.maxSize) / 2;   % tamanho médio dos pacotes (Bytes)
d      = lambda .* EB * 8 / 1e6;    % débito pedido por cada fluxo (Mbps)

fprintf('\nTask 3.e - Weighted max-min fairness, caso D, C = %d Mbps\n', p.C);
fprintf('Débito pedido (Mbps): %.3f  %.3f  %.3f  (total %.3f)\n', d, sum(d));

exps = {'3.c', [1500 1500 1500], 'task3c.mat';
        '3.d', [1500 1500 4500], 'task3d.mat'};

for e = 1:size(exps, 1)
    Q = exps{e,2};
    w = Q / min(Q);                 % pesos proporcionais ao Quantum
    fprintf('\n--- %s: Q = [%d %d %d] B -> pesos = [%g %g %g] ---\n', exps{e,1}, Q, w);
    x = wmmf(d, w, p.C);

    fprintf('%-26s %10s %10s %10s\n', '', 'Fluxo 1', 'Fluxo 2', 'Fluxo 3');
    fprintf('%-26s %10.3f %10.3f %10.3f\n', 'Throughput ideal (Mbps)', x);
    fx = fullfile('results', exps{e,3});
    if isfile(fx)
        s = load(fx);
        fprintf('%-26s', 'Throughput simulado (Mbps)');
        fprintf(' %5.3f+-%4.3f', [s.m(4,:); s.ci(4,:)]);
        fprintf('\n');
    else
        fprintf('(corre o task%s para comparar com a simulação)\n', erase(exps{e,1}, '.'));
    end
end

% Weighted max-min fairness ("water-filling"): em cada iteração a
% capacidade que sobra é dividida pelos fluxos ainda não satisfeitos em
% proporção aos pesos; os fluxos que pedem menos do que a sua parte
% recebem o que pedem e a sobra é redistribuída pelos restantes.
function x = wmmf(d, w, C)
    n = numel(d);
    x = zeros(1, n);
    ativo = true(1, n);             % fluxos ainda não satisfeitos
    resto = C;                      % capacidade ainda por atribuir
    it = 0;
    while any(ativo)
        it = it + 1;
        parte = resto / sum(w(ativo));          % capacidade por unidade de peso
        oferta = parte * w;
        fprintf('  Iteração %d: capacidade livre = %.3f Mbps, por unidade de peso = %.3f Mbps\n', ...
                it, resto, parte);
        sat = ativo & (d - x <= oferta);        % fluxos que ficam satisfeitos
        if ~any(sat)
            % nenhum fica satisfeito: todos os ativos recebem a sua parte
            for i = find(ativo)
                fprintf('    Fluxo %d: recebe %.3f Mbps (pede %.3f)\n', i, x(i) + oferta(i), d(i));
            end
            x(ativo) = x(ativo) + oferta(ativo);
            break;
        end
        for i = find(sat)
            fprintf('    Fluxo %d: pede %.3f <= %.3f, recebe o que pede\n', i, d(i), oferta(i));
        end
        resto = resto - sum(d(sat) - x(sat));
        x(sat) = d(sat);
        ativo(sat) = false;
    end
end
