## Read orgmTable.csv to form orgmOrgDB data.frame
library(usethis)

orgmOrgDB <- read.csv("data-raw/orgOrgDBTable.csv", header=TRUE, stringsAsFactors = FALSE)
usethis::use_data(orgmOrgDB, overwrite=T)
