pathBase = 'start/';
classes = {'circle', 'kite', 'parallelogram', 'square', 'trapezoid', 'triangle'};
numClasses = numel(classes);

X = [];  % Vetores das imagens
Y = [];  % Etiquetas one-hot

totalImgs = 0;

for i = 1:numClasses
    folder = fullfile(pathBase, classes{i});
    
    if ~isfolder(folder)
        warning('Pasta não encontrada: %s', folder);
        continue;
    end

    imgs = dir(fullfile(folder, '.png'));
    fprintf('%s: %d imagens encontradas\n', classes{i}, length(imgs));
    
    for j = 1:length(imgs)
        imgPath = fullfile(folder, imgs(j).name);
        img = imread(imgPath);

        % Vetoriza e guarda
        X = [X, double(img(:))];
        Y = [Y, double(full(ind2vec(i, numClasses)))];
        
        totalImgs = totalImgs + 1;
    end
end

fprintf('Total de imagens processadas: %d\n', totalImgs);

if totalImgs == 0
    error('Nenhuma imagem foi processada');
end

net = patternnet(10);  % Uma camada oculta com 10 neurónios
[net, tr] = train(net, X, Y);

outputs = net(X);

% Avaliação de precisão
[~, predicted] = max(outputs, [], 1);
[~, actual] = max(Y, [], 1);
accuracy = sum(predicted == actual) / numel(actual) * 100;

fprintf('Precisão global: %.2f%%\n', accuracy);

% Matriz de confusão
figure;
plotconfusion(Y, outputs);
title(sprintf('Matriz de Confusão - Precisão %.2f%%', accuracy));