pathBase = '../datasets/start/';
classes = {'circle', 'kite', 'parallelogram', 'square', 'trapezoid', 'triangle'};
numClasses = numel(classes);

X = [];
Y = [];
totalImgs = 0;

for i = 1:numClasses
    folder = fullfile(pathBase, classes{i});
    if ~isfolder(folder)
        warning('Pasta não encontrada: %s', folder);
        continue;
    end
    imgs = dir(fullfile(folder, '*.png')); % corrigido
    fprintf('%s: %d imagens encontradas\n', classes{i}, length(imgs));
    
    for j = 1:length(imgs)
        imgPath = fullfile(folder, imgs(j).name);
        img = imread(imgPath);
        img = imbinarize(rgb2gray(img));                % binarização
        img = imresize(img, [64 64]);                   % garante mesmo tamanho
        X = [X, double(img(:))];                        % colunas
        Y = [Y, double(full(ind2vec(i, numClasses)))];  % one-hot
        totalImgs = totalImgs + 1;
    end
end

fprintf('Total de imagens processadas: %d\n', totalImgs);
if totalImgs == 0
    error('Nenhuma imagem foi processada');
end

% Repetições para média
precisoes = zeros(1,10);
for k = 1:10
    net = patternnet(10); % 1 camada com 10 neurónios
    net.divideParam.trainRatio = 1.0;
    net.divideParam.valRatio   = 0.0;
    net.divideParam.testRatio  = 0.0;
    [net, tr] = train(net, X, Y);
    outputs = net(X);
    [~, predicted] = max(outputs, [], 1);
    [~, actual] = max(Y, [], 1);
    accuracy = sum(predicted == actual) / numel(actual) * 100;
    precisoes(k) = accuracy;
end

mediaPrecisao = mean(precisoes);
fprintf('Média da precisão após 10 execuções: %.2f%%\n', mediaPrecisao);
