import SaveAndMergePanel
import numpy as np

# ---------
# Load Data
# ---------
data = SaveAndMergePanel.data

# ----------
# Fix typo's
# ----------
_level_of_education_typo = ['educaciÃ³n  media', 'educaciÃ³n bÃ¡sica', 'centro de alfabetizaciÃ³n', 'educación  media']
_level_of_education_correct = ['educación media', 'educación básica', 'centro de alfabetización', 'educación media']
_level_of_education_correction_dict = dict(zip(_level_of_education_typo, _level_of_education_correct))
data['level_of_education'] = [_level_of_education_correction_dict[x] if x in _level_of_education_typo else x for x in data['level_of_education']]


# ------------------
# Change type to int
# ------------------

data.loc[data["daily_hours_internet_use"].apply(lambda x: isinstance(x, str)), "daily_hours_internet_use"] = [
    np.nan for x in data.loc[:, "daily_hours_internet_use"] if isinstance(x, str)
]
data.loc[data["daily_hours_internet_use"].apply(lambda x: ~np.isnan(x)), "daily_hours_internet_use"] = [
    int(x) for x in data.loc[:, "daily_hours_internet_use"] if ~np.isnan(x)
]

# ---------------------
# Add numerical columns
# ---------------------

# Add level of education as numerical variable. Note: primaria and basica, as well as secundaria and media, taken to be the same.
_level_of_education = ['ninguno', 'centro de alfabetización', 'primaria', 'secundaria', 'educación básica', 'educación media', 'superior no universitario', 'superior universitario', 'post-grado']
_level_of_education_num = [0, 1, 2, 3, 2, 3, 4, 5, 6]
_level_of_education_num_dict = dict(zip(_level_of_education, _level_of_education_num))
data['level_of_education_num'] = [int(_level_of_education_num_dict[x]) if x in _level_of_education else np.nan for x in data['level_of_education']]

# Add job feeling as numerical variable
_job_feeling = ['contento', 'poco contento', 'descontento pero conforme', 'totalmente decontento',
               'no sabe, no responde', np.nan]
_job_feeling_num = [4, 3, 2, 1, np.nan, np.nan]  # Is it legit to translate "do not know" to na? Depends on analysis?
_job_feeling_num_dict = dict(zip(_job_feeling, _job_feeling_num))
data['job_feeling_num'] = [_job_feeling_num_dict[x] if x in _job_feeling else x for x in data['job_feeling']]

# Add job feeling as numerical variable
_job_feeling = ['contento', 'poco contento', 'descontento pero conforme', 'totalmente decontento',
               'no sabe, no responde', np.nan]
_job_feeling_num = [4, 3, 2, 1, np.nan, np.nan]  # Is it legit to translate "do not know" to na? Depends on analysis?
_job_feeling_num_dict = dict(zip(_job_feeling, _job_feeling_num))
data['job_feeling_num'] = [_job_feeling_num_dict[x] if x in _job_feeling else x for x in data['job_feeling']]

# Clean age.
# Note: no informa has been changed to nan, and over 98 simply to 98.
set([x for x in data['age'] if not isinstance(x, (int, float))])
_repl_age = {'98 y más': 98,  '98 y mÃ¡s': 98, 'no informa': np.nan}
data['age'] = [_repl_age[x] if x in _repl_age.keys() else x for x in data['age']]

# Add standardized column for age
data['age_st'] = [x for x in (data['age']-data['age'].mean())/2*data['age'].std()]
print(data['age'].mean())  # 31 years
print(data['age'].std())  # 22 years

# Add standardized column for internet usage
data['daily_hours_internet_use_st'] = [x for x in (data['daily_hours_internet_use']-data['daily_hours_internet_use'].mean())/2*data['daily_hours_internet_use'].std()]
print(data['daily_hours_internet_use'].mean())  # 2 hours
print(data['daily_hours_internet_use'].std())  # 2 hours

# Add column female, with 1 for mujer and 0 otherwise
data['female'] = [1 if x == 'mujer' else 0 for x in data['sex']]

# Add column poverty_num, with 1 for in poverty and 0 otherwise
data['poverty_num'] = [1 if x == 'pobre' else 0 if x == 'no pobre' else np.nan for x in data['poverty']]

# Add column medical_insurance_num, with 1 for yes and 0 otherwise
data['no_medical_insurance_num'] = [0 if str(x).strip() == 'si' else 1 if str(x).strip() == 'no' else np.nan for x in data['medical_insurance']]
