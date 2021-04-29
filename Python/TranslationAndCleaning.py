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

# ---------------------
# Add numerical columns
# ---------------------

# Add level of education as numerical variable
_level_of_education = ['ninguno', 'centro de alfabetización', 'primaria', 'secundaria', 'educación básica', 'educación media', 'superior no universitario', 'superior universitario', 'post-grado']
_level_of_education_num = [0, 1, 2, 3, 4, 5, 6, 7, 8]
_level_of_education_num_dict = dict(zip(_level_of_education, _level_of_education_num))
data['level_of_education_num'] = [_level_of_education_num_dict[x] if x in _level_of_education else x for x in data['level_of_education']]

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
