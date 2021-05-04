#TODO: bit of cleaning and checking that there is actually 
#      flow through the code.

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

#TODO: Import data from TranslationAndClearning

# ---------------------
# Add numerical columns
# ---------------------

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
plt.title('Heatmap of Correlations')
plt.show()
plt.savefig("heatmap_of_correlations.png")
plt.clear()


data_filt = data.loc[(data['hours_worked']>36) and (data['age']>24) and (data['sex']=='mujer')]

# Correlating to find proxies 
# TODO add the effects of 'ordered'
data_school_edu_level=pd.concat(
    [
        data["years_of_schooling"],
        data["level_of_education_num"]
    ],axis=1

)
sn.heatmap(cdata_school_edu_level.corr(method='spearman'), annot=True)
plt.title('cor_test: years_of_schooling with level_of_education_num')
plt.show()
plt.savefig("cor_test_years_of_schooland_level_of_ed.png")
plt.clear()

data_school_job_feel=pd.concat(
    [
        data["years_of_schooling"],
        data["job_feeling_num"]
    ],axis=1

)
sn.heatmap(data_school_job_feel.corr(method='spearman'), annot=True)
plt.title('cor_test: years_of_schooling with job_feeling_num')
plt.show()
plt.savefig("cor_test_years_of_schooland_job_feeling.png")
plt.clear()



# Histogram plots.

# Essential commands. 
corr_plot_data['income_labour'].hist(bins=6)
plt.title('Histogram: income_labour')
plt.show()
plt.save_fig("hist_income_labour.png")
plt.clear()

corr_plot_data['hours_worked'].hist(bins=6)
plt.title('Histogram: hours_worked')
plt.show()
plt.save_fig("hist_hours_worked.png")
plt.clear()

