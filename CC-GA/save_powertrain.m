function [powertrains, stored_powertrains] = save_powertrain(powertrains, stored_powertrains, results, layout)

    % Save the results
    % Update the number of stored powertrains
    stored_powertrains = stored_powertrains + 1

    % Save the results structure into the powertrains array
    powertrains(stored_powertrains).results = results;
    powertrains(stored_powertrains).layout = layout;

% model_name = sprintf('Powertrain_%d', stored_powertrains);
% if isfile(model_name)
%     % Delete the existing model file
%     delete(model_name);
% end
% save_system(results.layout_model, model_name);
end
