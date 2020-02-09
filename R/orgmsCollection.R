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
#' mycoords.list <- "2:15.95e7:16.45e7"
#' orgm.2 <- "Mmusculus"
#' mycoords.list.2 <- "2:6.0e7:6.5e7"
#' orgm.3 <- "Rnorvegicus"
#' mycoords.list.3 <- "3:4.6e7:5.1e7"
#' \donttest{
#'   orgmsList <- orgmsCollection.init (orgmsList)
#'   orgmsList <- orgmsAdd (orgm, orgmTxDB, mycoords.list, orgmsList)
#'   orgmsList <- orgmsAdd (orgm.2, orgmTxDB, mycoords.list.2, orgmsList)
#'   orgmsList <- orgmsAdd (orgm.3, orgmTxDB, mycoords.list.3, orgmsList)
#'   orgmsList
#' }
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

  if (! str_detect(data.class(orgmsCollection), "list()", negate = FALSE)) {
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
  orgmsCollection = list ()
  return (orgmsCollection)
}



