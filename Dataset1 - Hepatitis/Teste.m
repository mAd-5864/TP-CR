function Teste()
    try
        S = readmatrix('Test.csv', 'Delimiter', ';', 'DecimalSeparator', '.');
    catch
        error('Erro ao carregar o arquivo CSV. Verifique o caminho e a formatação.');
    end

    % Obter os valores de entrada (Input_data)
    input = S(:, 3:end)';

    % Obter os valores do alvo (Target_data)
    target = S(:, 2)';

    % Definir diferentes funções de treino
    trainFcns = {'trainscg', 'trainbfg', 'traingd'};
    
    % Definir diferentes funções de ativação
    transferFcns = {'logsig', 'tansig', 'radbasn'};

    for f = 1:length(transferFcns)
        for g = 1:length(trainFcns)
            for iteration = 1:30
            %Criar rede neuronal
            net = feedforwardnet(20);
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
            end
        end
    end
    
    % Save the best network
    save('melhoresTest.mat','net');
end
