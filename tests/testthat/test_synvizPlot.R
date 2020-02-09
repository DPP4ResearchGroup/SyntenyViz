context("synvizPlot Data Test")
library(dplyr)
library(GenomicRanges)
library(Gviz)

mycoords.list <- "2:16e7:16.5e7"
mycoords.gr <- coordFormat (mycoords.list)
orgm <- "Hsapiens"
exp_synvizData_Output <- synvizDataTest

testthat::test_that ("If synvizPlot data list can be generated properly", {
  test_out <- synvizPlotData (mycoords.gr, orgm)
  expect_equal (test_out$itrack, exp_synvizData_Output$itrack)
  expect_equal (test_out$gtrack, exp_synvizData_Output$gtrack)
  expect_equal (test_out$atrack, exp_synvizData_Output$atrack)
})
