import SaveAndMergePanel
import numpy as np

# ---------
# Load Data
# ---------
data = SaveAndMergePanel.data

# ----------
# Fix typo's
# ----------
level_of_education_typo = ['educaciÃ³n  media', 'educaciÃ³n bÃ¡sica', 'centro de alfabetizaciÃ³n', 'educación  media']
level_of_education_correct = ['educación media', 'educación básica', 'centro de alfabetización', 'educación media']
level_of_education_correction_dict = dict(zip(level_of_education_typo, level_of_education_correct))
data['level_of_education'] = [level_of_education_correction_dict[x] if x in level_of_education_typo else x for x in data['level_of_education']]

# ---------------------
# Add numerical columns
# ---------------------

# Add level of education as numerical variable
level_of_education = ['ninguno', 'centro de alfabetización', 'primaria', 'secundaria', 'educación básica', 'educación media', 'superior no universitario', 'superior universitario', 'post-grado']
level_of_education_num = [0, 1, 2, 3, 4, 5, 6, 7, 8]
level_of_education_num_dict = dict(zip(level_of_education, level_of_education_num))
data['level_of_education_num'] = [level_of_education_num_dict[x] if x in level_of_education else x for x in data['level_of_education']]

# Add job feeling as numerical variable
job_feeling = ['contento', 'poco contento', 'descontento pero conforme', 'totalmente decontento',
               'no sabe, no responde', np.nan]
job_feeling_num = [4, 3, 2, 1, np.nan, np.nan]  # Is it legit to translate "do not know" to na? Depends on analysis?
job_feeling_num_dict = dict(zip(job_feeling, job_feeling_num))
data['job_feeling_num'] = [job_feeling_num_dict[x] if x in job_feeling else x for x in data['job_feeling']]
