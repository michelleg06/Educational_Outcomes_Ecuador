library(data.table)

#### 1. Dropping environment and importing raw panel ####
rm(list=ls())
data <- readRDS("ecuador_data.rds")

#### 2. Labelling vectors, cleaning ####
old_names <- c(
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
)

new_names <- c(
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
)


data_transl <- data.table::setnames(data[ , ..old_names], old_names, new_names)
str(data_transl) # 1,114,294 obs. of  85 variables

#### 3. Removing typo's ####
level_of_education_typo <- c('educaciÃ³n  media', 'educaciÃ³n bÃ¡sica', 'centro de alfabetizaciÃ³n', 'educación  media')
level_of_education_correct <- c('educación media', 'educación básica', 'centro de alfabetización', 'educación media')

dat_join <- data.table(old=level_of_education_typo, new=level_of_education_correct)
data_transl[dat_join, on=c(level_of_education='old'), level_of_education:=new]

#### 4. Adding new columns ####

# Level of education as numerical variable
level_of_education <- c('ninguno', 'centro de alfabetización', 'primaria', 'secundaria', 'educación básica', 'educación media', 'superior no universitario', 'superior universitario', 'post-grado')
level_of_education_num <- c(0, 1, 2, 3, 4, 5, 6, 7, 8)

dat_join <- data.table(level_of_education=level_of_education, level_of_education_num=level_of_education_num)
data_transl <- data_transl[dat_join, on=c(level_of_education = 'level_of_education')]

#Add job feeling as numerical variable
job_feeling_old = c('contento', 'poco contento', 'descontento pero conforme', 
                    'totalmente decontento', 'no sabe, no responde', NA)
job_feeling_new = c(4, 3, 2, 1, NA, NA)

data_transl[job_feeling=='no sabe, no responde', job_feeling:=rep(NA, length=.N)] 

dat_join <- data.table(job_feeling = job_feeling_old, job_feeling_num = job_feeling_new)
data_transl <- data_transl[dat_join, on=c(job_feeling='job_feeling')]
