import json
import pandas as pd
import os

# Get the current directory (assuming the script is in json_creation)
current_dir = os.path.dirname(os.path.abspath(__file__))

# Define file paths
template_path = "/scratch/users/rodell/AlphaFold3/AF3/templates/PUS7_RHBDD2.json"
csv_path = os.path.join(current_dir, "pus7sites_psipos_info.csv")
output_dir = os.path.join(current_dir, "output_PUS7_RNA")

# Ensure output directory exists
os.makedirs(output_dir, exist_ok=True)

# Read template JSON
with open(template_path, 'r') as f:
    template = json.load(f)

# Extract protein sequence from template
protein_sequence = template['sequences'][0]['protein']['sequence']

# Read CSV file
df = pd.read_csv(csv_path)

def sanitize_chr(chr_value):
    # Replace commas with underscores and remove any other problematic characters
    return chr_value.replace(',', '_').replace('/', '_').replace('\\', '_')

def create_new_json(template, protein_seq, rna_seq, chr_value):
    new_json = template.copy()
    sanitized_chr = sanitize_chr(chr_value)
    new_json['name'] = f"PUS7_{sanitized_chr}"
    new_json['sequences'][1]['rna']['sequence'] = rna_seq
    return new_json, sanitized_chr

# Main processing loop
files_created = 0
for index, row in df.iterrows():
    try:
        rna_seq = row['RNAsequence']
        chr_value = row['chr']
        
        new_json, sanitized_chr = create_new_json(template, protein_sequence, rna_seq, chr_value)
        
        filename = f"PUS7_{sanitized_chr}.json"
        filepath = os.path.join(output_dir, filename)
        
        with open(filepath, 'w') as f:
            json.dump(new_json, f, indent=2)
        
        files_created += 1
        print(f"Created file: {filename}")
    
    except Exception as e:
        print(f"Error processing row {index}: {e}")

print(f"Process complete. Created {files_created} JSON files.")