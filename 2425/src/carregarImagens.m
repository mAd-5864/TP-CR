function [X, Y] = carregarImagens(pathBase, classes, imgSize)
    numClasses = numel(classes);
    X = [];
    Y = [];
    for i = 1:numClasses
        folder = fullfile(pathBase, classes{i});
        imgs = dir(fullfile(folder, '*.png'));
        for j = 1:length(imgs)
            imgPath = fullfile(folder, imgs(j).name);
            img = imread(imgPath);
            img = imbinarize(rgb2gray(img));
            img = imresize(img, imgSize);
            X = [X, double(img(:))];
            Y = [Y, double(full(ind2vec(i, numClasses)))];
        end
    end
end
