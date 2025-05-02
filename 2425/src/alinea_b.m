tempoInicioScript = tic;

% Parâmetros básicos
pathBase = '../datasets/train/';
classes = {'circle', 'kite', 'parallelogram', 'square', 'trapezoid', 'triangle'};
imgSize = [32 32];
[X, Y] = carregarImagens(pathBase, classes, imgSize);

% Normalização dos dados de entrada
X = X / 255.0;

% Configurações a testar
topologias = {[50], [75], [100, 50], [100, 100]};
funcoesAtiv = {'logsig', 'poslin'};
funcoesTreino = {'trainrp', 'trainscg', 'traingdx'};

divisoes = {
    [0.7 0.15 0.15],
    [0.5 0.25 0.25],
    [0.8 0.1 0.1] };

% Guarda resultados
resultadoIndex = 1;
resultados = [];

if ~exist('../redes_gravadas', 'dir')
    mkdir('../redes_gravadas');
end
if ~exist('../resultados_excel', 'dir')
    mkdir('../resultados_excel');
end

melhoresRedes = struct('indice', [], 'precisao', [], 'net', []);
for i = 1:3
    melhoresRedes(i).precisao = 0;
end

fprintf('A treinar redes neuronais...\n');
for t = 1:length(topologias)
    for fA = 1:length(funcoesAtiv)
        for fT = 1:length(funcoesTreino)
            for d = 1:length(divisoes)
                precisaoGlobal = zeros(1, 10);
                precisaoTeste = zeros(1, 10);
                tempoTotal = 0;

                for rep = 1:10
                    if rep == 1
                        clear net tr;
                    end

                    net = patternnet(topologias{t});
                    net.trainFcn = funcoesTreino{fT};

                    net.trainParam.showWindow = false;
                    net.trainParam.showCommandLine = false;
                    net.trainParam.epochs = 300;

                    if strcmp(funcoesTreino{fT}, 'traingdx')
                        net.trainParam.lr = 0.01;      % Menor taxa de aprendizado
                        net.trainParam.mc = 0.9;       % Momentum para ajudar a sair de mínimos locais
                        net.trainParam.max_fail = 15;  % Mais paciência antes de early stopping
                    end

                    % Funções de ativação
                    for l = 1:length(net.layers) - 1
                        net.layers{l}.transferFcn = funcoesAtiv{fA}; % Camadas ocultas
                    end
                    net.layers{end}.transferFcn = 'softmax'; % Camada de saída

                    % Divisão de dados
                    net.divideParam.trainRatio = divisoes{d}(1);
                    net.divideParam.valRatio   = divisoes{d}(2);
                    net.divideParam.testRatio  = divisoes{d}(3);

                    net.performParam.regularization = 0.01;


                    try
                        tic;
                        [net, tr] = train(net, X, Y);
                        tempoRep = toc;
                        tempoTotal = tempoTotal + tempoRep;

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
                    catch ME
                        fprintf('Erro na repetição %d:\n%s\n', rep, getReport(ME));
                        precisaoGlobal(rep) = 0;
                        precisaoTeste(rep) = 0;
                        tempoRep = 0;
                    end
                fprintf('.');
                end

                % Calcula médias
                validGlobal = precisaoGlobal(precisaoGlobal > 0);
                validTeste = precisaoTeste(precisaoTeste > 0);
                if isempty(validGlobal), validGlobal = 0; end
                if isempty(validTeste), validTeste = 0; end

                mediaGlobal = mean(validGlobal);
                mediaTeste = mean(validTeste);
                tempoMedio = tempoTotal / 10;

                fprintf('\n--- CONFIG %d | Topologia: [%s] | Ativação: %s | Treino: %s | Divisão: [%s] ---\n', ...
                    resultadoIndex, num2str(topologias{t}), funcoesAtiv{fA}, ...
                    funcoesTreino{fT}, num2str(divisoes{d}));
                fprintf('Precisão Global Média: %.2f%% | Precisão Teste Média: %.2f%% | Tempo Médio: %.2f segundos\n', ...
                    mediaGlobal, mediaTeste, tempoMedio);

                % Guardar resultados da configuração
                resultados(resultadoIndex).topologia = topologias{t};
                resultados(resultadoIndex).funcAtiv = funcoesAtiv{fA};
                resultados(resultadoIndex).funcTreino = funcoesTreino{fT};
                resultados(resultadoIndex).divisao = divisoes{d};
                resultados(resultadoIndex).mediaGlobal = mediaGlobal;
                resultados(resultadoIndex).mediaTeste = mediaTeste;
                resultados(resultadoIndex).tempoMedio = tempoMedio;

                % Verificar se esta rede está entre as 3 melhores
                if mediaTeste > 0 && (mediaTeste > min([melhoresRedes.precisao]))
                    [~, piorIndice] = min([melhoresRedes.precisao]);

                    % Substituir pela rede atual
                    melhoresRedes(piorIndice).indice = resultadoIndex;
                    melhoresRedes(piorIndice).precisao = mediaTeste;
                    melhoresRedes(piorIndice).net = net;
                end

                resultadoIndex = resultadoIndex + 1;
            end
            % Limpar memória entre configs
            clear net tr;

        end
    end
end

% Ordenar as 3 melhores redes por precisão
precisoes = [melhoresRedes.precisao];
[~, indOrdem] = sort(precisoes, 'descend');
melhoresRedes = melhoresRedes(indOrdem);

fprintf('\n===================================\n');
fprintf('TOP 3 MELHORES CONFIGURAÇÕES:\n');
for i = 1:length(melhoresRedes)
    idx = melhoresRedes(i).indice;
    if idx > 0
        fprintf('\n%d. Precisão Teste: %.2f%%\n', i, resultados(idx).mediaTeste);
        fprintf('   Topologia: [%s] | Ativação: %s | Treino: %s | Divisão: [%s]\n', ...
            num2str(resultados(idx).topologia), resultados(idx).funcAtiv, ...
            resultados(idx).funcTreino, num2str(resultados(idx).divisao));

        net = melhoresRedes(i).net;
        nomeFicheiroFinal = sprintf('rede_melhor_%d.mat', i);
        save(fullfile('../redes_gravadas/teste3', nomeFicheiroFinal), 'net');

        resultados(idx).nomeFicheiroFinal = nomeFicheiroFinal;
    end
end

% Exportar para Excel
T = struct2table(resultados);
writetable(T, fullfile('../resultados_excel', 'precisao_alinea_b_teste_3.xlsx'));

tempoTotalScript = toc(tempoInicioScript);
fprintf('\n===================================\n');
fprintf('TEMPO TOTAL DE EXECUÇÃO: %.2f min\n', tempoTotalScript/60);