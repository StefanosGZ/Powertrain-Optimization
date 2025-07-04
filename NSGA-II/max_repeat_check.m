function doesnt_repeat = max_repeat_check(layout, max_repeat)
    % Create a cell array to store the unique elements and their counts
    uniqueItems = unique(layout);
    
    % Initialize the output variable
    doesnt_repeat = true;
    
    % Check if more than one "GEN" in layout
    GENCount = sum(strcmp(layout, 'GEN'));
    if GENCount > 1
        doesnt_repeat = false;
        return; % Early exit if more than one "GEN" is found
    end

    % Loop through each unique item and count its occurrences in the layout
    for i = 1:length(uniqueItems)
        itemCount = sum(strcmp(layout, uniqueItems{i}));
        if itemCount > max_repeat
            doesnt_repeat = false; % Early exit if more same items than allowed
            break;
        end
    end
end
