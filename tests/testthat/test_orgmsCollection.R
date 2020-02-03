context("Multi Orgms Search Query Testing")
library (stringr)
library (rlist)

orgm <- "Hsapiens"
mycoords.list <- "2:16e7:16.5e7"

exp_orgmsCollection.init_Output <- orgmsCollectionTestResult$init
exp_orgmsAdd_Output <- orgmsCollectionTestResult$add

testthat::test_that ("Test GRange object append", {
  orgmList <- orgmsCollection.init(orgmList)
  orgmListAdd <- orgmsAdd(orgm, orgmTxDB, mycoords.list, orgmList)

  expect_equivalent( orgmList, exp_orgmsCollection.init_Output)
  expect_equivalent( orgmListAdd, exp_orgmsAdd_Output)
})



