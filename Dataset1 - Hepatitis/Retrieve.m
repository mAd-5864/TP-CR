function [retrieved_indexes, similarities, new_case, retrieved_cases] = Retrieve(case_library, new_case, threshold)

    %Pesos de cada atributo da tabela
    pesos = [5 3 4 2 5 5 5 2 1 3 4 3];  
    
    %Calcular os valores máximos para normalização
    max_values = get_max_values(case_library);
    
    %Inicializar as variáveis de saída
    retrieved_indexes = [];
    retrieved_cases = [];
    similarities = [];

    %Iterar sobre todos os casos na biblioteca de casos
    for i = 1:size(case_library, 1)
        
        %Verificar se o caso atual é o mesmo que o novo caso
        if ismember(new_case.ID, 1:size(case_library, 1)) && i == new_case.ID
            continue; %Ignorar o caso atual se for o novo caso
        end
        
        %Inicializar um vetor para armazenar as distâncias entre os atributos
        distancias = zeros(1, 12);
                            
        %Calcular a distância euclidiana para cada atributo
        distancias(1,1) = distancia_euclidiana(case_library.Age(i) / max_values(3), ... 
                                new_case.Age / max_values(3));

        distancias(1,2) = distancia_euclidiana(case_library.Sex(i) / max_values(4), ... 
                                new_case.Sex / max_values(4));

        distancias(1,3) = distancia_euclidiana(case_library.ALB(i) / max_values(5), ...
                                new_case.ALB / max_values(5));

        distancias(1,4) = distancia_euclidiana(case_library.ALP(i) / max_values(6), ...
                                new_case.ALP / max_values(6));

        distancias(1,5) = distancia_euclidiana(case_library.ALT(i) / max_values(7), ...
                                new_case.ALT / max_values(7));

        distancias(1,6) = distancia_euclidiana(case_library.AST(i) / max_values(8), ...
                                new_case.AST / max_values(8));

        distancias(1,7) = distancia_euclidiana(case_library.BIL(i) / max_values(9), ...
                                new_case.BIL / max_values(9));

        distancias(1,8) = distancia_euclidiana(case_library.CHE(i) / max_values(10), ...
                                new_case.CHE / max_values(10));

        distancias(1,9) = distancia_euclidiana(case_library.CHOL(i) / max_values(11), ...
                                new_case.CHOL / max_values(11));

        distancias(1,10) = distancia_euclidiana(case_library.CREA(i) / max_values(12), ...
                                new_case.CREA / max_values(12));

        distancias(1,11) = distancia_euclidiana(case_library.GGT(i) / max_values(13), ...
                                new_case.GGT / max_values(13));

        distancias(1,12) = distancia_euclidiana(case_library.PROT(i) / max_values(14), ...
                                new_case.PROT / max_values(14));

                            
        %Calcular a distância geral considerando os pesos
        distancia_geral = ((distancias * pesos') / sum(pesos));
        %Calcular a similaridade final
        similaridade_final = 1 - distancia_geral;
        
        %Verificar se a similaridade atende ao limiar especificado
        if similaridade_final >= threshold
            %Se sim, adicionar o índice do caso e a similaridade aos resultados
            retrieved_indexes = [retrieved_indexes i];
            retrieved_cases = [retrieved_cases; case_library(i, :)];
            similarities = [similarities similaridade_final];
        end
    end
end

%Função para calcular a distância euclidiana entre dois valores
function [res] = distancia_euclidiana(val1, val2)
    res = sqrt((val1 - val2)^2);
end

%Função para obter os valores máximos de cada coluna na biblioteca de casos
function max_values = get_max_values(case_library)
    %Inicialize o vetor de valores máximos
    max_values = zeros(1, width(case_library));
    
    %Iterar sobre cada coluna do case_library
    for i = 1:width(case_library)
        %Obter o valor máximo da coluna atual
        max_values(i) = max(case_library{:, i}, [], 'omitnan');
    end
end
