context("DB retrieval")
library(dplyr)
library(GenomicRanges)

orgm <- "Hsapiens"
target_Orgm <- "TxDb.Hsapiens.UCSC.hg38.knownGene"

testthat::test_that ("TxDb name assemble", {
  expect_equal (getTxDB (orgm, orgmTxDB), target_Orgm)
})

exp_OrgDB_Output = "org.Hs.eg.db"
testthat::test_that ("If OrgDB retrieval can be successfully completed", {
  expect_equal (getOrgDB (orgm ,orgmOrgDB), exp_OrgDB_Output)
})

exp_Message = paste("DONE (", target_Orgm, ")")
exp_TxDB_Output = target_Orgm
testthat::test_that ("If DB retrieval from bioconductor can be successfully completed", {
  expect_equal (getPkgs (orgm, orgmTxDB), exp_TxDB_Output)
  expect_equal (getPkgs (orgm, orgmOrgDB), exp_OrgDB_Output)
})
