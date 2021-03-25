###
rm(list=ls())
setwd("~/Desktop/Ecuador_labour")
data <- readRDS("ecuador_data_2.rds")
library(data.table)
library(tidyverse)
library(corrplot)
library(multilevel)
library(foreign)
#write.dta(data, "ecuador_data_2.dta")

dim(data) # rows: 1,114,294    columns: 1,013


###### 1. Labelling vectors ####
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
    'pe03a5', 'pe07', 'pe08', 'pe09a', 'pe09b', 'pia01a'
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
    'illiteracy_rate(15+)', 'average_years_of_schooling', 'hh_income_total', 'hh_size', 'hh_income_pc',
    'economically_innactive_pop', 'economically_active_pop', 'year_of_enrollment',
    'working_equipment_in_institution_1', 'working_equipment_in_institution_2',
    'working_equipment_in_institution_3', 'working_equipment_in_institution_4',
    'working_equipment_in_institution_5', 'has_received_free_school_tests',
    'has_received_free_school_uniform', 'has_received_school_breakfast',
    'frequency_of_school_breakfast', 'has_used_bicycle'
)


data_transl <- data.table::setnames(data[ , ..old_names], old_names, new_names)
str(data_transl) # 1,114,294 obs. of  85 variables

##### 2. Looking at correlations and conditional correlations ####
lapply(data_transl, class) #returns the same as str()

#for the corrplot(corrplot pkg) all vectors need to be numeric
levels(data_transl$sex) # "hombre" "mujer"
sex                <- as.numeric(factor(data_transl$sex)) # hombre = 1, mujer = 2
age                <- as.numeric(as.integer(data_transl$age))
income_labour      <- as.numeric(as.integer(data_transl$income_labour))

ordered(levels(data_transl$level_of_education))
level_of_education <- fct_collapse(factor(data_transl$level_of_education), ninguno = "ninguno", centro_de_alfabetización = c("centro de alfabetización", "centro de alfabetizaciÃ³n"), jardín_de_infantes = c("jardÃn de infantes", "jardín de infantes"), primaria = "primaria", educación_básica = c("educación básica", "educaciÃ³n bÃ¡sica"), secundaria = "secundaria", educación_media = c("educaciÃ³n  media", "educación  media", "educación media"),  superior_no_universitario = "superior no universitario", superior_universitario = "superior universitario", postgrado = "post-grado", NULL = NA)
#data_transl <- data_transl[ data_transl$level_of_education != "centro de alfabetizaciÃ³n" & data_transl$level_of_education != "educaciÃ³n bÃ¡sica" & data_transl$level_of_education != "jardÃn de infantes" & data_transl$level_of_education != "educaciÃ³n  media" & data_transl$level_of_education != "educación  media", drop=FALSE]
#data_transl$level_of_education <- droplevels(data_transl$level_of_education) #at this point we should have 9 ordered categories
level_of_education <- as.numeric(ordered(factor(level_of_education)))

ordered(levels(data_transl$job_feeling))
job_feeling        <- as.numeric(ordered(factor(data_transl$job_feeling)))

hours_worked       <- as.numeric(as.integer(data_transl$hours_worked))

# create a temporary dataframe to feed the corrplot function with
holder <- cbind(income_labour,sex, age, level_of_education,job_feeling,hours_worked)
colSums(is.na(holder)) #checking for missing values (NAs)

corr <- cor(holder, method = "spearman", use = "pairwise.complete.obs") #calculate corr matrix disregarding NAs
corrplot(corr, method = "number", order = "hclust", tl.col = "black")
# a quick glance at variable correlations shows 2 important things: level of education and labour income (.45) are highly correlated, 
#AND job feeling (how happy you are with your job) is positively (and relatively highly) correlated with labour income (.23)
# this is a good start into thinking that perception may influence outcomes

# Look for correlation between level of education and labor income (combination of wage and self-employed)
    # Result for unfiltered data: 0.38. // this was before cleaning the factors! correct one is above (line 85)
    # Result for more than 30 hours worked: 0.43
    # Result for more than 36 hours worked: 0.43
    # Result for more than 36 hours worked and female: 0.52
    # Result for more than 36 hours worked and male: 0.39
    # Result for more than 36 hours worked and earning > minimum wage (400): 0.31
    # Result for more than 36 hours worked and earning > minimum wage (400) and older than 24: 0.37
    # Result for more than 36 hours worked and earning > minimum wage (400) and older than 30: 0.40
    # Result for more than 36 hours worked and earning > minimum wage (400) and older than 40: 0.42
    # Result for more than 36 hours worked and older than 40: 0.53
# Result for more than 36 hours worked and older than 24 and female: 0.57.
# Result for more than 36 hours worked and older than 40 and female: 0.61.
data_filt <- data_transl[hours_worked>36 & age>24 & sex=='mujer']
cor.test(as.numeric(ordered(data_filt[, income_labour])),
         as.numeric(ordered(data_filt[, level_of_education])), 
         method='spearman', 
         exact = F)

###### 3. quickly visualize numeric variables' distribution and get general stats #####
holder <- as.data.frame(holder)
setwd("~/Desktop/Ecuador_labour/visuals")
   
ggplot(data = holder, 
        aes(x=income_labour)) + 
        ggtitle("histogram of labour income") + 
        geom_histogram(breaks=seq(100,5000, by=50),
                       col="black",
                       fill="cornflowerblue") + 
    #theme_bw()
     theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
     panel.background = element_blank())
 # bunched to the left, what we would expect in an unequal country

    ggsave(file="lab_income.eps")
    dev.off()
    
ggplot(data = holder, 
        aes(x=hours_worked)) + 
        ggtitle("histogram of hours worked") + 
        geom_histogram(breaks=seq(1,100, by=10), 
                       col="black",
                       fill="cornflowerblue") + 
        #theme_bw()
        theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))
    #somewhat normally distributed... but with more data on the left side of the bell
    
ggsave(file="hours_worked.eps")
dev.off()
    
# summary statistics of all variables (subset 'holder')
for(i in 1:ncol(holder)){
    x <- holder[,i]
    print(names(holder)[i])
    print(summary(x))
}

# noteworthy: income_labour's minimum value is -1 (?), median age is 26 yrs old, median education is "educación básica" (middle school)

# Define cluster convention (Michelle)
    #socioeconomic
        income_labour
        hours_worked
        sex
        age
        level_of_education
        job_type
        job_category
        income_self_employed
        has_received_human_dev_bond
        amount_human_dev_bond
        income_pc
        has_received_handicap_bond
        amount_handicap_bond
        enrolled_classes
        average_years_of_schooling
        
    #psychosocial (preferences, subjective experience)
        job_feeling
        security_neighb
        sad_due_to_LowIncome
        sad_due_manyworkhours
        poverty # self-perception of being poor or not
        extr_poverty # self-perception of being extremely poor
        
    #environmental (access to physical and technological infrastructure)
        has_received_free_school_uniform
        has_received_school_breakfast
        frequency_of_school_breakfast
        medical_insurance
        social_security
        active_cellular
        mobile_has_wifi
        used_internet_last12months

# Visualization of distributions of relevant variables #done above
# Intracluster correlation
    ## Run a simple hierarchical analysis (multilevel analysis)
        dat  <- data_transl[, c("job_feeling", "conglomerado", "hours_worked")]
        dat2 <-aggregate(dat$hours_worked,list(dat$conglomerado),mean,na.rm=T)
    
        names(dat2)[names(dat2) == "Group.1"] <- "conglomerado"
        names(dat2)[names(dat2) == "x"]       <- "hours_worked_grpMean"
        
        dat3 <- merge(dat, dat2, by= "conglomerado")
        
        dat3$job_feeling <- as.integer(factor(dat3$job_feeling))
        
        mod <- lm(job_feeling~hours_worked+hours_worked_grpMean, data = dat3)
        summary(mod, cor=F)
# if we define conglomerado as our group variable, there is a correlation of the single outcome to the mean of the group
        #aka we do have nested data!
        
    ## make an edgelist where 1 equals similar activitie between two agents and 0 means no similar activity
