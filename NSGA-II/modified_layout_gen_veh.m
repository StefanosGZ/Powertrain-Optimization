function layout = modified_layout_gen_veh(library, layout)
% This function starts from Vehicle block only


% This function generates a random powertrain layout.
% Arguments:
% - library: A structure containing components, names of actuators and loads, and connection types.
% Returns:
% - layout: A random "linear" powertrain layout with at least one load block and an actuator.



% Determining number of connections of each item
connections = cellfun(@numel, library.conn_type);
n = numel(library.library);

% Check if layout is given (Only in mutation)
if nargin == 1
    % Initialization
    %layout.layout = {};
    %layout.layout_conn_type = {};
    %layout.layout_conn_dir = {};
    %layout.layout_fitness = [];
    layout.layout = {'VEH'};
    layout.layout_conn_type = {{'MECH'}};
    layout.layout_conn_dir = {{'IN'}};
    layout.layout_fitness = [];
end



% Find the index of 'VEH' in library.library
%load_indices = find(ismember({'VEH'},library.library))

% Randomly select an index from the load_indices
%i = load_indices(randi(length(load_indices)))

% Initialize layout with the selected item
%i = randi(n);
%layout.layout = {library.library{i}};
%layout.layout_conn_type = {library.conn_type{i}};
%layout.layout_conn_dir = {library.conn_dir{i}};
global max_repeat % Maximum times a component is repeated in a layout (not necessarily consecutively)

while true % Looping for item placement   
    k = 1; % Leftmost element in sequence (i.e., current element being considered)
    conn_old = layout.layout_conn_dir{k}{1};
    %conn_type_old = layout.layout_conn_type{k}{1};
    while true % Looping for connection component 
        j = randi(n); % Random index
        %disp(library.library{j});
        while strcmp(library.library{j}, "GEN") && ismember("GEN", layout.layout)
            j = randi(n);
        end

        if sum(ismember(layout.layout, library.library{j})) <= max_repeat - 1 
            % Check if left connection of new item is compatible with left one of old. If so, flip it and add it to left.
            conn_new = library.conn_dir{j}{1};
            %conn_type_new = library.conn_type{j}{1}
            if strcmp(library.conn_type{j}{1}, layout.layout_conn_type{k}{1})
                if direction_validity(conn_new, conn_old)
                    layout.layout_conn_dir = [{flip(library.conn_dir{j})}, layout.layout_conn_dir];
                    layout.layout_conn_type = [{flip(library.conn_type{j})}, layout.layout_conn_type];
                    layout.layout = [library.library{j}, layout.layout];
                    %sum(ismember(layout.layout, library.library{j}))
                    %disp(layout.layout)
                    %disp(layout.layout_conn_type{1})
                    %disp(layout.layout_conn_dir{1})
                    break;
                end 
            end 
            % Check if right connection of new item (if it has 2 connections) is compatible with left one of old. If so, add it to left.
            if length(library.conn_type{j}) == 2
                conn_new = library.conn_dir{j}{2};
                %conn_type_new = library.conn_type{j}{2}
                if strcmp(library.conn_type{j}{2}, layout.layout_conn_type{k}{1})  
                    if direction_validity(conn_new, conn_old)
                        layout.layout_conn_dir = [{library.conn_dir{j}}, layout.layout_conn_dir];
                        layout.layout_conn_type = [{library.conn_type{j}}, layout.layout_conn_type];
                        layout.layout = [library.library{j}, layout.layout];
                        %sum(ismember(layout.layout, library.library{j}))
                        %disp(layout.layout)
                        %disp(layout.layout_conn_type{1})
                        %disp(layout.layout_conn_dir{1})
                        break;
                    end 
                end 
            end 
        end 
    end % Loop otherwise, come up with new index
    if connections(j) == 1
        break; % Stop adding if the last added item has 1 connection
    end 
end

%disp(layout.layout)
end 