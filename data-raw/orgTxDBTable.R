## Read orgmTable.csv to form orgmTxDB data.frame
library(usethis)

orgmTxDB <- read.csv("data-raw/orgmTxDBTable.csv", stringsAsFactors = FALSE)
usethis::use_data(orgmTxDB, overwrite=T)
