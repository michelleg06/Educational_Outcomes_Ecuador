import pandas as pd
import time
from os import listdir
from os.path import isfile, join

# ------------------------------------
# Define Location of Annual .dta files
# ------------------------------------
IMPORT_PATH = "C://Users//alexh_okinaul//Documents//Data//Ecuadorian almost-panel//Trimestrales//"

# -----------------------
# Define Utility Function
# -----------------------


def flatten(nested_list):
    return [item for sublist in nested_list for item in sublist]


# ---------------------
# Import and Merge Data
# ---------------------
start = time.time()

year = 2007
print("--- Importing annual .dta files ---")
data_frames = [pd.read_stata(IMPORT_PATH + f) for f in listdir(IMPORT_PATH) if isfile(join(IMPORT_PATH, f))]

for df in data_frames:
    df['year'] = year
    year += 1

print("--- Concatenating annual DataFrames ---")
data = pd.concat(data_frames)
print("--- Concatenating finished ---")

end = time.time()
print("Finished importing and concatenating in " + str(end-start) + " seconds.")

# -------------------
# Check if successful
# -------------------
len(data.columns)  # returns 1013
len(set(flatten([df.columns for df in data_frames])))  # returns 1013
