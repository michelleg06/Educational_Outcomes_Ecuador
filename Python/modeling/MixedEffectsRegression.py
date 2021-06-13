import numpy as np
import statsmodels.formula.api as smf
from rpy2 import robjects
from rpy2.robjects import pandas2ri
from rpy2.robjects import rl
from rpy2.robjects.packages import importr
from scipy.special import expit
from math import exp


import Imputation

ordinal = importr("ordinal")
texreg = importr("texreg")
margins = importr("margins")

pandas2ri.activate()

# -------------------------
# Define the variables used
# -------------------------

endog = ["level_of_education_num"]
exog_f = ["female",
          "has_received_human_dev_bond",
          "poverty_num", "age_st", "year"]
exog_r = ["daily_hours_internet_use_st", "no_medical_insurance_num"]
clusters = ["city", "conglomerado", "home_id", "household_id"]

# ------------------
# Define helper math
# ------------------


def expit_deriv(x):
    return exp(x)/(1+exp(x))**2


# ----------------------
# Import and filter data
# ----------------------

data = Imputation.data

drop_na = endog + exog_f + exog_r + clusters
drop_na.remove('has_received_human_dev_bond')
data_filtered = data.loc[:, endog + exog_f + exog_r + clusters].dropna(subset=endog + exog_f + exog_r + clusters)

data_filtered.loc[:, 'level_of_education_num'] = data_filtered.loc[:, 'level_of_education_num'].astype(str)

# ----------------------
# Some descriptive stats
# ----------------------

data_filtered['has_received_human_dev_bond'].notnull().value_counts()  # Note: in this dataset, only 94 have actually received a bond.
data['has_received_human_dev_bond'].notnull().value_counts()  # Misses about 100k entries; 10 times more than income_pc
data_filtered['has_received_human_dev_bond'].notnull().value_counts()  # Misses about 100k entries; 10 times more than income_pc

data_filtered['conglomerado'].value_counts()  # <1% has a unique conglomerado, most is 999999: perhaps that's na?
data['conglomerado'].describe()  # On the whole, ~50% is 999999, of a total of 228k entries that even have this stored.

# over half the cities have less than 10 measurements. I think many cities are just too small to allow for unique
# conglomerado's.
data['city'].value_counts()  # Many unique values.
data['city'].value_counts().sum()  # On the whole, ~50% is 999999, of a total of 228k entries that even have this stored.

# -----------------------------
# Modeling using rpy2 and clmm2
# -----------------------------
r_data = pandas2ri.py2rpy_pandasdataframe(data_filtered.copy())

# Convert to factor
col_index = r_data.colnames.index('level_of_education_num')
col_as_factor = robjects.vectors.FactorVector(r_data.rx2('level_of_education_num'))
r_data[col_index] = col_as_factor

# Convert to factor
col_index = r_data.colnames.index('has_received_human_dev_bond')
col_as_factor = robjects.vectors.FactorVector(r_data.rx2('has_received_human_dev_bond'))
r_data[col_index] = col_as_factor

clmm = robjects.r("clmm")
summary = robjects.r("summary")
coef = robjects.r("coef")

fit = clmm(rl(
    'level_of_education_num ~ female + age_st + poverty_num + daily_hours_internet_use_st + has_received_human_dev_bond +' +
    '(no_medical_insurance_num|city) + year'
), data=r_data)

print(fit)
print(summary(fit))
print(coef(fit))

# Interpreting thresholds - marginal effects at the mean
1-expit(coef(fit)[2])  # 76%: chance of high school or higher for average, male, no poverty, no dev bond, with medical insurance.
1-expit(coef(fit)[3])  # 17%: chance of > high school average, male, no poverty, no dev bond, with medical insurance.
coef(fit)[6]*expit_deriv(coef(fit)[3])  # Being average and female increases the chance of going above high school by 11%.
coef(fit)[10]*expit_deriv(coef(fit)[3])  # Being average and receiving a dev bond decreases the chance of going above high school by 17%.
coef(fit)[8]*expit_deriv(coef(fit)[3])  # Being average and self-reporting poverty decreases the chance of going above high school by 10%.

# Interpreting thresholds - average marginal effects PACKAGE DOES NOT WORK FOR CLMM
# marginal_effects = robjects.r("marginal_effects")
# print(marginal_effects(fit))

# Interpreting coefficients - relative risk ratios
exp(coef(fit)[6])  # 2.2: Being female doubles the chance of increasing in rank.
exp(coef(fit)[10])  # 0.28: having received a bond would divide the chance of increasing in rank by 3
exp(coef(fit)[8])  # 0.51: self-reporting poverty halves the chance of increasing in rank

# Storing output
texreg = robjects.r("texreg")
texreg(fit, file='reg_output')
