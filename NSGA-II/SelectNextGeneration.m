function [new_powertrains, new_pop] = SelectNextGeneration(powertrains, pop, N)
    % SelectNextGeneration selects the next generation of powertrains based on NSGA-II criteria.
    %
    % Inputs:
    %   - powertrains: Struct array containing the current population.
    %   - pop: Struct array containing the rank and crowding distance for each individual.
    %   - N: Desired population size for the next generation.
    %
    % Output:
    %   - new_powertrains: Struct array containing the selected individuals for the next generation.

    % Initialize an empty array to store selected indices
    selected_indices = [];
    count = 0;  % Counter for the number of selected individuals

    % Get the maximum rank present in the population
    max_rank = max([pop.Rank]);

    % Iterate through each rank (Pareto front) starting from the best (rank 1)
    for rank = 1:max_rank
        % Find the indices of individuals in the current rank
        current_front = find([pop.Rank] == rank);
        
        % Number of individuals in the current front
        front_size = length(current_front);
        
        % Check if adding the entire front exceeds the desired population size
        if count + front_size <= N
            % Add all individuals from the current front
            selected_indices = [selected_indices, current_front];
            count = count + front_size;
        else
            % Calculate how many more individuals are needed
            remaining_slots = N - count;
            
            % Extract crowding distances of individuals in the current front
            crowding_distances = [pop(current_front).CrowdingDistance];
            
            % Sort the current front based on crowding distance in descending order
            [~, sorted_order] = sort(crowding_distances, 'descend');
            sorted_front = current_front(sorted_order);
            
            % Select the top individuals based on remaining slots
            selected_indices = [selected_indices, sorted_front(1:remaining_slots)];
            count = count + remaining_slots;
            break;  % The population is now full
        end
    end

    % Select the individuals from powertrains based on the selected indices
    new_powertrains = powertrains(selected_indices);
    new_pop = pop(selected_indices);
end
