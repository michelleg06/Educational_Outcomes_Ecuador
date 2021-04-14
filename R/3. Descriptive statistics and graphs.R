library(data.table)
library(tidyverse)
library(corrplot)
library(multilevel)
library(foreign)
source("2. Imputation of missing values.R", echo=T) # Returns cleaned and imputed data_transl data.table. 

##### 1. Looking at correlations and conditional correlations ####
lapply(data_transl, class) #returns the same as str()

#for the corrplot(corrplot pkg) all vectors need to be numeric
levels(data_transl$sex) # "hombre" "mujer"
sex                <- as.numeric(factor(data_transl$sex)) # hombre = 1, mujer = 2
age                <- as.numeric(as.integer(data_transl$age))
income_labour      <- as.numeric(as.integer(data_transl$income_labour))

ordered(levels(data_transl$level_of_education))


# TODO: Rewrite the code block below neatly into the translation and cleaning file. 
level_of_education <- fct_collapse(factor(data_transl$level_of_education), ninguno = "ninguno", centro_de_alfabetización = c("centro de alfabetización", "centro de alfabetizaciÃ³n"), jardín_de_infantes = c("jardÃn de infantes", "jardín de infantes"), primaria = "primaria", educación_básica = c("educación básica", "educaciÃ³n bÃ¡sica"), secundaria = "secundaria", educación_media = c("educaciÃ³n  media", "educación  media", "educación media"),  superior_no_universitario = "superior no universitario", superior_universitario = "superior universitario", postgrado = "post-grado", NULL = NA)
data_transl <- data_transl[ data_transl$level_of_education != "centro de alfabetizaciÃ³n" & data_transl$level_of_education != "educaciÃ³n bÃ¡sica" & data_transl$level_of_education != "jardÃn de infantes" & data_transl$level_of_education != "educaciÃ³n  media" & data_transl$level_of_education != "educación  media", drop=FALSE]
data_transl$level_of_education <- droplevels(data_transl$level_of_education) #at this point we should have 9 ordered categories
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
# TODO: Rewrite the code block above neatly into the translation and cleaning file. 

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


###### 2. quickly visualize numeric variables' distribution and get general stats #####
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
