% Parâmetros básicos
pathBase = '../datasets/train/';
classes = {'circle', 'kite', 'parallelogram', 'square', 'trapezoid', 'triangle'};
imgSize = [64 64];
[X, Y] = carregarImagens(pathBase, classes, imgSize);  % usa a mesma função da alínea a)

% Configurações a testar
topologias = {[10], [20], [20 10], [30 20 10]};
funcoesAtiv = {'logsig', 'radbas'};
funcoesTreino = {'trainrp', 'trainscg', 'traingdx'};

divisoes = {
    [0.7 0.15 0.15],
    [0.6 0.2 0.2],
    [0.8 0.1 0.1] };

% Guarda resultados
resultadoIndex = 1;
resultados = [];

for t = 1:length(topologias)
    for fA = 1:length(funcoesAtiv)
        for fT = 1:length(funcoesTreino)
            for d = 1:length(divisoes)
                precisaoGlobal = zeros(1, 10);
                precisaoTeste = zeros(1, 10);
                for rep = 1:10
                    fprintf('\n--- CONFIG %d | Topologia: [%s] | Ativação: %s | Treino: %s | Divisão: [%s] | Repetição %d ---\n', ...
                        resultadoIndex, num2str(topologias{t}), funcoesAtiv{fA}, ...
                        funcoesTreino{fT}, num2str(divisoes{d}), rep);

                    net = patternnet(topologias{t});
                    net.trainFcn = funcoesTreino{fT};

                    net.trainParam.showWindow = false;
                    net.trainParam.showCommandLine = false;

                    % Funções de ativação
                    for l = 1:length(net.layers)
                        net.layers{l}.transferFcn = funcoesAtiv{fA};
                    end

                    % Divisão de dados
                    net.divideParam.trainRatio = divisoes{d}(1);
                    net.divideParam.valRatio   = divisoes{d}(2);
                    net.divideParam.testRatio  = divisoes{d}(3);

                    tic;
                    [net, tr] = train(net, X, Y);
                    elapsed = toc;
                    fprintf('Treino concluído em %.2f segundos\n', elapsed);

                    outputs = net(X);
                    [~, pred] = max(outputs, [], 1);
                    [~, actual] = max(Y, [], 1);
                    precisaoGlobal(rep) = sum(pred == actual) / numel(actual) * 100;

                    % Avaliação de teste
                    testInd = tr.testInd;
                    testOutputs = outputs(:, testInd);
                    testTargets = Y(:, testInd);
                    [~, predTest] = max(testOutputs, [], 1);
                    [~, actTest] = max(testTargets, [], 1);
                    precisaoTeste(rep) = sum(predTest == actTest) / numel(actTest) * 100;
                end

                % Guardar resultados da configuração
                resultados(resultadoIndex).topologia = topologias{t};
                resultados(resultadoIndex).funcAtiv  = funcoesAtiv{fA};
                resultados(resultadoIndex).funcTreino = funcoesTreino{fT};
                resultados(resultadoIndex).divisao = divisoes{d};
                resultados(resultadoIndex).mediaGlobal = mean(precisaoGlobal);
                resultados(resultadoIndex).mediaTeste = mean(precisaoTeste);

                % Guarda as 3 melhores redes
                if mean(precisaoTeste) > 80 % critério inicial, ajustável
                    nomeRede = sprintf('rede_b%d.mat', resultadoIndex);
                    save(fullfile('../redes_gravadas', nomeRede), 'net');
                end
                resultadoIndex = resultadoIndex + 1;
            end
        end
    end
end

% Exportar para Excel
T = struct2table(resultados);
writetable(T, fullfile('../resultados_excel', 'precisao_alinea_b.xlsx'));