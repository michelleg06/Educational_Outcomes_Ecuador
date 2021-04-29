#TODO (Siphelele): this skeleton was set up on a slightly outdated main,
                   # so I will have to check for consistency amongst all
                   # the todo's.



#-------------------
# Import functions
#-------------------

import SaveAndMergePanel
import numpy as np
import pandas as pd
import seaborn as sn
import matplotlib.pyplot as plt


# ---------
# Load Data
# ---------

#TODO (Siphelele): Import data from TranslationAndClearning

# ---------------------
# Add numerical columns
# ---------------------

# Add level of education as numerical variable
# but this will come with the imported data.

# Add sex as a numerical variable
sex = ["hombre", "mujer"]
sex_num = [1, 2]
sex_num_dict = dict(zip(sex, sex_num))
data["sex_num"] = [sex_num_dict[x] if x in sex else\ 
                  x for x in data["sex"]]

#-----------------------
# Return column as int.
#-----------------------

data["age"]=data["age"].astype (int)
data["income_labour"]=data["income_labour"].astype (int)
data["hours_worked"]=data["hours_worked"].astype(int)

#TODO (Siphelele): translating the column collapse based
# on criteria related to names.

# Sort data on level_of_education_num and job_feeling_num.
data = data.sort_values(["level_of_education_num", 
       "job_feeling_num"])


# Creating a temporary data frame
# necessary computing the correlation matrix.
corr_plot_data = pd.concat(
    [
        data["income_labour"],
        data["sex_num"],
        data["age"],
        data["level_of_education_num"],
        data["job_feeling_num"],
        data["hours_worked"],
    ],axis=1

)
#--------------------------------
# Plots and further correlations.
#--------------------------------

# Plotting a heatmap with labels as correlation
# values.
sn.heatmap(corr_plot_data.corr(), annot=True)

#TODO (Siphelele): make axis pop-up for this visual.

#TODO (Siphelel): directly translate the part for correlating to 
#                 find proxies.

# Histogram plots.

# Essential commands. 
corr_plot_data['income_labour'].hist(bins=6)
corr_plot_data['hours_worked'].hist(bins=6)

#TODO (Siphelele): Make axes and dispay 
                   #results then enable saving.


