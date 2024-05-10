% Ler o dataset TRAIN já adaptado
train = readtable('TrainAdaptado.csv', 'Delimiter', ';');

% Loop sobre todas as linhas
for i = 1:size(train, 1)
    % Exibir informações sobre o loop

    % Verificar se há valores em falta (NA) em cada linha
    if any(ismissing(train{i, :}))
        % Extrair o caso com valores em falta
        missing_case = train(i, :);
        threshold = 0.75;
        
        % Preencher os valores em falta usando a função Retrieve
        [retrieved_indexes, similarities, filled_case, retrieved_cases] = Retrieve(train, missing_case, threshold);
        
        % Verificar se há casos recuperados
        if ~isempty(retrieved_indexes)
            % Ordenar os casos recuperados com base na similaridade
            [sorted_similarities, idx] = sort(similarities, 'descend');
            sorted_retrieved_cases = retrieved_cases(idx, :);
            
            % Selecionar o caso mais semelhante
            most_similar_case = sorted_retrieved_cases(1, :);
            
            % Preencher os valores em falta na linha correspondente do conjunto de dados
            for j = 1:width(train)
                % Verificar se o valor na linha é faltante
                if ismissing(train{i, j})
                    % Substituir o valor faltante pelo valor do caso mais semelhante
                    train{i, j} = most_similar_case{1, j};
                end
            end
            
            % Exibir informações sobre os casos preenchidos
            disp(['Preenchido NA na linha ', num2str(i)]);
            disp('Caso mais semelhante:');
            disp(most_similar_case);
        else
            disp(['Não foi possível encontrar um caso semelhante para preencher NA na linha ', num2str(i)]);
        end
    end
end

% Salvar a tabela atualizada de volta no arquivo CSV
writetable(train, 'TrainAdaptado.csv', 'Delimiter', ';');