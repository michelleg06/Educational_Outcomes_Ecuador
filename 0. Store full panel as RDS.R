glibrary(dplyr)
library(data.table)
library(readstata13)

#-----------#
# Wrangling #
#-----------#

dir <- "C:/Users/alexh_okinaul/PycharmProjects/EducationEcuador/data/Ecuadorian almost-panel/Trimestrales/"

# Import data
ecuador_files <- list.files(dir)
ecuador_dfs <- paste0(dir, ecuador_files) %>%
  lapply(readstata13::read.dta13) %>%
  lapply(data.table::as.data.table)
print('done')

# Add year column
year = 2007
for (table in ecuador_dfs) {
  table[, year := year]
  year <- year + 1
}

# Concatenate all individual yearly panels
ecuador_data <- data.table::rbindlist(ecuador_dfs, fill=T)
print('done')  

# Save full panel as RDS
saveRDS(ecuador_data, file = "ecuador_data.rds")