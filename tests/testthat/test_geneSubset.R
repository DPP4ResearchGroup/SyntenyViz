context("Gene Subset")
library(dplyr)
library(GenomicRanges)

mycoords.list <- "2:16e7:16.5e7"
mycoords.gr <- coordFormat (mycoords.list)
orgm <- "Hsapiens"
exp_getSubset_Output <- geneSubsetTestResult
exp_getSubset_chr_Output <- "chr2"

testthat::test_that ("If gene subset can be performed correctly", {
  test_out <- geneSubset (mycoords.gr, orgm)
  expect_equal (test_out$geneListsorted, exp_getSubset_Output)
  expect_equal (test_out$chr, exp_getSubset_chr_Output)
})

