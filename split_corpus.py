from lxml import etree
import requests
import os
import pandas as pd
import re
import glob

def download_xml(year, title, vol):
    URL = f"https://www.govinfo.gov/content/pkg/CFR-{year}-title{title}-vol{vol}/xml/CFR-{year}-title{title}-vol{vol}.xml"
    response = requests.get(URL)

    if response.status_code == 200:
        directory = f"CFR{year}"
        os.makedirs(directory, exist_ok=True)  # Ensure the directory exists

        file_path = os.path.join(directory, f"CFR{year}-title{title}-vol{vol}.xml")
        with open(file_path, 'wb') as file:
            file.write(response.content)
        print(f"Downloaded and saved: {file_path}")
    else:
        print(f"Error: Unable to download file. HTTP Status: {response.status_code}")
        return

def split_xml_file(file_path, delimiter):
    try:
        source_file = f"{file_path}.xml"
        with open(source_file, 'r') as file:
            xml_content = file.read()
    except FileNotFoundError:
        print(f"Error: File not found: {source_file}")
        return
    parts = xml_content.split(delimiter)

    for i, part in enumerate(parts):
        output_file_path = f"{file_path}-part{i}.xml"
        with open(output_file_path, 'w') as output_file:
            output_file.write(part)
        print(f"Created file: {output_file_path}")

'''
for focal_year in range(1997, 2023):
        for focal_title in range(1, 51):
            dir_path = f"CFR-{focal_year}/title-{focal_title}/"
            file_pattern = os.path.join(dir_path, "*part*.xml")
            xml_files = glob.glob(file_pattern)
            
            for file_path in xml_files:
                os.remove(file_path)
'''

for focal_year in range(1997, 2023):
    for focal_vol in range(1, 21):
        for focal_title in range(1, 51):
            file_path = f"CFR-{focal_year}/title-{focal_title}/CFR-{focal_year}-title{focal_title}-vol{focal_vol}"
            delimiter = '<HD SOURCE="HED">PART'
            split_xml_file(file_path, delimiter)
