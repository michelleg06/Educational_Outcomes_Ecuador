import TranslationAndCleaning
import pandas as pd
import statsmodels.api as sm
import matplotlib.pyplot as plt
from statsmodels.formula.api import ols

data = TranslationAndCleaning.data.reset_index()

# ------------------------
# Define used column names
# ------------------------
cluster_vars = ['person', 'household_id', 'home_id', 'conglomerado', 'city']

indep_vars = ['sex', 'age', 'income_pc', 'poverty', 'has_received_free_school_uniform']
dep_vars = ['years_of_schooling']
# Is this a numerical proxy for level of education? Perhaps better to use the level directly.

# ---------------------------------------
# Study Completeness for Different Models
# ---------------------------------------

# Count per-variable completeness.
#  Note: level_of_education is 92% complete, years of schooling only 47.6%.
#  Note: has_received_free_school_uniform is 11.48% complete.
#  Note: All other variables are >99% complete.
#  Note: Missingness in income_pc seems to correspond precisely with missingness in poverty.
total_entries = data.shape[0]
for var in dep_vars + indep_vars + ['level_of_education']:
    complete_entries = data[var].dropna().shape[0]
    print("missing values for " + var, ":", total_entries - complete_entries, "/", total_entries, "|| Completeness",
          100 * complete_entries / total_entries, "%")

# Count completeness by complete series using these data
model_1_vars = dep_vars + indep_vars
print("Completeness for " + ", ".join(model_1_vars) + ":",
      1 - data[model_1_vars].notnull().all(axis=1).value_counts()[False] / total_entries)
# 0% complete.

model_2_vars = ['level_of_education'] + indep_vars
print("Completeness for " + ", ".join(model_2_vars) + ":",
      1 - data[model_2_vars].notnull().all(axis=1).value_counts()[False] / total_entries)
# Exchange years of schooling for level of education: 11% complete.

model_3_vars = ['level_of_education'] + indep_vars
model_3_vars.remove('has_received_free_school_uniform')
print("Completeness for " + ", ".join(model_3_vars) + ":",
      1 - data[model_3_vars].notnull().all(axis=1).value_counts()[False] / total_entries)
# Exchange years of schooling for level of education & remove has_received_free_school_uniform: 91% complete.
# Completeness is 99% without level of education\.

model_4_vars = ['level_of_education'] + indep_vars
model_4_vars.remove('has_received_free_school_uniform')
model_4_assumptions = data['age'] > 4
print("Completeness for " + ", ".join(model_4_vars) + ":",
      1 - data.loc[model_4_assumptions, model_4_vars].notnull().all(axis=1).value_counts()[False] / total_entries)
print("Assumption: age > 4")

total_entries_filt = data.loc[model_4_assumptions, :].shape[0]
for var in model_4_vars:
    complete_entries = data.loc[model_4_assumptions, var].dropna().shape[0]
    print("missing values for " + var, ":", total_entries_filt - complete_entries, "/", total_entries_filt,
          "|| Completeness", 100 * complete_entries / total_entries_filt, "%")
# 0% is missing in level of education, sex, and age.
# 1.11% is missing in income_pc, poverty


# -----------------------------------------
# Study Completeness for Level of Education
# -----------------------------------------
data['missing_level_of_education'] = [1 if pd.isnull(x) else 0 for x in data['level_of_education']]

X = pd.get_dummies(data=data[['sex', 'age', 'income_pc', 'poverty']], drop_first=True).dropna()
y = data.iloc[X.index]['missing_level_of_education']

for i in range(0, X.shape[1]):
    plt.scatter(X.iloc[:, i], y)
    plt.xlabel(X.columns[i])
    plt.show()
# Age almost fully separates the data, with no missing values existing for ages above 8 years old or so.
# Note: this way of plotting does not work for sex and poverty. Need a value count. See below.

print(data[data['missing_level_of_education'] == 1]['age'].value_counts())
age_for_non_missing_data = data[data['missing_level_of_education'] == 0]['age']
print(min(age_for_non_missing_data), max(age_for_non_missing_data))
# Level of education is missing only for ages 0-4, and exists for above 5.

data[data['age'] > 4].missing_level_of_education.value_counts()
# Conclusion: When filtering for ages above 4 all missing data points are removed.

# -----------------------------------------------------
# Study Amount of Missingness for poverty and income_pc
# -----------------------------------------------------
total_measurements_per_year = data.iloc[data.index[data['person'].notnull()]]['year'].value_counts().reset_index()

data['has_received_human_dev_bond'].notnull().value_counts()
data['poverty'].notnull().value_counts()

missing_pov_idx = data.index[data['poverty'].isnull()]
missing_inc_idx = data.index[data['income_pc'].isnull()]
present_inc_idx = data.index[data['income_pc'].notnull()]

missing_pov_idx.equals(missing_inc_idx)
# Returns True: Precisely the same values are missing here. Strange.
# TODO: What does it mean for our model results that missingness in poverty and income_pc is perfectly correlated?

pov_count_per_year = data[data['poverty'] == 'pobre']['year'].value_counts().reset_index()
missing_per_year = data[data['poverty'].isnull()]['year'].value_counts().reset_index()
missing_per_year = (missing_per_year.merge(total_measurements_per_year, on='index')
                    .merge(pov_count_per_year, on='index')
                    .rename({'year': 'count_pov', 'index': 'year', 'year_x': 'count_missing', 'year_y': 'count_full'},
                            axis=1)
                    .sort_values(by='year'))
missing_per_year['percentage_miss'] = missing_per_year['count_missing'] / missing_per_year['count_full']
missing_per_year['percentage_pov'] = missing_per_year['count_pov'] / missing_per_year['count_full']
missing_per_year['factor'] = missing_per_year['percentage_miss'] / missing_per_year['percentage_pov']
# Summary of created tables:
# Missingness fluctuates from 1.9% to 0.05% per year for this variable. If removing the data does not induce significant
# bias, it is probably safe to remove it: In no single year is the percentage of values missing more than 5% of the
# amount of people self-reporting poverty. It is unlikely we are removing important dynamics.

# ------------------------------------------------------------------------------------------
# Study Type of Missingness for poverty and income_pc (e.g. at random, completely at random)
# ------------------------------------------------------------------------------------------

data['poverty_num'] = pd.factorize(data['poverty'])[0]
data[['poverty_num', 'income_pc']].corr(method='spearman')
# Poverty and income_pc are very strongly correlated; -0.8.

data['missing_poverty'] = [1 if pd.isnull(x) else 0 for x in data['poverty']]

X = pd.get_dummies(data=data[['sex', 'age']], drop_first=True)
y = data['missing_poverty']

for i in range(0, X.shape[1]):
    plt.scatter(X.iloc[:, i], y)
    plt.xlabel(X.columns[i])
    plt.show()
# On first sight it appears evenly distributed. 

missingness_by_level_of_ed = data.loc[data['missing_poverty'] == 1, 'level_of_education'].value_counts()
missingness_pct_by_level_of_ed = (data.loc[data['missing_poverty'] == 1, 'level_of_education']
                                  .value_counts().div(data['level_of_education'].value_counts()))
missingness_by_level_of_ed.plot(kind='bar')
plt.show()
missingness_pct_by_level_of_ed.plot(kind='bar')
plt.show()
# More values are missing in the bracket for higher educated people, i.e. post-grado and universitario.

X = pd.get_dummies(data.loc[model_4_assumptions, 'level_of_education'], drop_first=True)
y = data.loc[model_4_assumptions, 'missing_poverty']
model = sm.OLS(y, sm.add_constant(X)).fit()
print(model.summary())
# ANOVA shows that coefficients for post-grado, secundaria, and superior universitario are all statistically significant.
# Hence data missingness is related to our dependent variable. As such, it may even be related to income levels.

model_for_anova = ols(formula='missing_poverty ~ level_of_education', data=data[model_4_assumptions]).fit()
sm.stats.anova_lm(model_for_anova)
# Corroborated by statistical test: F-test says we can reject the null hypothesis that all means are the same.
# --> Data is definitely not MCAR, and unlikely to be MAR, since level of education is weakly correlated to income.

data.loc[model_4_assumptions, ['income_pc', 'level_of_education_num']].corr(method='spearman')
# corr is .23

# Conclusion: To prevent any bias data should be imputed with some model.
# TODO: Create data imputation model.

# ------------------------------------------------
# Study Possible Proxies for poverty and income_pc
# ------------------------------------------------
missing_pov_idx = data.index[data['poverty'].isnull()]

income_cols = ['income_self_employed', 'income_wage_and_domestic', 'income_capital', 'income_capital_transactions',
               'income_retirement_pension', 'income_gift_donation', 'income_from_abroad', 'income_labour']
hh_income_cols = ['hh_income_total', 'hh_size', 'hh_income_pc']  # can impute based on hh wealth?
pov_proxy_1 = ['number_of_jobs']  # perhaps strongly related to poverty? where more jobs = less money per job = poorer?
pov_proxy_2 = ['hours_worked1', 'place_of_work']  # use in nn imputation?


def count_missing_values_for_selection(idx, df, mask, cols):
    for col in cols:
        print(df.iloc[idx].loc[mask, col].isnull().value_counts())


count_missing_values_for_selection(missing_pov_idx, data, model_4_assumptions, income_cols)
# wage and domestic covers all but 634 missing values!
# capital and capital transactions cover all but one missing value!

count_missing_values_for_selection(missing_pov_idx, data, model_4_assumptions, pov_proxy_1)
# covers all but 446 values.

count_missing_values_for_selection(missing_pov_idx, data, model_4_assumptions, pov_proxy_2)
# cover a bit more than half of missing values; 5499

count_missing_values_for_selection(missing_pov_idx, data, model_4_assumptions, hh_income_cols)
# hh_inc_total and hh_income_pc
# present for all values! Size missing, though.

data['income_tot'] = data[income_cols].sum(axis=1)
data['income_pct_change'] = (data['income_pc'] - data['income_tot']) / data['income_pc']
(data.loc[(-3 < data['income_pct_change']) & (data['income_pct_change'] < 101), 'income_pct_change']
 .value_counts(bins=50)
 .sort_index(ascending=True))
(data.loc[(-101 < data['income_pct_change']) & (data['income_pct_change'] < 101), 'income_pct_change']
 .value_counts()
 .sum())
# For 615k entries the change is almost 100%; i.e. income_tot is near 0 for these entries. Changes are around 0% for only 22k
# entries: Very big discrepancies exist.

# TODO: Contact statistical office to ask why this discrepancy exists.
# TODO: Further decide on what proxy to use.

# Impute income data with total data. NOTE: This is far from perfect, but produces a complete dataset for now, until
# I can get some information from the producer of the dataset.
# So: Right now income_pc is leading, and imputed with the sum of incomes where necessary.
data['income_imp'] = data.loc[:, 'income_pc']
data.loc[missing_inc_idx, 'income_imp'] = data.loc[:, 'income_tot']

# Assert that no values are missing.
data['income_imp'].isnull().value_counts()[False] == len(data)

# Assert values have been imputed
data.loc[present_inc_idx, 'income_imp'].equals(data.loc[present_inc_idx, 'income_pc'])
data.loc[missing_inc_idx, 'income_imp'].equals(data.loc[missing_inc_idx, 'income_tot'])
