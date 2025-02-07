# this script updates the metadata of all Python notebooks
# (needed by KI-Campus' Jupyterhub to automatically detect the correct Kernel)
# Run with `python3 update-kernel_py.py` from the `exercises` folder!

import os
import json

# how the Kernel specifications in each notebook should look:
reference = {
    "display_name": "Python (I2ML)",
    "language": "python",
    "name": "python-i2ml"
}

base_dir = "./"

def update_kernelspec(notebook_path):
    with open(notebook_path, 'r', encoding='utf-8') as file:
        notebook_data = json.load(file)
    
    notebook_data['metadata']['kernelspec'] = reference
    
    with open(notebook_path, 'w', encoding='utf-8') as file:
        json.dump(notebook_data, file, indent=2)
    print(f"Updated {notebook_path}")

for root, _, files in os.walk(base_dir):
    for file in files:
        if file.endswith("_py.ipynb"):
            notebook_path = os.path.join(root, file)
            update_kernelspec(notebook_path)

print("All notebooks' Kernelspec have been updated.")
