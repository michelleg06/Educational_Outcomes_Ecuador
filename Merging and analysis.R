library(foreign)
library(plyr)
library(dplyr)
library(haven)
library(data.table)
library(readstata13)

dir <- "C:/Users/alexh_okinaul/PycharmProjects/EducationEcuador/data/Ecuadorian almost-panel/Trimestrales/"
to_transform <- c('id_sector', 'conglomerado', 'panelm', 'vivienda', 'hogar', '^p01$')

ecuador_files <- list.files(dir)
ecuador_dfs <- paste0(dir, ecuador_files) %>%
  lapply(readstata13::read.dta13) %>%
  lapply(data.table::as.data.table)
print('done')

# LEIPE data.table guide
ecuador_dfs[[1]][!is.na(num_tba_prepa), c('new_col1', 'new_col2') := lapply(.SD, sum), .SDcols = c('lpobreza', 'eq0801'), by = 'id_upm']

df <- data.frame(x=c(1,2,3), y=c(4,5,6))

ding <- function(asdf){
  asdf$z <- c(8,9,10)
  
  return(asdf)
}

df2 <- ding(df)


ding2 <- function(dt){
  dt[, z:= c(8,9,10)]
  
  return(dt)
}



  data_t <- data.table(x=c(1,2,3), y=c(4,5,6))
ding(data_t)

new_dt <-ding2(data_t)


data.table::setkey(ecuador_dfs[[1]],'id_upm' )

leipe_dt_1
leipe_dt_2

data.table::merge.data.table(x,y, by=gemeenschappelijkecol, by.x=colnaaminx, by.y=)

leipe_dt_1[leipe_dt_2]
data.table::
# ecuador_data_st2 <- lapply(ecuador_data, mutate_at, vars(matches(to_transform)), as.numeric)

# Does not get past the 11th dataframe: hits a  "cannot allocate vector of size ... ."
ecuador_data <- ecuador_dfs[[1]]
for (i in 2:length(ecuador_dfs)) {
  df <- ecuador_dfs[[i]]
  ecuador_data <- rbind.fill(ecuador_data, df)
  print(i)
}
print('done')

# Throws an error: Class attribute on column 24 of item 8 does not match with 
# column 26 of item 1.
ecuador_data <- data.table::rbindlist(ecuador_dfs, fill=T)
print('done')  

# Throws an error: Can't convert from `$p12b` <labelled<double>> to `$p12b` 
# <labelled<double>> due to loss of precision. How to pay hiervoor? 
ecuador_dfs <- lapply(ecuador_dfs, mutate_at, vars(matches(to_transform)), as.numeric)
ecuador_data <- bind_rows(ecuador_dfs)

print('done')  
hello <- readRDS('ecuador_data_rds.rds')
hello <- fread('ecuador_data.csv')

  
View(ecuador_data)




# I used these lines to test specific parts of the pipeline. 
# I really wanted to use either rbindlist(fill=T) from data.table, or bind_rows
# from dplyr. Both give me errors, the former says precision errors in converting
# from double to double. The latter says that should match, do not. 
test_ec <- read_dta(paste0(dir, ecuador_files[[1]]))
test_ec11 <- read_dta(paste0(dir, ecuador_files[[12]]))
View(test_ec11[,c('sector', 'id_sector')])
View(test_ec$sector)
print("done") 


test_list = list(test_ec, test_ec11) %>% 
  lapply(mutate_at, vars(matches(to_transform)), as.double)
  
rbindlist(test_list, fill=TRUE)


View(test_list)

tib <- mutate_at(test_ec, vars(matches('id_sector')), as.numeric)
ncol(test_ec11)
print(data.class(test_ec11$id_sector))
tib2 <- mutate_at(test_ec11, vars(matches('id_sector')), as.numeric)
ncol(tib2)
print(data.class(tib2$id_sector))
print(data.class(test_list[[2]]$conglomerado))
View(test_list[[2]]$panelm)

View(ecuador_data)


