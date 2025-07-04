import matlab.engine
import pandas as pd
import time
import os

# Start MATLAB engine
eng = matlab.engine.start_matlab()

# Define settings for each algorithm
algorithms = {
    "Random": {
        "script_path": r"Placeholder",
        "inputs": {
            "required_powertrains": 2,
            "required_MAE": 50,
            "save_folder": "Run_5",
            "initial_population": 2,
            "iteration_population": 0,
            "max_iterations": 0,
            "create_offspring": False,
            "n_offspring_per_iteration": 0,
            "mutate": False,
            "n_mutations_per_iteration": 0,
            "create_new_powertrains": False,
            "n_new_powertrains_per_iteration": 0,
            "max_repeat": 1
        },
        "workbook": r"Placeholder",
        "sheet_prefix": "Rand 1 - "
    },
    "GA": {
        "script_path": r"Placeholder",
        "inputs": {
            "required_powertrains": 3,
            "required_MAE": 50,
            "save_folder": "Run_5",
            "initial_population": 2,
            "iteration_population": 5,
            "max_iterations": 10,
            "create_offspring": True,
            "n_offspring_per_iteration": 1,
            "mutate": True,
            "n_mutations_per_iteration": 1,
            "create_new_powertrains": False,
            "n_new_powertrains_per_iteration": 0,
            "max_repeat": 1
        },
        "workbook": r"Placeholder",
        "sheet_prefix": "GA 1 - "
    },
    "NSGA-II": {
        "script_path": r"Placeholder",
        "inputs": {
            "required_powertrains": 3,
            "required_MAE": 50,
            "save_folder": "Run_5",
            "initial_population": 2,
            "iteration_population": 5,
            "max_iterations": 10,
            "create_offspring": True,
            "n_offspring_per_iteration": 1,
            "mutate": True,
            "n_mutations_per_iteration": 1,
            "create_new_powertrains": False,
            "n_new_powertrains_per_iteration": 0,
            "max_repeat": 1
        },
        "workbook": r"Placeholder",
        "sheet_prefix": "NSGA-II 1 - "
    }
}

# Run each algorithm
for algo_name, algo_details in algorithms.items():
    print(f"Starting {algo_name}...")
    eng.addpath(algo_details["script_path"], nargout=0)

    if not os.path.exists(algo_details["workbook"]):
        df = pd.DataFrame()  # Create an empty DataFrame
        with pd.ExcelWriter(algo_details["workbook"], engine='openpyxl', mode='w') as writer:
            df.to_excel(writer, index=False, sheet_name="Sheet1")

    for iteration in range(2):
        print(f"Running {algo_name} - Iteration {iteration + 1}...")
        start_time = time.time()

        # Pass inputs to MATLAB
        for key, value in algo_details["inputs"].items():
            eng.workspace[key] = value

        # Run the MATLAB script
        eng.eval("main", nargout=0)

        # Extract outputs from MATLAB
        created_powertrains = eng.workspace['created_powertrains']
        stored_powertrains = eng.workspace['stored_powertrains']
        created_with_crossover = eng.workspace['created_with_crossover']
        created_with_mutation = eng.workspace['created_with_mutation']
        powertrains_cell = eng.workspace['powertrains_cell']
        elapsed_time = time.time() - start_time

        # Iterate over the cells to extract individual structs
        powertrains = [dict(item) for item in powertrains_cell]
        # Store results for this iteration
        iteration_results = []
        for i in range(int(stored_powertrains)):
            iteration_results.append({
                "Created Powertrains": created_powertrains,
                "Stored Powertrains": stored_powertrains,
                "Created with crossover": created_with_crossover,
                "Created with mutation": created_with_mutation,
                "MAE": powertrains[i]['results']['MAE'],
                "E_specific": powertrains[i]['results']['E_specific'],
                "Cost": powertrains[i]['results']['cost'],
                "Emissions": powertrains[i]['results']['emissions'],
                "Layout": powertrains[i]['layout']['layout'],
                "Layout Connection Type": powertrains[i]['layout']['layout_conn_type'],
                "Layout Connection Direction": powertrains[i]['layout']['layout_conn_dir'],
                "Elapsed Time (s)": elapsed_time
            })

        # Add input parameters to the DataFrame
        input_parameters = algo_details["inputs"]
        input_parameters_log = [{"Parameter": key, "Value": value} for key, value in input_parameters.items()]

        # Create DataFrames for iteration results and input parameters
        df_results = pd.DataFrame(iteration_results)
        df_inputs = pd.DataFrame(input_parameters_log)

        # Dynamically name the sheet
        sheet_name = f"{algo_details['sheet_prefix']}{iteration + 1}"

        # Write results and input parameters to separate parts of the same sheet
        with pd.ExcelWriter(algo_details["workbook"], engine='openpyxl', mode='a') as writer:
            df_results.to_excel(writer, index=False, sheet_name=sheet_name)
            df_inputs.to_excel(writer, index=False, sheet_name=f"{sheet_name} - Inputs")

print("All algorithms completed successfully.")

# Stop MATLAB engine
eng.quit()
