% Diretório principal com subpastas por forma
pasta = 'start';
categories = dir(pasta);
categories = categories([categories.isdir] & ~ismember({categories.name}, {'circle', 'kite','parallelogram', 'square', 'trapezoid', 'triangle'}));

data = [];
labels = [];

% Percorrer cada subpasta
for i = 1:length(categories)
    categoryName = categories(i).name;
    imageFiles = dir(fullfile(pasta, categoryName, '*.png'));
    
    for j = 1:length(imageFiles)
        imgPath = fullfile(imageFiles(j).folder, imageFiles(j).name);
        img = imread(imgPath);
        
        img_bin = imbinarize(img);

        data = [data; img_bin(:)']; 
        
        labels = [labels; i];
    end
end

% Transformar labels em codificação one-hot
target = full(ind2vec(labels'))';
