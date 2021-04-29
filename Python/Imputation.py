import TranslationAndCleaning
import pandas as pd
import statsmodels.api as sm

data = TranslationAndCleaning.data.reset_index()

# ------------------------
# Define used column names
# ------------------------
cluster_vars = ['person', 'household_id', 'home_id', 'conglomerado', 'city']

indep_vars = ['sex', 'age', 'income_pc', 'poverty', 'has_received_free_school_uniform']
dep_vars = ['years_of_schooling']  # Is this a numerical proxy for level of education? Perhaps better to use the level directly.

# ---------------------------------------
# Study Completeness for Different Models
# ---------------------------------------

# Count per-variable completeness.
#  Note: level_of_education is 92% complete, years of schooling only 47.6%.
#  Note: has_received_free_school_uniform is 11.48% complete.
#  Note: All other variables are >90% complete.
#  Note: Missingness in income_pc seems to correspond precisely with missingness in poverty.
total_entries = data.shape[0]
for var in dep_vars + indep_vars + ['level_of_education']:
    complete_entries = data[var].dropna().shape[0]
    print("missing values for " + var, ":", total_entries - complete_entries, "/", total_entries, "|| Completeness", 100*complete_entries/total_entries, "%")

# Count completeness by complete series using these data
model_1_vars = dep_vars + indep_vars
print("Completeness for " + ", ".join(model_1_vars) + ":", 1 - data[model_1_vars].notnull().all(axis=1).value_counts()[False]/total_entries)
# 0% complete.

model_2_vars = ['level_of_education'] + indep_vars
print("Completeness for " + ", ".join(model_2_vars) + ":", 1 - data[model_2_vars].notnull().all(axis=1).value_counts()[False]/total_entries)
# Exchange years of schooling for level of education: 11% complete.

model_3_vars = ['level_of_education'] + indep_vars
model_3_vars.remove('has_received_free_school_uniform')
print("Completeness for " + ", ".join(model_3_vars) + ":", 1 - data[model_3_vars].notnull().all(axis=1).value_counts()[False]/total_entries)
# Exchange years of schooling for level of education & remove has_received_free_school_uniform: 91% complete.
# Completeness is 99% without level of education, so this variable definitely leads the problem.

# -----------------------------------------
# Study Completeness for Level of Education
# -----------------------------------------
all_data = data.iloc[data.index[data['person'].notnull()]]['year'].value_counts().reset_index()

missing_per_year = data[data['level_of_education'].isnull()]['year'].value_counts().reset_index()
missing_per_year = (missing_per_year.merge(all_data, on='index')
        .rename({'index': 'year', 'year_x': 'count_missing', 'year_y': 'count_full'}, axis=1)
        .sort_values(by='year'))
missing_per_year['percentage'] = missing_per_year['count_missing']/missing_per_year['count_full']
# Missingness fluctuates from 6% to 9% per year for this variable. We can see if we can model the missingness.

data['missing_level_of_education'] = [1 if pd.isnull(x) else 0 for x in data['level_of_education']]

#TODO: Argue, perhaps in more detail, why we can simply drop the other missing values.

X = pd.get_dummies(data=data[['sex', 'age', 'income_pc', 'poverty']]).dropna()
y = data.iloc[X.index]['missing_level_of_education']
mod = sm.OLS(y, sm.add_constant(X))
res = mod.fit()
print(res.summary())
# --------------------------------------------
# Study Completeness for poverty and income_pc
# --------------------------------------------
all_data = data.iloc[data.index[data['person'].notnull()]]['year'].value_counts().reset_index()

missing_pov_idx = data.index[data['poverty'].isnull()]
missing_inc_idx = data.index[data['income_pc'].isnull()]
missing_pov_idx.equals(missing_inc_idx)
# Returns True: Precisely the same values are missing here. Strange.

pov_count_per_year = data[data['poverty'] == 'pobre']['year'].value_counts().reset_index()
missing_per_year = data[data['poverty'].isnull()]['year'].value_counts().reset_index()
missing_per_year = (missing_per_year.merge(all_data, on='index')
                    .merge(pov_count_per_year, on='index')
                    .rename({'year': 'count_pov', 'index': 'year', 'year_x': 'count_missing', 'year_y': 'count_full'}, axis=1)
                    .sort_values(by='year'))
missing_per_year['percentage_miss'] = missing_per_year['count_missing']/missing_per_year['count_full']
missing_per_year['percentage_pov'] = missing_per_year['count_pov']/missing_per_year['count_full']
missing_per_year['factor'] = missing_per_year['percentage_miss']/missing_per_year['percentage_pov']
# Missingness fluctuates from 1.9% to 0.05% per year for this variable. Is it required to model missingness here? I do
# not think so: In no single year is the percentage of values missing more than 5% of the amount of people self-reporting
# poverty. Since the goal of these variables is precisely to understand the role of self-reporting poverty, this missingness
# can safely be ignored.

# TODO: What does it mean for our model results that missingness in poverty and income_pc is perfectly correlated?
# TODO: Are poverty and income_pc perfectly correlated?
