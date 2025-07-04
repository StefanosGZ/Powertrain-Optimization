import os
import time
import secrets  # For secure random seed generation
import pandas as pd
import matlab.engine
from multiprocessing import Pool, current_process
from itertools import product

# Import psutil to set CPU affinity for consistent resource allocation
try:
    import psutil
except ImportError:
    print("psutil module not found. Please install it to set CPU affinity for consistent resource allocation.")

def init_worker():
    """
    This initializer runs once per worker process in the pool.
    It assigns each worker to a specific CPU core (using round-robin).
    This prevents workers from grabbing additional cores when others finish,
    ensuring each simulation runs with a consistent share of resources.
    """
    try:
        worker_id = current_process()._identity[0] if current_process()._identity else 0
        total_cores = os.cpu_count() or 1
        assigned_core = (worker_id - 1) % total_cores if worker_id > 0 else 0
        p = psutil.Process(os.getpid())
        p.cpu_affinity([assigned_core])
        print(f"Worker {worker_id} running on CPU core {assigned_core}")
    except Exception as e:
        print("Could not set CPU affinity for worker:", e)

def run_single_simulation(algo_name, variation, run_id, required_MAE, seed, same_seed, suppress_output=True):
    print(f"[{algo_name} - Var {variation} - MAE {required_MAE} - Run {run_id} - {same_seed}] Starting...")
    eng = matlab.engine.start_matlab()
    eng.eval("warning('off', 'all');", nargout=0)

    # Optional: Suppress MATLAB command window output
    if suppress_output:
        eng.eval("diary off; diary('nul');", nargout=0)

    # Define simulation parameters for each algorithm.
    algorithms = {
        "Random": {
            "script_path": r"\\home.org.aalto.fi\zafiris1\data\Documents\MATLAB\Genetic Algorithm",
            "inputs": {
                "params_file": 'parameters_database_one_conf_35.mat',
                "required_powertrains": 50,
                "initial_population": 50,
                "iteration_population": 0,
                "create_offspring": False,
                "n_offspring_per_iteration": 0,
                "mutate": False,
                "n_mutations_per_iteration": 0,
                "create_new_powertrains": False,
                "n_new_powertrains_per_iteration": 0,
                "variation": variation,
                "required_MAE": required_MAE
            },
            "workbook": fr"C:\Users\zafiris1\AppData\Local\anaconda3\GA\Random_{variation}_MAE_{required_MAE}_{same_seed}_Results.xlsx",
            "sheet_prefix": f"Random {variation} - "
        },
        "GA": {
            "script_path": r"\\home.org.aalto.fi\zafiris1\data\Documents\MATLAB\Genetic Algorithm",
            "inputs": {
                "params_file": 'parameters_database_one_conf_35.mat',
                "required_powertrains": 50,
                "initial_population": 15,
                "iteration_population": 10,
                "create_offspring": True,
                "n_offspring_per_iteration": 10 * variation,
                "mutate": True,
                "n_mutations_per_iteration": 10 * variation,
                "create_new_powertrains": False,
                "n_new_powertrains_per_iteration": 0,
                "variation": variation,
                "required_MAE": required_MAE
            },
            "workbook": fr"C:\Users\zafiris1\AppData\Local\anaconda3\GA\GA_{variation}_MAE_{required_MAE}_{same_seed}_Results.xlsx",
            "sheet_prefix": f"GA {variation} - "
        },
        "NSGA-II": {
            "script_path": r"\\home.org.aalto.fi\zafiris1\data\Documents\MATLAB\NSGA-II",
            "inputs": {
                "params_file": 'parameters_database_one_conf_35.mat',
                "required_powertrains": 50,
                "initial_population": 15,
                "iteration_population": 10,
                "create_offspring": True,
                "n_offspring_per_iteration": 10 * variation,
                "mutate": True,
                "n_mutations_per_iteration": 10 * variation,
                "create_new_powertrains": False,
                "n_new_powertrains_per_iteration": 0,
                "variation": variation,
                "required_MAE": required_MAE
            },
            "workbook": fr"C:\Users\zafiris1\AppData\Local\anaconda3\GA\NSGA-II_{variation}_MAE_{required_MAE}_{same_seed}_Results.xlsx",
            "sheet_prefix": f"NSGA-II {variation} - "
        }
    }

    algo_details = algorithms[algo_name]
    eng.addpath(algo_details["script_path"], nargout=0)

    # Create an empty workbook if it does not exist.
    if not os.path.exists(algo_details["workbook"]):
        df = pd.DataFrame()
        with pd.ExcelWriter(algo_details["workbook"], engine='openpyxl', mode='w') as writer:
            df.to_excel(writer, index=False, sheet_name="Sheet1")

    # Pass simulation parameters to MATLAB workspace.
    for key, value in algo_details["inputs"].items():
        eng.workspace[key] = value

    if same_seed == 'SAME_SEED':
        if run_id == 1:
            seed = 879437953
        elif run_id == 2:
            seed = 3071760814
        elif run_id == 3:
            seed = 3454044073
    # Set MATLAB's RNG using the unique seed.
    eng.eval(f"rng({seed});", nargout=0)

    # --- Measure wall-clock and CPU time ---
    start_wall = time.time()
    start_cpu = time.process_time()

    eng.eval("main", nargout=0)

    elapsed_time = time.time() - start_wall
    cpu_time_used = time.process_time() - start_cpu

    # Retrieve results from MATLAB workspace.
    created_powertrains = eng.workspace['created_powertrains']
    stored_powertrains = eng.workspace['stored_powertrains']
    created_with_crossover = eng.workspace['created_with_crossover']
    created_with_mutation = eng.workspace['created_with_mutation']
    powertrains_cell = eng.workspace['powertrains_cell']
    powertrains = [dict(item) for item in powertrains_cell]

    # Format the simulation results.
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
            "Layout parameters": powertrains[i]['layout']['params'],
            "Elapsed Time (s)": elapsed_time,
            "CPU Time (s)": cpu_time_used,
            "Unique Identifier": f"{algo_name} - {i+1} - run {run_id} - variation {variation} - MAE {required_MAE}"
        })

    df_results = pd.DataFrame(iteration_results)
    sheet_name = f"{algo_details['sheet_prefix']}{run_id}"
    with pd.ExcelWriter(algo_details["workbook"], engine='openpyxl', mode='a', if_sheet_exists='new') as writer:
        df_results.to_excel(writer, index=False, sheet_name=sheet_name)

    eng.eval("clear", nargout=0)
    eng.quit()

    print(f"[{algo_name} - Var {variation} - MAE {required_MAE} - Run {run_id}] Completed in {elapsed_time:.1f} s, CPU time: {cpu_time_used:.1f} s.")

if __name__ == '__main__':
    variations = [0.15, 0.30, 0.45]         # Example variations
    algorithms = ["NSGA-II"]
    runs = [1, 2, 3]
    required_MAEs = [1, 10]                # New MAE values to test
    same_seed = ['DIFFERENT_SEED', 'SAME_SEED']

    # Generate a unique seed for each simulation run and create job list.
    all_jobs = []
    for same_seed_val, algo, variation, run, mae in product(same_seed, algorithms, variations, runs, required_MAEs):
        seed = secrets.randbits(32)
        all_jobs.append((algo, variation, run, mae, seed, same_seed_val))

    # Use available processors (or the number of jobs, whichever is lower).
    processes_count = min(len(all_jobs), os.cpu_count())

    # Launch the pool with our CPU affinity initializer.
    with Pool(processes=processes_count, initializer=init_worker) as pool:
        pool.starmap(run_single_simulation, all_jobs)
