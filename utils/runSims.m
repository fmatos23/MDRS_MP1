function [m, ci, r] = runSims(simFun, N, alfa)
% RUNSIMS Corre um simulador N vezes e calcula médias e ICs.
%   [m, ci, r] = runSims(simFun, N, alfa)
%     simFun - function handle sem argumentos que devolve um vetor linha
%              com todos os parâmetros de uma corrida
%              (ex.: @() simRow(lambda, p))
%     N      - número de corridas (50)
%     alfa   - nível de significância (0.10 para IC a 90%)
%   Devolve:
%     m  - média de cada parâmetro
%     ci - semi-largura do IC (resultado = m +- ci)
%     r  - matriz N x nParam com os valores de cada corrida

    r1 = simFun();
    r  = zeros(N, numel(r1));
    r(1,:) = r1;
    for k = 2:N
        r(k,:) = simFun();
    end
    m  = mean(r);
    ci = norminv(1 - alfa/2) * std(r) / sqrt(N);
end
