#!/bin/bash
#SBATCH --partition=standard
#SBATCH --account=liegroup
#SBATCH --job-name=dodge
#SBATCH --output=splitxml.log
#
#SBATCH --time=10:00:00
#SBATCH --mem=50G
#SBATCH --ntasks=5
#
#SBATCH --mail-type=ALL


module load python/3.9.0

python3 split_corpus.py
python3 read_xml.py