###
rm(list=ls())
setwd("~/Desktop/Ecuador_labour")
data <- readRDS("ecuador_data.rds")
library(data.table)
library(tidyverse)
library(corrplot)
library(multilevel)
library(foreign)
library(lme4)
library(jtools)
#write.dta(data, "ecuador_data_2.dta")

dim(data) # rows: 1,114,294    columns: 1,013


###### 1. Labelling vectors, cleaning ####
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

#Remove typo's 
level_of_education_typo <- c('educaciÃ³n  media', 'educaciÃ³n bÃ¡sica', 'centro de alfabetizaciÃ³n', 'educación  media')
level_of_education_correct <- c('educación media', 'educación básica', 'centro de alfabetización', 'educación media')

dat_join <- data.table(old=level_of_education_typo, new=level_of_education_correct)
data_transl[dat_join, on=c(level_of_education='old'), level_of_education:=new]

#Add level of education as numerical variable
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
    #clusters
        person #l1
        household_id #l2
        home_id #l3
        conglomerado #l4
        city #l5
        
    
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
        years_of_schooling
        
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
        area #urban vs rural, I think
        
    # First model attempt contains 
        hours_worked
        sex
        age
        income_labour
        has_received_human_dev_bond
        years_of_schooling
        security_neighb
        
## Correlating to find proxies 
cor.test(data_transl[, years_of_schooling],
         data_transl[, level_of_education_num], 
         method='spearman', 
         exact = F)
# Correlation between years of schooling and level of education is 0.94. 
# Will now use avg years of schooling as numerical proxy for level of education. 

cor.test(data_transl[, years_of_schooling],
         data_transl[, job_feeling_num], 
         method='spearman', 
         exact = F)
# Correlation between years of schooling and job satisfaction is only 0.13. 
# Suggests that studying well-being requires a much broader outlook 


###### 4. Using LMER to understand cluster correlations #####
## Checking for ICC in three possible variables. Note: g1/g2 means g1 contains g2.
# However, g2:g1 means g2 is contained in g1: The order switches. 
m1 <- lmer(income_labour ~ 1 + (1|city/conglomerado), data=data_transl, REML=FALSE)
summ(m1)
# This model adds a random effect based on city, and conglomerado per city. 
# conglomerado per city has higher ICC (0.13), city becomes negligible (0.00)

m1 <- lmer(level_of_education_num ~ 1 + (1|city/conglomerado), data=data_transl, REML=FALSE)
summ(m1)
# This model adds a random effect based on city, and conglomerado per city. 
# conglomerado per city has high ICC; (0,16), city remains significant (0.08)

m1 <- lmer(years_of_schooling ~ 1 + (1|city/conglomerado), data=data_transl, REML=FALSE)
summ(m1)
# This model adds a random effect based on city, and conglomerado per city. 
# conglomerado per city has high ICC; (0,16), city is now smaller (0.01)
# Suggests that the translation of years of schooling to level of education 
# perhaps depends on city-specific effects? 

m1 <- lmer(job_feeling_num ~ 1 + (1|city/conglomerado), data=data_transl, REML=FALSE)
summ(m1)
# This model adds a random effect based on city, and conglomerado per city. 
# we are finding a low correlation here for job satisfaction; 0.07 at the level 
# of conglomerado, and only 0.02 at the level of cities. Perhaps better to skip. 

## Further exploration and modeling of level of education
m1 <- lmer(level_of_education_num ~ 1 + (1|conglomerado:city), data=data_transl, REML=FALSE)
summ(m1)
# Here ICC for conglomerado's as varying within cities is 0.29; some of this can 
# be explained by inter-city variance, suggests the above model

m1 <- lmer(level_of_education_num ~ 1 + (1|conglomerado), data=data_transl, REML=FALSE)
summ(m1)
# ICC drops to 0.24 when not accounting for different conglomerado's in cities themselves. 

m1 <- lmer(level_of_education_num ~ 1 + (1|city), data=data_transl, REML=FALSE)
summ(m1)
# Only city is 0.08. It appears conglomerado's are more important than 
# cities. 

## Further exploration and modeling of years of schooling
m1 <- lmer(years_of_schooling ~ 1 + (1|conglomerado:city), data=data_transl, REML=FALSE)
summ(m1)
# Here ICC for conglomerado's as varying within cities is 0.19. This captures most
# of the variance, it seems. 

m1 <- lmer(years_of_schooling ~ 1 + (1|conglomerado), data=data_transl, REML=FALSE)
summ(m1)
# ICC drops to 0.07 when not accounting for different conglomerado's in cities themselves. 

m1 <- lmer(years_of_schooling ~ 1 + (1|city), data=data_transl, REML=FALSE)
summ(m1)
# Only city is 0.15. It appears conglomerado's are more important than cities, 
# but somehow less than for level of education. This would imply that there are 
# some cities that, with less years of schooling, achieve the same levels of 
# education. 
# I do not really know how to interpret the fact that, city ICC is similar to 
# conglomerado in city ICC. 


## I will set up the model as follows: 
# - dependent variable: hours of schooling. This because I do not know how to 
# correctly model categorical variables. 
# - a random effect for individual characteristics such as intelligence.
# - Then, I will look at each of the variables relevant for determining years of 
# schooling: sex, age, amount_human_dev_bond to determine what cluster correlations
# to add. 
# - finally, I will add the relevant cluster variables. To find out what is "relevant"
# I will compare the model at three levels (congl:city), (congl/city), (city). 

### Years of schooling and age 
m1 <- lmer(years_of_schooling ~ age + (age|city/conglomerado), data=data_transl, REML=FALSE)
summ(m1)
# There seems to be a very low std. dev. for age varied over city/congl. Probably
# I can leave that as a purely individual variable. 

m1 <- lmer(years_of_schooling ~ age + (age|conglomerado:city), data=data_transl, REML=FALSE)
summ(m1)
# Again, low std. dev. for random effects for age at congl:city level. Can omit. 

### Years of schooling and sex
m1 <- lmer(years_of_schooling ~ sex + (sex|city/conglomerado), data=data_transl, REML=FALSE)
summ(m1)
# We find the largest effect (ICC of 0.15 and standard deviation of 1.89) at the level of 
# cities. It appears that women in some cities perform better/worse than in others. 

m1 <- lmer(years_of_schooling ~ sex + (sex|conglomerado:city), data=data_transl, REML=FALSE)
summ(m1)
# Lower std. dev. for random effects for sex at congl:city level (0.76, but ICC 
# 0.17)

m1 <- lmer(years_of_schooling ~ sex + (sex|city), data=data_transl, REML=FALSE)
summ(m1)
# Std deviation of 1.01 now. Perhaps more is absorbed by the city intercept. 
# it is a simpler addition, so perhaps better to start with this than with 
# city/conglomerado. 

### Years of schooling and Human Dev Bond
# Do this later. Not so relevant yet. 

## The model: y = beta_0 + beta_1 age + beta_2 city + beta_3 conglomerado:city
## + beta_4 sex:city. Sort of; I need to figure out how exactly to write down 
## the random effect of sex per city. 
m1 <- lmer(years_of_schooling ~ age + (sex|city) + (1|conglomerado:city), 
           data=data_transl, REML=FALSE)
summ(m1)
# Well. This gives some result. I need to apparently remove missing values 
# to calculate r-sq. 

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

###### 5. Trying a conceptual model with time fixed effects #####
## Note: security_neighb and mobile_has_wifi were omitted. I believe they do not 
## actually vary, at least for some households. 
mod <- lm(hours_worked ~ year + hh_income_pc + sex + age 
              + has_received_human_dev_bond 
          + poverty 
          #+ security_neighb 
          #+ mobile_has_wifi
                    
          + used_internet_last12months 
          + has_received_free_school_uniform + has_received_school_breakfast, dat=data_transl)
str(data_transl)
summ(mod)
        
    ## make an edgelist where 1 equals similar activitiesbetween two agents and 0 means no similar activity
