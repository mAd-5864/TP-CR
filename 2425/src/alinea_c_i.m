tempoInicioScript = tic;

% Parâmetros
pathTest = '../datasets/test/';
classes = {'circle', 'kite', 'parallelogram', 'square', 'trapezoid', 'triangle'};
imgSize = [32 32];

% Carrega dados de teste
[Xtest, Ytest] = carregarImagens(pathTest, classes, imgSize);
Xtest = Xtest / 255.0;

fprintf('A testar redes guardadas com imagens da pasta "test"...\n');
% Diretório com as melhores redes
pastas = dir('../redes_gravadas/estudoNNN');

for j = 1:length(pastas)
    pastaRedes = fullfile(pastas(j).folder, pastas(j).name);
    ficheirosRedes = dir(fullfile(pastaRedes, 'rede_melhor_*.mat'));

    for i = 1:length(ficheirosRedes)
        nomeRede = ficheirosRedes(i).name;
        caminhoRede = fullfile(pastaRedes, nomeRede);

        % Carregar rede
        dados = load(caminhoRede);
        net = dados.net;

        % Classificar dados de teste
        saidas = net(Xtest);
        [~, predicoes] = max(saidas, [], 1);
        [~, reais] = max(Ytest, [], 1);

        % Calcular precisão e matriz de confusão
        precisao = sum(predicoes == reais) / numel(reais) * 100;
        matrizConfusao = calcularMatrizConfusao(predicoes, reais, length(classes));

        % Mostrar resultados
        fprintf('\nRede %d (%s)\n', i, nomeRede);
        fprintf('-> Precisão com pasta test: %.2f%%\n', precisao);

        % Plot da matriz de confusão
        h = figure;
        plotConfusionMatrix(matrizConfusao, classes);
        title(sprintf('Matriz de Confusão - Rede %d (Reteste)', i));
        saveas(h, fullfile(pastaRedes, sprintf('conf_matrix_retest_%d.png', i)));
        close(h);
    end
end

tempoTotal = toc(tempoInicioScript);
fprintf('\nTempo total de execução: %.2f minutos\n', tempoTotal / 60);