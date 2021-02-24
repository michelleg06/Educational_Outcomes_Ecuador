library(data.table)

data <- readRDS("ecuador_data.rds")

old_names = c(
  'area', 'city', 'conglomerado', 'panelm', 'vivienda', 'hogar', 
  'p01', 'p02', 'p03', 'p10a', 'p10b', 'p12b', 'p24', 'p41', 'p42', 'p43', 
  'p59', 'p63', 'p66', 'p67', 'p68a', 'p69', 'p70a', 'p71a', 'p72a', 'p72b', 'p73b',
  'p74b', 'p75', 'p76', 'p77', 'p78', 'ingrl', 'nnivins', 'id_vivienda', 'id_hogar', 
  'id_persona'
  
  
  )

new_names = c(
  'area', 'city', 'conglomerado', 'panelm', 'household', 'home', 
  'person', 'sex', 'age', 'level_of_education', 'graduation_year', 'obtained_title',
  'hours_worked', 'job_type', 'job_category', 'job', 'job_feeling', 'income_self_employed',
  'income_wage_and_domestic', 'employee_discounts', 'is_income_in_kind', 
  'income_wage_and_domestic_job_2', 'is_income_in_kind_job_2', 'income_capital', 
  'income_capital_transactions', 'income_retirement_pension', 'income_gift_donation',
  'income_from_abroad', 'has_received_human_dev_bond', 'amount_human_dev_bond',
  'has_received_handicap_bond', 'amount_handicap_bond', 'income_labour', 'level_of_instruction',
  'id_hh', 'id_home', 'id_p'
  )

data.table::setnames(data, ci)

