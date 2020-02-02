context("Multi Orgms Search Query Testing")
library (stringr)
library (rlist)

orgm <- "Hsapiens"
mycoords.list <- "2:16e7:16.5e7"

exp_orgmsCollection.init_Output <- orgmsCollectionTestResult$init
exp_orgmsAdd_Output <- orgmsCollectionTestResult$add

testthat::test_that ("Test GRange object append", {
  orgmList <- orgmsCollection.init(orgmList)
  orgmListAdd <- orgmsAdd(orgm, mycoords.list, orgmList)

  expect_equal( orgmList, exp_orgmsCollection.init_Output)
  expect_equal( orgmListAdd, exp_orgmsAdd_Output)
})



