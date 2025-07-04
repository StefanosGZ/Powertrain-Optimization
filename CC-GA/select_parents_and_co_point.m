function [parent1, parent2, idx_to_cross_over] = select_parents_and_co_point(powertrains)
    parent1 = 0;
    parent2 = 0;
    idx_to_cross_over = false;
    counter = 0;
    powertrains_length = sum(~cellfun(@isempty, {powertrains.layout}));
    while isequal(parent1, parent2) || all(~idx_to_cross_over)
        parent1 = powertrains(randi([1,powertrains_length], 1)).layout;
        parent2 = powertrains(randi([1,powertrains_length], 1)).layout;
        idx_to_cross_over = find_cross_over_point(parent1, parent2);
        if counter == 10
            idx_to_cross_over = false;
            break;
        end
        counter = counter + 1;
    end 
end

function idx_to_cross_over = find_cross_over_point(parent1, parent2)
    same_types_of_connections = same_connection_types(parent1.layout_conn_type, parent2.layout_conn_type);
    plausible_connections = connection_direction_check(same_types_of_connections, parent1.layout_conn_dir, parent2.layout_conn_dir);

    if isempty(plausible_connections)
        idx_to_cross_over = false;
        return;
    end

    random_idx = randi(size(plausible_connections,1));
    idx_to_cross_over = plausible_connections(random_idx, :);
end


function common_indices = same_connection_types(connection_type1, connection_type2)
    common_indices = [];
    for i = 2:length(connection_type1)-1
        for j = 2:length(connection_type2)-1
            if strcmp(connection_type1{i}(2), connection_type2{j}(1))
                common_indices = [common_indices; i, j];
            end
        end
    end
end



function common_connections = connection_direction_check(common_connections, connection_direction1, connection_direction2)
    for i = 1:size(common_connections, 1)
        connection = common_connections(i, :);
        if ~direction_validity(connection_direction1{connection(1)}{2}, connection_direction2{connection(2)}{1})
            common_connections(i, :) = []; % Remove the connection
            i = i - 1; % Adjust the index since the array has shrunk
        end
    end
end


