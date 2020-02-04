#'orgmsAdd
#'Add a new search target in GRange format into GRangeList
#'
#' @inheritParams getPkgs
#' @inheritParams getTxDB
#' @inheritParams coordFormat
#' @inheritParams geneSubset
#' @param orgmsCollection A GRangesList object that contains a list of search targets in GRange form
#'
#' @return orgmsCollection A GRangesList of search targets in GRange form
#'
#' @family orgmsCollection
#' @export
#' @examples
#' orgm <- "Hsapiens"
#' mycoords.list <- "2:16e7:16.5e7"
#' orgmsList <- orgmsCollection.init (orgmsList)
#' orgmsAdd (orgm, mycoords.list, orgmsList)
orgmsAdd <- function (orgm, orgTxDB, mycoords.list, orgmsCollection) {
  mycoords.gr <- coordFormat (mycoords.list = mycoords.list)

  orgIndex <- match (orgm, orgTxDB$dbSpecies)
  if (!is.na(orgIndex)) {
    genome(mycoords.gr) <- orgTxDB$dbAbbv[orgIndex]
  } else {
    warning (paste (orgm, "is not available, please select a different organism or checking your spelling"))
    returnValue()
    stop()
  }

  if (! str_detect(data.class(orgmsCollection), "GRangesList", negate = FALSE)) {
    geterrmessage()
    stop ("GRangesList object is not available, please initialize the object first using function orgmsCollection.init")
  }

  listTag <- length (orgmsCollection) + 1
  orgmsCollection <- append (orgmsCollection, mycoords.gr, after = listTag)
  return (orgmsCollection)
}

#'orgmsCollection.init
#'Initiate the orgmsCollection to an empty GRangeList
#'
#' @inheritParams orgmsAdd
#'
#' @return A empty GRangesList object
#'
#' @export
#' @family orgmsCollection
#' @examples
#' orgmsList <- orgmsCollection.init (orgmsList)
orgmsCollection.init <- function (orgmsCollection) {
  orgmsCollection = GRangesList()
  return (orgmsCollection)
}



