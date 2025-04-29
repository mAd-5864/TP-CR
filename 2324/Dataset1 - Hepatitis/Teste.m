% function Teste()

    % Carregar as melhores redes
    load('melhores_redes.mat', 'melhores_redes');

    try
        S = readmatrix('Test.csv', 'Delimiter', ';', 'DecimalSeparator', '.');
    catch
        error('Erro ao carregar o arquivo CSV. Verifique o caminho e a formatação.');
    end

    % Obter os valores de entrada (input)
    input = S(:, 3:end)';

    % Obter os valores do alvo (target)
    target = S(:, 2)'

    % Inicializar matriz para armazenar as métricas de acerto
    acertos = zeros(length(melhores_redes), 1);

    % Testar cada uma das melhores redes
    for i = 1:length(melhores_redes)
        % Simular a rede com o conjunto de dados de teste
        y = melhores_redes{i}.rede(input);
        
        % Calcular o erro da rede
        erro = perform(melhores_redes{i}.rede, target, y);
        
        % Converter os valores de saída para classes (0 ou 1)
        y_class = round(y)
        
        % Calcular a métrica de acerto
        acertos(i) = sum(y_class == target)/ length(target) * 100;
    end

    % Exibir as métricas de acerto
    disp('Métricas de acerto das melhores redes:');
    disp(acertos);
% end
