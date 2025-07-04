function [is_unique, simulated_powertrains] = is_unique_check(simulated_powertrains, layout)
    is_unique = true;  % assume the layout is unique initially
    for i = 1:length(simulated_powertrains)
        if isequal(simulated_powertrains{i}, layout)
            is_unique = false;
            break;
        end
    end
    
    if is_unique
        % Append the new layout since it’s unique
        simulated_powertrains{end+1} = layout;
    end
end
