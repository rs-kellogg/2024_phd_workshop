##############################
#  Remove HTML from SEC docs #
##############################

# libraries
import pandas as pd
import re
import os
import sys
from pathlib import Path
import argparse

##########
# Inputs #
##########
# input dir
#input_dir = "/kellogg/data/EDGAR/10-K/2023"

# output dir
#output_dir = "/home/<netID>/2024_phd_workshop/klc_fundamental/clean_sec/10K_cleaned_2023"

# run with 
# python clean_sec.py --input_dir /kellogg/data/EDGAR/10-K/2023 --output_dir /home/<netID>/2024_phd_workshop/klc_fundamental/clean_sec/10K_cleaned_2023

# Create the parser
parser = argparse.ArgumentParser(description="Process 10-K files.")

# Add arguments for input and output directories
parser.add_argument("--input_dir", type=str, required=True, help="Input directory path")
parser.add_argument("--output_dir", type=str, required=True, help="Output directory path")

# Parse the arguments
args = parser.parse_args()

# Convert arguments to Path objects
input_dir = Path(args.input_dir)
output_dir = Path(args.output_dir)

#############
# Functions #
#############

def clean_html(html: str) -> str:
    # First we remove inline JavaScript/CSS:
    cleaned = re.sub(r"(?is)<(script|style).*?>.*?(</\1>)", "", html.strip())

    # Then we remove html comments. This has to be done before removing regular
    # tags since comments can contain '>' characters.
    cleaned = re.sub(r"(?s)<!--(.*?)-->[\n]?", "", cleaned)

    # Next we can remove the remaining tags:
    cleaned = re.sub(r"(?s)<.*?>", " ", cleaned)

    # Finally, we deal with whitespace
    cleaned = re.sub(r"&nbsp;", " ", cleaned)
    cleaned = re.sub(r" {2,}", " ", cleaned)

    return cleaned.strip()

def ensure_directory_exists(directory: Path) -> None:
    if not directory.exists():
        directory.mkdir(parents=True, exist_ok=True)

########
# Run
########

def main(input_dir: Path, output_dir: Path) -> None:
    # Ensure directories exist
    ensure_directory_exists(input_dir)
    ensure_directory_exists(output_dir)

    # Get list of files
    files = list(input_dir.glob("*"))
    files = files[0:5] # for the demo I limit to the first 5 10Ks
    num_files = len(files)
    print(f"Number of files: {num_files}")

    if num_files == 0:
        print("Number of files must be greater than 0!")
        sys.exit(1)

    # Load and clean files
    for file_path in files:
        print(f"Loading: {file_path.name}")

        # Clean file
        clean_text = clean_html(file_path.read_text(encoding='utf-8'))

        # Save file
        output_path = output_dir / file_path.name
        output_path.write_text(clean_text, encoding='utf-8')

        print(f"Saved: {output_path}")

if __name__ == "__main__":
    main(input_dir, output_dir)

