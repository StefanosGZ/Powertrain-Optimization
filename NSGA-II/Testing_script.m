%% Create and scale parameters structure

% Define the original parameters
parameters.Env_par   = [0.008, 1.13, 9.81];
parameters.ICE_par   = [333, 188000, 3730, 6380, 7500, 3000, 3330];
parameters.MOT_par   = [243, 131000, 3500, 2030];
parameters.GB_par    = [5.45, 950, 937];
parameters.TR_par    = [3.07, 1.77, 1.19, 0.87, 0.7];
parameters.Shift_par = [10, 30, 45, 60];
parameters.BAT_par   = [328, 140000, 4580, 8540];
parameters.GEN_par   = [343, 44000, 2650, 5150];
parameters.VEH_par   = [1470, 0.305, 2.2, 0.287, 1670, 1790];

% Define scale factor to reduce the values by 70%
scale_factor = 0.3;  % (i.e. new value = original value * 0.3)

% Scale the parameters that need to be adjusted:
% (ICE_par, MOT_par, GB_par, BAT_par, GEN_par, VEH_par)
parameters.ICE_par = parameters.ICE_par * scale_factor;
parameters.MOT_par = parameters.MOT_par * scale_factor;
parameters.GB_par  = parameters.GB_par  * scale_factor;
parameters.BAT_par = parameters.BAT_par * scale_factor;
parameters.GEN_par = parameters.GEN_par * scale_factor;
parameters.VEH_par = parameters.VEH_par * scale_factor;
parameters.TR_par = parameters.TR_par * scale_factor;
parameters.Shift_par = parameters.Shift_par * scale_factor; 

%% Save the structure to a .mat file
save('parameters_database_one_conf_30.mat', 'parameters');
