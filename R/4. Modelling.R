library(data.table)
library(tidyverse)
library(corrplot)
library(multilevel)
library(foreign)
library(lme4)
library(jtools)
source("2. Imputation of missing values.R", echo=T) # Returns cleaned and imputed data_transl data.table. 

# This first attempt at a model contains: hours_worked, sex, age, income_labour,
# has_received_human_dev_bond, years_of_schooling, security_neighb. 


###### 1. Using LMER to understand cluster correlations #####
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

###### 2. Trying a conceptual model with time fixed effects #####
## Note: security_neighb and mobile_has_wifi were omitted. I believe they do not 
## actually vary (all values are NA), at least for some households. 
mod <- lm(hours_worked ~ year + hh_income_pc + sex + age + has_received_human_dev_bond 
          + poverty + used_internet_last12months + has_received_free_school_uniform 
          + has_received_school_breakfast, dat=data_transl)
str(data_transl)
summ(mod)
# Yearly trend, age, internet usage, and number of school breakfasts are significant. 