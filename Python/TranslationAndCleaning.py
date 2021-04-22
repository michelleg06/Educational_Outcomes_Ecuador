import SaveAndMergePanel


# ---------
# Load Data
# ---------
data = SaveAndMergePanel.data


# --------------------
# Define the constants
# --------------------

old_names = [
  'area', 'ciudad', 'conglomerado', 'panelm', 'vivienda', 'hogar',
  'p01', 'p02', 'p03', 'p10a', 'p10b', 'p12b', 'p24', 'p41', 'p42', 'p43',
  'p59', 'p63', 'p66', 'p67', 'p68a', 'p69', 'p70a', 'p71a', 'p72a', 'p72b',
  'p73b', 'p74b', 'p75', 'p76', 'p77', 'p78', 'ingrl', 'nnivins', 'id_vivienda',
  'id_hogar', 'id_persona', 'p38','p50', 'p51a', 'p46', 'p44f', 'p44g', 'p07',
  'p11','p15aa','p15bb','p15b1','p15cb','seg011','seg012','seg013','fexp',
  'desempleo','pobreza', 'epobreza', 'rn', 'estrato', 'ingpc', 'pt01a', 'pt1a',
  'pt1b1', 'pt02', 'p60a', 'p60b', 'pt08', 'p40a1', 'analfa', 'escolaridad', 'ih',
  'hsize', 'ipcf', 'pei', 'pea', 'pe02b', 'pe03a1', 'pe03a2', 'pe03a3', 'pe03a4',
  'pe03a5', 'pe07', 'pe08', 'pe09a', 'pe09b', 'pia01a',
  'year'
]

new_names = [
  'area', 'city', 'conglomerado', 'panelm', 'household_id', 'home_id',
  'person', 'sex', 'age', 'level_of_education', 'graduation_year',
  'obtained_title', 'hours_worked', 'job_type', 'job_category', 'job',
  'job_feeling', 'income_self_employed', 'income_wage_and_domestic',
  'employee_discounts', 'is_income_in_kind', 'income_wage_and_domestic_job_2',
  'is_income_in_kind_job_2', 'income_capital', 'income_capital_transactions',
  'income_retirement_pension', 'income_gift_donation', 'income_from_abroad',
  'has_received_human_dev_bond', 'amount_human_dev_bond',
  'has_received_handicap_bond', 'amount_handicap_bond', 'income_labour',
  'id_hh', 'id_home', 'id_p', 'reason4_leavejob', 'numberof_jobs',
  'hours_worked1', 'placeof_work', 'social_security', 'medical_insurance', 'enrolled_classes',
  'reads_writes','current_school_year','place_of_birth','place_of_residence','year_arrival_ecuador',
  'residence_5yearsago','security_house', 'security_neighb', 'security_city', 'expansion_factor',
  'unemployed_pop', 'poverty', 'extr_poverty','natural_regions','stratum', 'income_pc', 'active_cellular',
  'cellular_is_smartphone','mobile_has_wifi', 'used_internet_last12months',
  'sad_due_to_LowIncome', 'sad_due_manyworkhours', 'daily_hours_internet_use', 'province_or_country',
  'illiteracy_rate(15+)', 'years_of_schooling', 'hh_income_total', 'hh_size', 'hh_income_pc',
  'economically_innactive_pop', 'economically_active_pop', 'year_of_enrollment',
  'working_equipment_in_institution_1', 'working_equipment_in_institution_2',
  'working_equipment_in_institution_3', 'working_equipment_in_institution_4',
  'working_equipment_in_institution_5', 'has_received_free_school_tests',
  'has_received_free_school_uniform', 'has_received_school_breakfast',
  'frequency_of_school_breakfast', 'has_used_bicycle',
  'year'
]
