# Networks in Ecuador
 Educational and Labour Networks

## Data
The dataset used can be downloaded at: https://drive.google.com/drive/folders/1V55ahzgc2SWl3GkebYUg814jbh7UQ-7p?usp=sharing. The most important variables are outlined below. Some information on the dataset:
...

## The code
Some notes:
* The cleaning, analysis, and modelling workflow is separeted into five files:
   0. Store full panel as RDS.R. This file loads the yearly panel, merges it into a single table, and stores it as an RDS.
   1. Translation and cleaning.R. Currently translates the Spanish column names into English, adds some necessary columns, and fixes some typo's. This is where cleaning and defining of new variables takes place.
   2. Imputation of missing values.R. Currently empty, but this is where we will impute the required variables.
   3. Descriptive statistics and graphs.R. For the generation of graphs and statistics.
   4. Modelling.R. Contains the hierarchical mixed model, and some tests associated to its creation. Also contains the more simple fixed effects model based on some variables.
* We do not currently use pull requests, so some mild awareness is required of who is tasked with working within each file. We believe that this should be fine with out current project size, but will re-evaluate if we run into problems.
* Comments are used in two ways: as titles of a particular section above the code, and to note some interesting results below the code.

### Define cluster convention
**Clusters**
* person (level 1)
* household_id (level 2)
* home_id (level 3)
* conglomerado (level 4)
* city (level 5)

**Socioeconomic**
* income_labour
* hours_worked
* sex
* age
* level_of_education
* job_type
* job_category
* income_self_employed
* has_received_human_dev_bond
* amount_human_dev_bond
* income_pc
* has_received_handicap_bond
* amount_handicap_bond
* enrolled_classes
* years_of_schooling

**Psychosocial (preferences, subjective experience)**
* job_feeling
* security_neighb
* sad_due_to_LowIncome
* sad_due_manyworkhours
* poverty (self-perception of being poor or not)
* extr_poverty (self-perception of being extremely poor)

**Environmental (access to physical and technological infrastructure)**
* has_received_free_school_uniform
* has_received_school_breakfast
* frequency_of_school_breakfast
* medical_insurance
* social_security
* active_cellular
* mobile_has_wifi
* used_internet_last12months
* area (urban vs rural, I think)

## Next steps
### Define cluster convention (Michelle)
### Visualization of distributions of relevant variables
### Intracluster correlation
#### Run a simple hierarchical analysis (multilevel analysis)
### Define an interaction matrix
#### make an edgelist where 1 equals similar activitie between two agents and 0 means no similar activity
