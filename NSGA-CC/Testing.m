function layout_model = Testing(layout_model, offspring)
% APPLYOFFSPRINGPARAMETERS Assigns predefined parameters to the blocks in a Simulink model.
%
%   layout_model = applyOffspringParameters(layout_model, offspring)
%
%   This function applies the parameters provided in offspring.params to the
%   corresponding blocks in the Simulink model. The order of assignment is defined
%   by offspring.layout (e.g. {'BAT','MOT','GEN','MOT','VEH'}).
%
%   Inputs:
%       layout_model - Simulink model name or handle containing the layout.
%       offspring    - Struct with two fields:
%                         .layout: 1xN cell array of component type abbreviations.
%                         .params: 1xN cell array of parameter sets.
%
%   Output:
%       layout_model - The updated Simulink model with parameters assigned.
%
%   Example usage:
%       offspring.layout = {'BAT', 'MOT', 'GEN', 'MOT', 'VEH'};
%       offspring.params = {BAT_params, MOT_params1, GEN_params, MOT_params2, {Env_params, VEH_params}};
%       model = 'MySimulinkModel';
%       model = applyOffspringParameters(model, offspring);

% Get all blocks in the model (excluding the model itself)
blocks = find_system(layout_model, 'Type', 'Block');
blocks(strcmp(blocks, layout_model)) = [];  % Remove the top-level model block

% Sort blocks from left to right based on their x-coordinate position
positions = cellfun(@(b) get_param(b, 'Position'), blocks, 'UniformOutput', false);
xCoords = cellfun(@(pos) pos(1), positions);
[~, sortIdx] = sort(xCoords);
blocks = blocks(sortIdx);

% Check that the number of blocks matches the length of the offspring layout
if length(blocks) ~= length(offspring.layout)
    error('Mismatch between number of blocks (%d) and offspring layout (%d).', ...
          length(blocks), length(offspring.layout));
end

% Loop through each component in the offspring layout and assign its parameters
for i = 1:length(offspring.layout)
    compType = offspring.layout{i};
    paramSet = offspring.params{i};
    currentBlock = blocks{i};
    
    switch compType
        case 'BAT'
            % Battery block: expected paramSet = {V_bat_nom, mAh_bat_rated, cost, base_emissions}
            set_param(currentBlock, 'V_bat_nom', num2str(paramSet{1}), ...
                'mAh_bat_rated', num2str(paramSet{2}), ...
                'cost', num2str(paramSet{3}), ...
                'base_emissions', num2str(paramSet{4}));
            
        case 'GEN'
            % Generator block: expected paramSet = {V_bat_nom, mAh_bat_rated, cost, base_emissions}
            set_param(currentBlock, 'V_bat_nom', num2str(paramSet{1}), ...
                'mAh_bat_rated', num2str(paramSet{2}), ...
                'cost', num2str(paramSet{3}), ...
                'base_emissions', num2str(paramSet{4}));
            
        case 'GB'
            % Gearbox block: expected paramSet = {G, cost, base_emissions}
            set_param(currentBlock, 'G', num2str(paramSet{1}), ...
                'cost', num2str(paramSet{2}), ...
                'base_emissions', num2str(paramSet{3}));
            
        case 'ICE'
            % IC Engine block: expected paramSet = {T_p, P_p, w_T, w_P, w_ice_max, cost, base_emissions}
            set_param(currentBlock, 'T_p', num2str(paramSet{1}), ...
                'P_p', num2str(paramSet{2}), ...
                'w_T', num2str(paramSet{3}), ...
                'w_P', num2str(paramSet{4}), ...
                'w_ice_max', num2str(paramSet{5}), ...
                'cost', num2str(paramSet{6}), ...
                'base_emissions', num2str(paramSet{7}));
            
        case 'MOT'
            % Motor block: expected paramSet = {T_mot_max, P_mot_max, cost, base_emissions}
            set_param(currentBlock, 'T_mot_max', num2str(paramSet{1}), ...
                'P_mot_max', num2str(paramSet{2}), ...
                'cost', num2str(paramSet{3}), ...
                'base_emissions', num2str(paramSet{4}));
            
        case 'VEH'
            % Vehicle block: expected paramSet is a cell array with two sets:
            %   {Env_params, VEH_params}
            % Env_params: {mu_rr, rho, g}
            % VEH_params: {m, r, A, C_D, cost, base_emissions}
            env_par = paramSet{1};
            veh_par = paramSet{2};
            set_param(currentBlock, 'm', num2str(veh_par{1}), ...
                'r', num2str(veh_par{2}), ...
                'A', num2str(veh_par{3}), ...
                'C_D', num2str(veh_par{4}), ...
                'cost', num2str(veh_par{5}), ...
                'base_emissions', num2str(veh_par{6}), ...
                'mu_rr', num2str(env_par{1}), ...
                'rho', num2str(env_par{2}), ...
                'g', num2str(env_par{3}));
            
        case 'FT'
            % Fuel Tank block: No parameter assignment defined.
            % (Add set_param calls here if needed.)
            
        case 'TR'
            % Transmission block: No parameter assignment defined.
            % (Add set_param calls here if needed.)
            
        otherwise
            warning('Unknown component type "%s" at index %d.', compType, i);
    end
end

end
