function plotConfusionMatrix(confMatrix, classNames)
    confMatrixPercent = zeros(size(confMatrix));
    for i = 1:size(confMatrix, 1)
        if sum(confMatrix(i,:)) > 0
            confMatrixPercent(i,:) = confMatrix(i,:) / sum(confMatrix(i,:)) * 100;
        end
    end

    imagesc(confMatrixPercent);
    colormap('jet');
    colorbar;

    numClasses = length(classNames);
    set(gca, 'XTick', 1:numClasses, 'XTickLabel', classNames, ...
        'YTick', 1:numClasses, 'YTickLabel', classNames);
    xtickangle(45);

    [x, y] = meshgrid(1:numClasses);
    for i = 1:numClasses
        for j = 1:numClasses
            if confMatrixPercent(i,j) > 50
                textColor = [0 0 0];
            else
                textColor = [1 1 1];
            end
            text(j, i, sprintf('%.1f%%', confMatrixPercent(i,j)), ...
                'HorizontalAlignment', 'center', 'Color', textColor);
        end
    end

    xlabel('Classe Prevista');
    ylabel('Classe Real');
    title('Matriz de Confusão (%)');
end
