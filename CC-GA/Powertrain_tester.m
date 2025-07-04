function [MAE, E_total, E_specific, cost, emissions, fig] = Powertrain_tester(layout_model, DriveCycle)
%% This Function tests a powertrain model on a given drive cycle, and outputs mean absolute error, and total and specific fuel and battery energy consumption.
    %% Simulation
    tend = num2str(DriveCycle(end,1));
    set_param(layout_model, 'StopTime', tend);
    
    testing_sim = sim(layout_model);
    time_steps = testing_sim.tout;
    ref_speed = testing_sim.ref_speed.data;
    actual_speed = testing_sim.actual_speed.data;
    distance = 0.001*trapz(time_steps, actual_speed/3.6);

    %% Absolute Error
    abs_error = abs(ref_speed - actual_speed);
    MAE = mean(abs_error(isfinite(abs_error)));

    %% Symmetric Mean Absolute Percentage Error (SMAPE)
    % smape_raw = (abs_error./(abs(actual_speed) + abs(ref_speed)))*(100/length(time_steps));
    % smape_filtered = smape_raw(isfinite(smape_raw));
    % SMAPE = mean(smape_filtered);

    %% Integrated Absolute Error (IAE)
    %IAE = trapz(time_steps, abs_error);

    %% Energy Consumption 
    E_bat = find(testing_sim,'E_b');
    E_fuel = find(testing_sim,'E_f');
    if isempty(E_bat)
        E_total = E_fuel.data(end);
        co2 = 3.3; % 3.3 kgCO2/kg
    else 
        E_total = E_bat.data(end); 
        co2 = 0; % no CO2 with battery
    end 
    E_specific = E_total/distance;
    %% Cost & Emissions
    % 46*10^6 J/kg is the fuel energy density
    % 3.3 kg of CO2 per kg of fuel is the emission rate
    % 1 Wh = 3600 J
    % Average life of a vehicle assumed to be 250,000 km
    % J/km * 3600 J/Wh * 3.3 kgCO2/kg * 250,000 km / 46*10^6 J/kg 
    running_emissions = (E_specific*co2*3600*250000)/(46*10^6);
    cost = 0;
    base_emissions = 0;
   
    powertrain_components = find_system(layout_model, 'Mask', 'on');
    for i = 1:length(powertrain_components)
        attr_vector = eval(get_param(powertrain_components{i}, 'attribute_vector'));
        if ~strcmp(attr_vector{1},'CONTROLLER')
            cost = (cost + str2double(get_param(powertrain_components{i}, 'cost')));
            base_emissions = base_emissions + str2double(get_param(powertrain_components{i}, 'base_emissions'));        
        end 
    end
    
    emissions = (running_emissions + base_emissions)/1000; % Tons of CO2
    
    %% Plotting
    fig = figure('Visible', 'off');
  
    plot(time_steps, ref_speed, 'b', 'DisplayName', 'Reference');
    hold on;
    plot(time_steps, actual_speed, 'r', 'DisplayName', 'Actual');
    xlabel('Time');
    ylabel('Speed (km/h)');
end
