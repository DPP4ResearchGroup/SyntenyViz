## Read SynVizOrgms.csv to form SynVizOrgms data.frame
library(usethis)

SynVizOrgms <- read.csv("data-raw/SynVizOrgms.csv", stringsAsFactors = FALSE)
usethis::use_data(SynVizOrgms, overwrite=T)
