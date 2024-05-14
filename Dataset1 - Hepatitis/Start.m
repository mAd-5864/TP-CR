function Start()

   %Ler o excel
   data = readmatrix('Start.csv');

    %Preparar o input e target
    input = data(:, 3:end)';
    target = data(:, 2)';


    %Definir diferentes funções de treino
    Treino = {'trains', 'traingd', 'trainbfg'};
    
    %Definir diferentes funções de ativação
    Ativacao = {'radbas', 'purelin', 'radbasn'};

    %Inicializar uma matriz para armazenar os resultados
    resultados = [];

    for f = 1:length(Ativacao)
        for g = 1:length(Treino)
            for iteration = 1:30

            %Criar rede neuronal
            net = feedforwardnet(10);
            net.divideFcn = '';

            %Timer
            tic;

            %Alterar a função de ativação e treino
            net.trainFcn = Treino{g};
            net.layers{1}.transferFcn = Ativacao{f};

            %Treinar a rede
            net.trainParam.showWindow = false;
            net = train(net, input, target);

            %Parar o Timer
            tempo_execucao = toc;

            %Simular a rede e calcular o erro
            y = net(input);
            erro = perform(net, target, y);
            precisao = (1-erro)*100;

            fprintf("\nFunçôes de Treino: %s e Ativação: %s\n", Treino{g}, Ativacao{f});
            fprintf("Erro: %f\n", erro);
            fprintf("Precisão: %.2f%%\n", precisao);
            fprintf("Tempo: %.2f seconds\n", tempo_execucao);
            
            %Adicionar os resultados à matriz
            resultados = [resultados; {Treino{g}, Ativacao{f}, erro, precisao, tempo_execucao}];

            end
        end
    end
    
    % Converter a matriz de resultados em uma tabela
    resultadosTable = cell2table(resultados, 'VariableNames', {'Função Treino', 'Função Ativação', 'Erro', 'Precisão', 'Tempo'});
    
    %Salvar a tabela em um arquivo Excel
    writetable(resultadosTable, 'melhoresStart.xlsx');

end
