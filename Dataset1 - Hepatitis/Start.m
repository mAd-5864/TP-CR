function Start()

   %Ler o excel
   data = readmatrix('Start.csv');

    %Preparar o input e target
    input = data(:, 3:end)';
    target = data(:, 2)';

    % Definir diferentes funções de treino
    trainFcns = {'trainlm', 'traingd', 'trainbfg'};
    
    % Definir diferentes funções de ativação
    transferFcns = {'radbas', 'radbasn', 'purelin'};

    for f = 1:length(transferFcns)
        for g = 1:length(trainFcns)

    %Ciclo das iterações
    for iteration = 1:30

    %Criar rede neuronal
    net = feedforwardnet(10);
    net.divideFcn = '';

    %Timer
    tic;

    %Funções de ativação e treino
    net.trainFcn = trainFcns{g};
    net.layers{1}.transferFcn = transferFcns{f};

    %Treinar a rede
    net.trainParam.showWindow = false;
    net = train(net, input, target);

    %Acaba o timer
    tempo_execucao = toc;

    %Simular a rede e ver o erro
    y = net(input);
    erro = perform(net, target, y);
    precisao = (1-erro)*100;

    fprintf("\nFunçôes de Treino: %s e Ativação: %s\n", trainFcns{g}, transferFcns{f});
    fprintf("Erro: %f\n", erro);
    fprintf("Precisão: %.2f%%\n", precisao);
    fprintf("Execution Time: %.2f seconds\n", tempo_execucao);
            end
        end
    end

    % Save the best network
    save('melhoresStart.mat','net');
end