###
rm(list=ls())
setwd("~/Desktop/Ecuador_labour")
data <- readRDS("ecuador_data_2.rds")
library(data.table)
library(tidyverse)
library(corrplot)
library(multilevel)

dim(data) # rows: 1,114,294    columns: 1,013


###### 1. Labelling vectors ####
old_names <- c(
    'area', 'ciudad', 'conglomerado', 'panelm', 'vivienda', 'hogar', 
    'p01', 'p02', 'p03', 'p10a', 'p10b', 'p12b', 'p24', 'p41', 'p42', 'p43', 
    'p59', 'p63', 'p66', 'p67', 'p68a', 'p69', 'p70a', 'p71a', 'p72a', 'p72b', 
    'p73b', 'p74b', 'p75', 'p76', 'p77', 'p78', 'ingrl', 'nnivins', 'id_vivienda',
    'id_hogar', 'id_persona'
)

new_names <- c(
    'area', 'city', 'conglomerado', 'panelm', 'household', 'home', 
    'person', 'sex', 'age', 'level_of_education', 'graduation_year', 
    'obtained_title', 'hours_worked', 'job_type', 'job_category', 'job', 
    'job_feeling', 'income_self_employed', 'income_wage_and_domestic', 
    'employee_discounts', 'is_income_in_kind', 'income_wage_and_domestic_job_2', 
    'is_income_in_kind_job_2', 'income_capital', 'income_capital_transactions', 
    'income_retirement_pension', 'income_gift_donation', 'income_from_abroad', 
    'has_received_human_dev_bond', 'amount_human_dev_bond', 
    'has_received_handicap_bond', 'amount_handicap_bond', 'income_labour', 
    'level_of_instruction', 'id_hh', 'id_home', 'id_p'
)

data_transl <- data.table::setnames(data[ , ..old_names], old_names, new_names)


##### 2. Looking at correlations and conditional correlations ####
lapply(data_transl, class)

#for the corrplot(corrplot pkg) all vectors need to be numeric
levels(data_transl$sex) # "hombre" "mujer"
sex                <- as.numeric(factor(data_transl$sex)) # hombre = 1, mujer = 2
age                <- as.numeric(as.integer(data_transl$age))
income_labour      <- as.numeric(as.integer(data_transl$income_labour))

ordered(levels(data_transl$level_of_education))
level_of_education <- as.numeric(ordered(factor(data_transl$level_of_education)))

ordered(levels(data_transl$job_feeling))
job_feeling        <- as.numeric(ordered(factor(data_transl$job_feeling)))

hours_worked       <- as.numeric(as.integer(data_transl$hours_worked))

# create a temporary dataframe to feed the corrplot function with
holder <- cbind(income_labour,sex, age, level_of_education,job_feeling,hours_worked)
colSums(is.na(holder)) #checking for missing values (NAs)

corr <- cor(holder, method = "spearman", use = "pairwise.complete.obs") #calculate corr matrix disregarding NAs
corrplot(corr, method = "number", order = "hclust", tl.col = "black")
# a quick glance at variable correlations shows nothing interesting

# Look for correlation between level of education and labor income (combination of wage and self-employed)
    # Result for unfiltered data: 0.38.
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

###### 3. quickly visualize numeric variables' distribution and getting general stats #####
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

    
ggsave(file="hours_worked.eps")
dev.off()
    
# summary statistics of all variables (subset 'holder')
for(i in 1:ncol(holder)){
    x <- holder[,i]
    print(names(holder)[i])
    print(summary(x))
}

# Define cluster convention (Michelle)
    #socioeconomic
        income_labour
        hours_worked
        sex
        age
        level_of_education
    #psychosocial (preferences, subjective experience)
        job_feeling
        
    #environmental (access to physical and technological infrastructure)

# Visualization of distributions of relevant variables
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
# Define an interaction matrix
    ## make an edgelist where 1 equals similar activitie between two agents and 0 means no similar activity
