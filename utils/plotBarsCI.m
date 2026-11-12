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
    figure('Renderer', 'painters');   % painters evita problemas de OpenGL
    b = bar(m); hold on; grid on;

    % centro de cada barra para pôr as error bars no sítio certo
    for s = 1:size(m, 2)
        x = b(s).XEndPoints;
        errorbar(x, m(:,s), ci(:,s), 'k', 'LineStyle', 'none', ...
                 'LineWidth', 1, 'HandleVisibility', 'off');
    end

    set(gca, 'XTick', 1:size(m,1), 'XTickLabel', xLabels);
    ylabel(yLabel); title(titulo);
    % margem no topo para as error bars não ficarem coladas ao limite
    ylim([0, 1.15 * max(m(:) + ci(:))]);
    if nargin >= 6 && ~isempty(legenda)
        % legenda fora da área do gráfico para não tapar as barras
        legend(legenda, 'Location', 'northoutside', 'Orientation', 'horizontal');
    end
    hold off;

    if nargin >= 7 && ~isempty(ficheiro)
        exportgraphics(gcf, ficheiro, 'Resolution', 200);
    end
end
