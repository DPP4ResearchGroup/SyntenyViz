## Read orgmTable.csv to form orgmTxDB data.frame

orgmTxDB <- read.csv("data-raw/orgmTxDBTable.csv")
save(orgmTxDB, file="data/orgmTxDB.RData")
