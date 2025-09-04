context("multisynvizPlots behavior")

testthat::test_that("multisynvizPlots warns when more than 3 plots requested", {
  orgmsList <- orgmsCollection.init(orgmList)
  orgmsList <- orgmsAdd("Hsapiens", orgmTxDB, "2:16e7:16.5e7", orgmsList)
  orgmsList <- orgmsAdd("Mmusculus", orgmTxDB, "2:6.0e7:6.5e7", orgmsList)
  orgmsList <- orgmsAdd("Rnorvegicus", orgmTxDB, "3:4.6e7:5.1e7", orgmsList)
  orgmsList <- orgmsAdd("Drerio", orgmTxDB, "1:1e6:2e6", orgmsList)
  expect_warning(multisynvizPlots(orgmsList),
                 "Maximum allowed multiplots limit is 3 synteny plots at one time")
})


