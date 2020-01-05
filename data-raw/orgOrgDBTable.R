## Read orgmTable.csv to form orgmOrgDB data.frame
library(usethis)

orgmOrgDB <- read.csv("data-raw/orgDBTable.csv", stringsAsFactors = FALSE)
usethis::use_data(orgmOrgDB, overwrite=T)
