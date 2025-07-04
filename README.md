# Powertrain Optimization

This repository contains a MATLAB and Simulink framework for the generative design and multi-objective optimization of vehicle powertrain architectures. It leverages genetic algorithms to automatically create, simulate, and evaluate different powertrain layouts, aiming to find optimal solutions based on performance, energy consumption, cost, and emissions.

The project implements and compares several optimization strategies:
*   A custom Co-evolutionary Genetic Algorithm (CC-GA) that uses a weighted-sum fitness function.
*   A Non-dominated Sorting Genetic Algorithm II (NSGA-II), adapted for co-evolution (NSGA-CC), which finds a Pareto front of non-dominated solutions.
*   A random search method to provide a baseline for comparison.

## Key Features

*   **Generative Powertrain Design**: Automatically generates diverse powertrain topologies from a component library.
*   **Multi-Objective Optimization**: Optimizes designs against four key objectives:
    1.  **Drive Cycle Fidelity (MAE)**: Mean Absolute Error in tracking a reference speed profile.
    2.  **Specific Energy Consumption (Wh/km)**: Energy efficiency of the powertrain.
    3.  **Cost (€)**: Total cost of the powertrain components.
    4.  **Emissions (Tons of CO2)**: Estimated lifetime CO2 emissions, including manufacturing and operation.
*   **Dynamic Simulation**: Utilizes Simulink to simulate the performance of each generated powertrain design over a standard drive cycle (WLTP).
*   **Automated PID Tuning**: Integrates a genetic algorithm to automatically tune the PID controller for each unique powertrain design to ensure fair performance comparison.
*   **Component Library**: Includes a customizable Simulink library (`Powertrain_Library_GenAI.slx`) with components like batteries, internal combustion engines (ICE), motors, generators, and gearboxes.
*   **Automated Testing Framework**: Python scripts orchestrate the execution of MATLAB simulations in parallel, manage parameters, and log comprehensive results to Excel files.

## Repository Structure

```
.
├── CC-GA/                   # Co-evolutionary Genetic Algorithm (weighted sum) implementation.
│   ├── main.mlx             # Main script to run the CC-GA optimization.
│   ├── fitness_function.m   # Calculates the weighted fitness score.
│   └── ...                  # Other MATLAB functions and Simulink models.
│
├── NSGA-CC/                 # NSGA-II for Co-evolutionary design implementation.
│   ├── main.mlx             # Main script to run the NSGA-CC optimization.
│   ├── NDS_n_CD.m           # Non-dominated Sorting & Crowding Distance calculation.
│   ├── SelectNextGeneration.m # Selects the next generation based on Pareto fronts.
│   └── ...                  # Other MATLAB functions and Simulink models.
│
├── Running-the-tests/       # Scripts and results for running experiments.
│   ├── Matlab run and log 2.py # Python script to automate and parallelize simulation runs.
│   ├── Non-Dominated sorting for excel.py # Script to post-process results and find Pareto fronts.
│   └── Results/             # Directory containing extensive test results in .xlsx format.
│
└── LICENSE                  # Apache 2.0 License.
```

## How It Works

The optimization process follows these general steps:

1.  **Layout Generation**: The `modified_layout_gen_veh.m` script generates a powertrain architecture as a sequence of components, starting from the vehicle block and adding components backward.
2.  **Model Creation**: The `model_gen.m` script dynamically constructs a Simulink model (`Powertrain_Layout.slx`) based on the generated component sequence.
3.  **Parametrization**: The `parametrizer.m` script assigns physical parameters (e.g., engine power, battery capacity) to the components in the Simulink model. Parameters can be selected from a database or randomized within a defined variation.
4.  **PID Tuning**: Before full evaluation, `GeneticAlgorithmPIDTuner.m` tunes the driver model's PID controller for the specific powertrain to ensure it can adequately follow the drive cycle.
5.  **Simulation & Evaluation**: The `Powertrain_tester.m` script simulates the complete model over the WLTP drive cycle and calculates the four objective values (MAE, specific energy, cost, emissions).
6.  **Evolution**:
    *   In **CC-GA**, a single fitness score is calculated by `fitness_function.m`, and individuals are selected for crossover and mutation based on this score.
    *   In **NSGA-CC**, `NDS_n_CD.m` and `SelectNextGeneration.m` are used to rank solutions into Pareto fronts and select a diverse set of high-performing individuals for the next generation.
7.  **Iteration**: The process repeats, with new designs being generated through crossover (combining parts of two parent layouts) and mutation (randomly modifying a layout), until a target number of powertrains has been evaluated.

## Getting Started

### Prerequisites

*   **MATLAB**: R2021b or newer.
    *   Simulink
    *   Optimization Toolbox
*   **Python**: 3.8 or newer.
    *   `pandas`
    *   `matlab.engine`
    *   `openpyxl`
    *   `psutil`
    *   `numpy`

### Running the Simulations

The recommended way to run the experiments is by using the provided Python scripts, which manage the entire workflow.

1.  **Configure Paths**: Open `Running-the-tests/Matlab run and log 2.py` and update the file paths within the `algorithms` dictionary to match your local setup.

2.  **Set Parameters**: In the same script, you can configure the simulation parameters:
    *   `variations`: The percentage variation for component parameters.
    *   `algorithms`: A list of algorithms to run ("Random", "GA", "NSGA-II").
    *   `runs`: The number of repeated runs for each configuration.
    *   `required_MAEs`: The constraint for the Mean Absolute Error.
    *   `same_seed`: Determines if runs should use the same or different random seeds for reproducibility studies.

3.  **Execute**: Run the script from your terminal:
    ```bash
    python "Running-the-tests/Matlab run and log 2.py"
    ```
    The script will launch and manage multiple MATLAB instances in parallel to execute the simulation runs. Results will be automatically logged into `.xlsx` files in the `Running-the-tests` directory.

### Analyzing Results

After the runs are complete, you can use the `Non-Dominated sorting for excel.py` script to post-process the generated Excel files. This script calculates the Pareto front for the collected data points, making it easier to identify the optimal set of trade-off solutions.

## License

This project is licensed under the Apache License, Version 2.0. See the [LICENSE](LICENSE) file for details.
