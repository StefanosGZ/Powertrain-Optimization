% This function is used for performing the non dominated sorting and
% crowding distance.
function pop = NDS_n_CD(powertrains)
    % Step 1: Convert powertrains data to the population structure expected by NonDominatedSorting
    num_powertrains = sum(~cellfun(@isempty, {powertrains.layout}));
    pop = struct();  % Initialize an empty population structure
    
    for i = 1:num_powertrains
        % Assuming the NonDominatedSorting function expects a field 'Cost' for objective values
        pop(i).Cost = powertrains(i).layout.layout_fitness;
        pop(i).DominationSet = [];  % Placeholder, the sorting function likely fills this in
        pop(i).DominatedCount = 0;
        pop(i).Rank = 0;
        pop(i).CrowdingDistance = 0;  % Initialize crowding distance to 0
    end
    [pop, MaxFNo] = NonDominatedSorting(pop);
    pop = CalcCrowdingDistance(pop, MaxFNo);
end
