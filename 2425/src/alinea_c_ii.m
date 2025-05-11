tempoInicioScript = tic;

% Definição de parâmetros
pathStart = '../datasets/start/';
pathTrain = '../datasets/train/';
pathTest = '../datasets/test/';
classes = {'circle', 'kite', 'parallelogram', 'square', 'trapezoid', 'triangle'};
imgSize = [32 32];
pastaResultados = '../resultados_estudo_ii/';

if ~exist(pastaResultados, 'dir')
    mkdir(pastaResultados);
end

% Carregar dados de todas as pastas
[Xstart, Ystart] = carregarImagens(pathStart, classes, imgSize);
[Xtrain, Ytrain] = carregarImagens(pathTrain, classes, imgSize);
[Xtest, Ytest] = carregarImagens(pathTest, classes, imgSize);

Xstart = Xstart / 255.0;
Xtrain = Xtrain / 255.0;
Xtest = Xtest / 255.0;

pastas = dir('../redes_gravadas/estudoNNN');

% Tabela para armazenar resultados
resultados = table('Size', [0, 7], 'VariableTypes', {'string', 'double', 'double', 'double', 'double', 'double', 'double'}, ...
                   'VariableNames', {'Rede', 'PrecisaoTreino', 'PrecisaoValidacao', 'PrecisaoStart', 'PrecisaoTrain', 'PrecisaoTest', 'TempoTreino'});

for j = 1:length(pastas)
    pastaRedes = fullfile(pastas(j).folder, pastas(j).name);
    ficheirosRedes = dir(fullfile(pastaRedes, 'rede_melhor_*.mat'));
    
    for i = 1:length(ficheirosRedes)
        nomeRede = ficheirosRedes(i).name;
        pathRede = fullfile(pastaRedes, nomeRede);
        
        dados = load(pathRede);
        redeOriginal = dados.net;
        
        % Extrair a topologia da rede original
        config = [];
        for camada = 1:length(redeOriginal.layers)
            if isa(redeOriginal.layers{camada}, 'nnet.layer.FclayerClass')
                config = [config, redeOriginal.layers{camada}.dimensions];
            end
        end
        
        nomeNovaRede = sprintf('rede_test_%d', i);
        novaRede = feedforwardnet(config);

        
        % Treinar a nova rede apenas com imagens da pasta test
        fprintf('Treinando rede com imagens da pasta test...\n');
        tempoInicioTreino = tic;
        [novaRede, tr] = train(novaRede, Xtest, Ytest);
        tempoTreino = toc(tempoInicioTreino);
        
        % Avaliar a rede em cada conjunto de dados
        fprintf('Avaliando rede com imagens da pasta start...\n');
        saidasStart = novaRede(Xstart);
        [~, predicoesStart] = max(saidasStart, [], 1);
        [~, reaisStart] = max(Ystart, [], 1);
        precisaoStart = sum(predicoesStart == reaisStart) / numel(reaisStart) * 100;
        
        fprintf('Avaliando rede com imagens da pasta train...\n');
        saidasTrain = novaRede(Xtrain);
        [~, predicoesTrain] = max(saidasTrain, [], 1);
        [~, reaisTrain] = max(Ytrain, [], 1);
        precisaoTrain = sum(predicoesTrain == reaisTrain) / numel(reaisTrain) * 100;
        
        fprintf('Avaliando rede com imagens da pasta test...\n');
        saidasTest = novaRede(Xtest);
        [~, predicoesTest] = max(saidasTest, [], 1);
        [~, reaisTest] = max(Ytest, [], 1);
        precisaoTest = sum(predicoesTest == reaisTest) / numel(reaisTest) * 100;
        
        matrizConfusao = calcularMatrizConfusao(predicoesTest, reaisTest, length(classes));
        
        fprintf('\nResultados para rede %s:\n', nomeNovaRede);
        fprintf('-> Precisão de treino: %.2f%%\n', tr.best_perf * 100);
        fprintf('-> Precisão de validação: %.2f%%\n', tr.best_vperf * 100);
        fprintf('-> Precisão com pasta start: %.2f%%\n', precisaoStart);
        fprintf('-> Precisão com pasta train: %.2f%%\n', precisaoTrain);
        fprintf('-> Precisão com pasta test: %.2f%%\n', precisaoTest);
        fprintf('-> Tempo de treino: %.2f segundos\n', tempoTreino);
        
        novaLinha = {nomeNovaRede, tr.best_perf * 100, tr.best_vperf * 100, ...
                     precisaoStart, precisaoTrain, precisaoTest, tempoTreino};
        resultados = [resultados; novaLinha];
        
        pathGuardarRede = fullfile(pastaResultados, sprintf('%s.mat', nomeNovaRede));
        net = novaRede;
        save(pathGuardarRede, 'net');
        
        % Plot da matriz de confusão
        h = figure;
        plotConfusionMatrix(matrizConfusao, classes);
        title(sprintf('Matriz de Confusão - %s', nomeNovaRede));
        saveas(h, fullfile(pastaResultados, sprintf('conf_matrix_%s.png', nomeNovaRede)));
        close(h);
        
        % Plot da curva de treino
        h = figure;
        plotperform(tr);
        title(sprintf('Desempenho - %s', nomeNovaRede));
        saveas(h, fullfile(pastaResultados, sprintf('performance_%s.png', nomeNovaRede)));
        close(h);
    end
end

writetable(resultados, fullfile(pastaResultados, 'resultados_estudo_ii.csv'));

fprintf('Total de redes avaliadas: %d\n', height(resultados));

% Calcular médias das precisões
mediaPrecisaoStart = mean(resultados.PrecisaoStart);
mediaPrecisaoTrain = mean(resultados.PrecisaoTrain);
mediaPrecisaoTest = mean(resultados.PrecisaoTest);

fprintf('Precisão média - pasta start: %.2f%%\n', mediaPrecisaoStart);
fprintf('Precisão média - pasta train: %.2f%%\n', mediaPrecisaoTrain);
fprintf('Precisão média - pasta test: %.2f%%\n', mediaPrecisaoTest);

tempoTotal = toc(tempoInicioScript);
fprintf('\nTempo total de execução: %.2f minutos\n', tempoTotal / 60);
