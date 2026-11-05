function plotBarsCI(m, ci, xLabels, yLabel, titulo, legenda, ficheiro)
% PLOTBARSCI Gráfico de barras com error bars (IC).
%   plotBarsCI(m, ci, xLabels, yLabel, titulo, legenda, ficheiro)
%     m, ci    - vetor (1 série) ou matriz nGrupos x nSeries
%     xLabels  - cell com os nomes dos grupos (ex.: {'A','B','C'})
%     yLabel   - texto do eixo y
%     titulo   - título do gráfico
%     legenda  - cell com nomes das séries ({} se só houver uma)
%     ficheiro - (opcional) caminho para guardar em .png

    if isvector(m), m = m(:); ci = ci(:); end
    figure;
    b = bar(m); hold on; grid on;

    % centro de cada barra para pôr as error bars no sítio certo
    for s = 1:size(m, 2)
        x = b(s).XEndPoints;
        errorbar(x, m(:,s), ci(:,s), 'k', 'LineStyle', 'none', ...
                 'LineWidth', 1, 'HandleVisibility', 'off');
    end

    set(gca, 'XTick', 1:size(m,1), 'XTickLabel', xLabels);
    ylabel(yLabel); title(titulo);
    if nargin >= 6 && ~isempty(legenda)
        legend(legenda, 'Location', 'northwest');
    end
    hold off;

    if nargin >= 7 && ~isempty(ficheiro)
        exportgraphics(gcf, ficheiro, 'Resolution', 200);
    end
end
