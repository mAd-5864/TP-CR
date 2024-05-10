function [retrieved_indexes, similarities, new_case, retrieved_cases] = Retrieve(case_library, new_case, threshold)

    weighting_factors = [5 3 4 2 5 5 5 2 1 3 4 3];  
    
    %blooddonor_type_sim = get_blooddonor_similarities();
    %transportation_sim = get_transportation_similarities();
    %accommodation_sim = get_accommodation_similarities();
    
   max_values = get_max_values(case_library);
   retrieved_indexes = [];
   retrieved_cases = [];
   similarities = [];

     for i=1:size(case_library,1)

         % Verificar se o índice atual é o mesmo do caso com valores em falta
         if ismember(new_case.ID, 1:size(case_library, 1)) && i == new_case.ID
            continue;
        end
        
        distances = zeros(1,12);
                            

        distances(1,1) = calculate_euclidean_distance(case_library.Age(i) / max_values(3), ... 
                                new_case.Age / max_values(3));

        distances(1,2) = calculate_euclidean_distance(case_library.Sex(i) / max_values(4), ... 
                                new_case.Sex / max_values(4));

        distances(1,3) = calculate_euclidean_distance(case_library.ALB(i) / max_values(5), ...
                                new_case.ALB / max_values(5));

        distances(1,4) = calculate_euclidean_distance(case_library.ALP(i) / max_values(6), ...
                                new_case.ALP / max_values(6));

        distances(1,5) = calculate_euclidean_distance(case_library.ALT(i) / max_values(7), ...
                                new_case.ALT / max_values(7));

        distances(1,6) = calculate_euclidean_distance(case_library.AST(i) / max_values(8), ...
                                new_case.AST / max_values(8));

        distances(1,7) = calculate_euclidean_distance(case_library.BIL(i) / max_values(9), ...
                                new_case.BIL / max_values(9));

        distances(1,8) = calculate_euclidean_distance(case_library.CHE(i) / max_values(10), ...
                                new_case.CHE / max_values(10));

        distances(1,9) = calculate_euclidean_distance(case_library.CHOL(i) / max_values(11), ...
                                new_case.CHOL / max_values(11));

        distances(1,10) = calculate_euclidean_distance(case_library.CREA(i) / max_values(12), ...
                                new_case.CREA / max_values(12));

        distances(1,11) = calculate_euclidean_distance(case_library.GGT(i) / max_values(13), ...
                                new_case.GGT / max_values(13));

        distances(1,12) = calculate_euclidean_distance(case_library.PROT(i) / max_values(14), ...
                                new_case.PROT / max_values(14));

                            
        DG = (distances * weighting_factors') / sum(weighting_factors);
        final_similarity = 1 - DG;
        
        if final_similarity >= threshold
            retrieved_indexes = [retrieved_indexes i];
            retrieved_cases = [retrieved_cases; case_library(i, :)];
            similarities = [similarities final_similarity];
            fprintf('Case %d out of %d has a similarity of %.2f%%...\n', i, size(case_library,1), final_similarity*100);
        end
     end


end


function [res] = calculate_euclidean_distance(val1, val2)

    res = sqrt((val1 - val2)^2);
end

function max_values = get_max_values(case_library)
    % Inicialize o vetor de valores máximos
    max_values = zeros(1, width(case_library));
    
    % Iterar sobre cada coluna do case_library
    for i = 1:width(case_library)
        % Obter o valor máximo da coluna atual
        max_values(i) = max(case_library{:, i}, [], 'omitnan');
    end
end