import pandas as pd
import numpy as np

# Function for non-dominated sorting
def non_dominated_sorting(data):
    num_points = data.shape[0]
    domination_counts = np.zeros(num_points, dtype=int)
    domination_sets = [set() for _ in range(num_points)]
    ranks = np.zeros(num_points, dtype=int)

    for p in range(num_points):
        for q in range(num_points):
            if np.all(data[p] <= data[q]) and np.any(data[p] < data[q]):
                domination_sets[p].add(q)
            elif np.all(data[q] <= data[p]) and np.any(data[q] < data[p]):
                domination_counts[p] += 1

        if domination_counts[p] == 0:
            ranks[p] = 1

    current_rank = 1
    while True:
        next_front = []
        for p in np.where(ranks == current_rank)[0]:
            for q in domination_sets[p]:
                domination_counts[q] -= 1
                if domination_counts[q] == 0:
                    ranks[q] = current_rank + 1
                    next_front.append(q)
        if not next_front:
            break
        current_rank += 1

    return ranks

# Load the Excel data
file_path = r"Placeholder"
sheet_name = "Sheet1"
data = pd.read_excel(file_path, sheet_name=sheet_name, skiprows=1)  # Adjust skiprows if necessary

# Preview the dataset

# Access columns F, G, H, I by position (adjust indices if needed)
objectives = data.iloc[:, [5, 6, 7, 8]].to_numpy()

# Perform non-dominated sorting
pareto_ranks = non_dominated_sorting(objectives)

# Add Pareto ranks to column O (index 14, adjust as needed)
data['O'] = pareto_ranks

# Save the updated data back to Excel
data.to_excel(file_path, sheet_name=sheet_name, index=False)
print("Non-dominated sorting completed. Pareto front ranks written to column O.")
