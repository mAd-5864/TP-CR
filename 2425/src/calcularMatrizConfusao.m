function confMatrix = calcularMatrizConfusao(predicoes, reais, numClasses)
    confMatrix = zeros(numClasses, numClasses);
    for i = 1:length(predicoes)
        confMatrix(reais(i), predicoes(i)) = confMatrix(reais(i), predicoes(i)) + 1;
    end
end
