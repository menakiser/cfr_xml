import pandas as pd
import re
import glob
import os

def read_xmlcontent(output_table, part_path, statutes_list):
    try:
        with open(part_path, 'r') as file:
            first_line = file.readline().strip()
            xml_content = file.read()
    except FileNotFoundError:
        print(f"Error: File not found: {part_path}")
        return output_table  # Return unchanged table
    except Exception as e:
        print(f"An error occurred: {e}")
        return output_table  # Return unchanged table

    # Initialize row with FileName and FirstLine
    working_row = {'FileName': part_path, 'FirstLine': first_line}

    # Initialize all USCAct columns to 0
    for i in range(1, 31):
        working_row[f'USCAct{str(i).zfill(2)}'] = 0

    # Iterate through statutes_list DataFrame to check for citations in xml_content
    for _, row in statutes_list.iterrows():
        try:
            act_number = int(row["Act Number"])  # Convert act number to integer
            usc_citation = str(row["USC Citation"])  # Ensure USC Citation is a string, ignore et seq. or note

            if 1 <= act_number <= 30 and pd.notna(usc_citation): # replace using max act number
                if re.search(re.escape(usc_citation), xml_content):
                    working_row[f'USCAct{str(act_number).zfill(2)}'] += 1  # Mark as found
        except (ValueError, KeyError):
            continue  # Skip rows with invalid or missing values

    # Append the row to the output_table
    output_table = pd.concat([output_table, pd.DataFrame([working_row])], ignore_index=True)

    return output_table  # Return the updated dataframe



# obtain list of envrironmental statutes
statutes_list = pd.read_csv('env_statutes.csv', skiprows=2)
statutes_list.columns = statutes_list.iloc[0]
statutes_list = statutes_list[1:].reset_index(drop=True)
print(statutes_list.shape)
print(statutes_list['USC Citation'])

# define output table
USCcolumns = ["FileName", "FirstLine"] + [f"USCAct{str(i).zfill(2)}" for i in range(1, 31)]
USCtable = pd.DataFrame(columns=USCcolumns)
print(USCtable)

# loop through all *part*.xml files for each year-title folder
#for focal_year in range(1997, 2023):
for focal_year in range(1997, 2023):  # Updated range to include 2022
    for focal_title in range(1, 51):
        dir_path = f"CFR-{focal_year}/title-{focal_title}/"
        file_pattern = os.path.join(dir_path, "*part*.xml")
        xml_files = glob.glob(file_pattern)  # Get all matching XML files

        for file_path in xml_files:
            USCtable = read_xmlcontent(USCtable, file_path, statutes_list)

# Save only after all files from all years have been processed
USCtable.to_csv(f"USCtables/USCtable1997_2022.csv", index=False)

''''
for focal_year in range(1997, 2022):
    for focal_vol in range(1, 16):
        for focal_title in range(1, 51):
           for focal_part in range(1, 246):
                file_path = f"CFR-{focal_year}/title-{focal_title}/CFR-{focal_year}-title{focal_title}-vol{focal_vol}-part{focal_part}.xml"
                USCtable = read_xmlcontent(USCtable, file_path, statutes_list)
                USCtable.to_csv(f"CFR-{focal_year}/USCtable{focal_year}.csv", index=False)
'''''
