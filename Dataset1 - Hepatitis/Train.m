%function Train()
    try
        S = readmatrix('TrainAdaptado.csv', 'Delimiter', ';', 'DecimalSeparator', '.');
    catch
        error('Erro ao carregar o arquivo CSV. Verifique o caminho e a formatação.');
    end

    % Obter os valores de entrada (Input_data)
    input = S(:, 3:end)';

    % Obter os valores do alvo (Target_data)
    target = S(:, 2)';

    % Definir diferentes funções de treino
    trainFcns = {'trainscg', 'trainlm', 'trainrp'};
    
    % Definir diferentes funções de ativação
    transferFcns = {'radbas', 'tansig', 'purelin'};

    %Inicializar uma matriz para armazenar os resultados
    resultados = [];

    % Inicializar célula para armazenar as três melhores redes
    melhores_redes = cell(3, 1);

    for f = 1:length(transferFcns)
        for g = 1:length(trainFcns)
            for iteration = 1:1
            %Criar rede neuronal
            net = feedforwardnet(10);
            net.divideFcn = '';

            % Timer
            tic;

            % Alterar a função de ativação e treino
            net.trainFcn = trainFcns{g};
            net.layers{1}.transferFcn = transferFcns{f};

            % Treinar a rede
            net.trainParam.showWindow = false;
            net = train(net, input, target);

            % Parar o Timer
            tempo_execucao = toc;

            % Simular a rede e calcular o erro
            y = net(input);
            erro = perform(net, target, y);
            accuracy = (1-erro)*100;

            fprintf("\nFunçôes de Treino: %s e Ativação: %s\n", trainFcns{g}, transferFcns{f});
            fprintf("Erro: %f\n", erro);
            fprintf("Accuracy: %.2f%%\n", accuracy);
            fprintf("Execution Time: %.2f seconds\n", tempo_execucao);

            %Adicionar os resultados à matriz
            resultados = [resultados; {trainFcns{g}, transferFcns{f}, erro, accuracy, tempo_execucao}];

            % Verificar se é uma das três melhores redes
                if isempty(melhores_redes{1}) || accuracy > melhores_redes{1}.precisao
                    melhores_redes{3} = melhores_redes{2};
                    melhores_redes{2} = melhores_redes{1};
                    melhores_redes{1} = struct('rede', net, 'precisao', accuracy);
                elseif isempty(melhores_redes{2}) || accuracy > melhores_redes{2}.precisao
                    melhores_redes{3} = melhores_redes{2};
                    melhores_redes{2} = struct('rede', net, 'precisao', accuracy);
                elseif isempty(melhores_redes{3}) || accuracy > melhores_redes{3}.precisao
                    melhores_redes{3} = struct('rede', net, 'precisao', accuracy);
                end
            end
        end
    end
    
    % Guardar as três melhores redes
    save('melhores_redes.mat', 'melhores_redes');

        % Converter a matriz de resultados em uma tabela
    resultadosTable = cell2table(resultados, 'VariableNames', {'Função Treino', 'Função Ativação', 'Erro', 'Precisão', 'Tempo'});
    
    %Salvar a tabela em um arquivo Excel
    writetable(resultadosTable, 'melhoresTrain.xlsx');

%end
