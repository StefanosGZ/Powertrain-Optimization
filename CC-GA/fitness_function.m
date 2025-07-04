function fitness = fitness_function(results, max_MAE, max_E_specific, max_cost, max_emissions)
    % Weights for different components of the fitness function
    weight_MAE = 0.1;
    weight_E_specific = 0.3;
    weight_cost = 0.3;
    weight_emissions = 0.3;

    % Normalization
    normalized_MAE = results.MAE / max_MAE;
    normalized_E_specific = results.E_specific / max_E_specific;
    normalized_cost = results.cost / max_cost;
    normalized_emissions = results.emissions / max_emissions;

    % Calculation of fitness
    fitness = weight_MAE * normalized_MAE...
              + weight_E_specific * normalized_E_specific...
              + weight_cost * normalized_cost...
              + weight_emissions * normalized_emissions;
end
