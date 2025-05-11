clear all; close all; clc;

% --- Definições
paths = {'../datasets/start/', '../datasets/train/', '../datasets/test/'};
names = {'start', 'train', 'test'};
classes = {'circle', 'kite', 'parallelogram', 'square', 'trapezoid', 'triangle'};
imgSize = [32 32];

% Carrega todas as imagens para treino
Xfull = []; Yfull = [];
for p = 1:length(paths)
    [Xtmp, Ytmp] = carregarImagens(paths{p}, classes, imgSize);
    Xfull = [Xfull, Xtmp];
    Yfull = [Yfull, Ytmp];
end
Xfull = Xfull / 255.0;

% Diretório das melhores redes guardadas
pastaRedes = '../redes_gravadas/estudoNNN/';
ficheirosRedes = dir(fullfile(pastaRedes, 'rede_melhor_*.mat'));

for i = 1:length(ficheirosRedes)
    dados = load(fullfile(pastaRedes, ficheirosRedes(i).name));
    net = dados.net;

    fprintf('\n======== Rede %d: %s ========\n', i, ficheirosRedes(i).name);

    % Re-treinar a rede com todos os dados
    net.divideParam.trainRatio = 1.0;
    net.divideParam.valRatio = 0.0;
    net.divideParam.testRatio = 0.0;
    net.trainParam.showWindow = false;
    [net, ~] = train(net, Xfull, Yfull);

    % Testar em cada pasta individualmente
    for p = 1:length(paths)
        [Xteste, Yteste] = carregarImagens(paths{p}, classes, imgSize);
        Xteste = Xteste / 255.0;

        outputs = net(Xteste);
        [~, pred] = max(outputs, [], 1);
        [~, actual] = max(Yteste, [], 1);
        acc = sum(pred == actual) / numel(actual) * 100;

        fprintf('Precisão com imagens da pasta "%s": %.2f%%\n', names{p}, acc);

        % Matriz de confusão
        matrizConfusao = calcularMatrizConfusao(pred, actual, length(classes));
        fig = figure;
        plotConfusionMatrix(matrizConfusao, classes);
        title(sprintf('Matriz de Confusão - %s (Rede %d)', names{p}, i));
        saveas(fig, fullfile(pastaRedes, sprintf('conf_matrix_%s_rede_%d.png', names{p}, i)));
        close(fig);

        % Guardar matriz para análise posterior (opcional)
        save(fullfile(pastaRedes, sprintf('matrizConf_%s_rede_%d.mat', names{p}, i)), 'matrizConfusao');
    end
end
