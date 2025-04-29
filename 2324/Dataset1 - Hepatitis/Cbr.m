%Ler o dataset TRAIN já adaptado no excel
train = readtable('Train.csv', 'Delimiter', ';');

%Loop sobre todas as linhas
for i = 1:size(train, 1)

    %Verificar se há valores em falta (NA) em cada linha
    if any(ismissing(train{i, :}))
        %Extrair o caso com valores em falta
        missing_case = train(i, :);
        threshold = 0.75;
        
        %Preencher os valores em falta usando a função Retrieve
        [retrieved_indexes, similarities, filled_case, retrieved_cases] = Retrieve(train, missing_case, threshold);
        
        %Verificar se há casos recuperados
        if ~isempty(retrieved_indexes)
            %Ordenar os casos recuperados com base na similaridade
            [sorted_similarities, idx] = sort(similarities, 'descend');
            sorted_retrieved_cases = retrieved_cases(idx, :);
            
            %Selecionar o caso mais semelhante
            caso_mais_semelhante = sorted_retrieved_cases(1, :);
            
            %Preencher os valores em falta na linha correspondente do conjunto de dados
            for j = 1:width(train)
                %Verificar se o valor na linha é faltante
                if ismissing(train{i, j})
                    %Substituir o valor faltante pelo valor do caso mais semelhante
                    train{i, j} = caso_mais_semelhante{1, j};
                    
                    %Mostrar informações sobre os casos preenchidos
                    fprintf("Caso mais semelhante com uma similaridade de %.2f%%:\n", sorted_similarities(1)*100);
                    disp(caso_mais_semelhante);
                    break; %Interrompe o loop interno após preencher um valor em falta
                end
            end
        else
            disp(['Não foi possível encontrar um caso semelhante para preencher NA na linha ', num2str(i)]);
        end
    end
end



%Salvar a tabela atualizada de volta no arquivo CSV
writetable(train, 'TrainAdaptado.csv', 'Delimiter', ';');