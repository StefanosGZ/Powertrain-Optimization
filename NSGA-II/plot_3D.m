function plot_3D(pop, powertrains)
    % Extract the number of data points
    numPoints = length(pop);

    % Extract the unique ranks
    ranks = [pop.Rank];  % Array of ranks for all points
    unique_ranks = unique(ranks);  % Get unique ranks
    numRanks = length(unique_ranks);  % Number of unique ranks

    % Generate colors for each unique rank using a colormap
    colors = lines(numRanks);  % Generate distinct colors for each rank

    % Create figure
    figure;
    hold on;
    xlabel('Energy Specific');
    ylabel('Cost');
    zlabel('Emissions');
    title('Dynamic 3D Scatter Plot with Ranks and Marker Shapes');
    grid on;

    % Ensure the plot is 3D
    view(3);  % Force the view to be 3D

    % Initialize an array to store scatter handles for legend
    scatter_handles = gobjects(numRanks, 1);

    % Initialize an array to store the Pareto front points
    pareto_points = [];

    % Loop to plot each point one by one, color by rank, and label with index
    for i = 1:numPoints
        % Find the rank of the current point
        rank_i = pop(i).Rank;

        % Assign color based on rank
        rank_color = colors(unique_ranks == rank_i, :);

        % Check the layout type and assign marker shape
        if ismember('GEN', powertrains(i).layout.layout)
            marker_shape = 'o';  % Circle for GEN (EVs)
        elseif ismember('ICE', powertrains(i).layout.layout)
            marker_shape = 's';  % Square for ICE (SHEVs)
        elseif ismember('MOT', powertrains(i).layout.layout)
            marker_shape = '^';  % Triangle for MOT (ICEVs)
        end

        % Scatter plot for each data point, color based on its rank and marker shape
        h = scatter3(pop(i).Cost(1), pop(i).Cost(2), pop(i).Cost(3), 100, rank_color, marker_shape, 'filled');
        
        % Label the point with its index
        text(pop(i).Cost(1), pop(i).Cost(2), pop(i).Cost(3), num2str(i), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        
        % Store handle of scatter plot corresponding to this rank
        scatter_handles(unique_ranks == rank_i) = h;

        % If the current point is on the Pareto front (Rank 1), store it
        if rank_i == 1
            pareto_points = [pareto_points; pop(i).Cost];  % Add this point to the Pareto front array
        end
    end

    % Sort the Pareto points based on the first objective (Energy Specific)
    pareto_points = sortrows(pareto_points, 1);

    % Plot the Pareto front line by connecting the Pareto front points
    pareto_line = plot3(pareto_points(:, 1), pareto_points(:, 2), pareto_points(:, 3), '-k', 'LineWidth', 2);

    % Create a legend for the ranks using the scatter handles
    legend_labels = arrayfun(@(r) sprintf('Front %d', r), unique_ranks, 'UniformOutput', false);
    legend_labels{1} = 'Front 1 (Pareto front)';  % Modify the first front to indicate Pareto front

    % Add an additional legend for the marker shapes
    % Create dummy scatter plots for the shapes with NaN values so they won't appear on the plot
    dummy_ev = scatter3(NaN, NaN, NaN, 100, 'k', 'o', 'filled');  % EVs (Circle)
    dummy_shev = scatter3(NaN, NaN, NaN, 100, 'k', 's', 'filled');  % SHEVs (Square)
    dummy_icev = scatter3(NaN, NaN, NaN, 100, 'k', '^', 'filled');  % ICEVs (Triangle)

    % Combine legends for both fronts and vehicle types, and add the Pareto line
    legend([scatter_handles; pareto_line; dummy_ev; dummy_shev; dummy_icev], ...
           [legend_labels, 'Pareto Line', {'EVs (Circle)', 'SHEVs (Square)', 'ICEVs (Triangle)'}]);

    hold off;
end
