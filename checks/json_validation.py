import json
import os
import sys

def validate_json(file_path):
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
        
        # Check for required keys
        required_keys = ['name', 'modelSeeds', 'sequences', 'dialect', 'version']
        for key in required_keys:
            if key not in data:
                return False, f"Missing required key: {key}"
        
        # Check sequences
        if len(data['sequences']) != 2:
            return False, "Expected 2 sequences (protein and RNA)"
        
        if 'protein' not in data['sequences'][0] or 'rna' not in data['sequences'][1]:
            return False, "Incorrect sequence order or missing protein/RNA"
        
        return True, "Valid"
    except json.JSONDecodeError:
        return False, "Invalid JSON format"
    except Exception as e:
        return False, str(e)

base_dir = "/scratch/users/rodell/AlphaFold3/AF3/PUS7_RNA"
invalid_files = []

for subdir in os.listdir(base_dir):
    json_path = os.path.join(base_dir, subdir, "input")
    if os.path.isdir(json_path):
        for file in os.listdir(json_path):
            if file.endswith('.json'):
                full_path = os.path.join(json_path, file)
                is_valid, message = validate_json(full_path)
                if not is_valid:
                    invalid_files.append((full_path, message))

if invalid_files:
    print("The following JSON files are invalid:")
    for file, message in invalid_files:
        print(f"{file}: {message}")
    sys.exit(1)
else:
    print("All JSON files are valid!")