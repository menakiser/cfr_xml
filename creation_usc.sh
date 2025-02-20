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


module load python/anaconda3

pip install --user re
pip install --user pandas
pip install --user glob
pip install --user os
pip install --user lxml
pip install --user requests

python3 split_corpus.py
python3 read_xml.py