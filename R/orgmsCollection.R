#'orgmsAdd
#'Add a new search target in GRange format into GRangeList
#'
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
#'
orgmsAdd <- function (orgm, mycoords.list, orgmsCollection) {
  mycoord.gr <- coordFormat (mycoords.list = mycoords.list)

  if (! str_detect(data.class(orgmsCollection), "GRangesList", negate = FALSE)) {
    geterrmessage()
    stop ("GRangesList object is not available, please initialize the object first using function orgmsCollection.init")
  }

  listTag <- length (orgmsCollection) + 1
  orgmsCollection <- append (orgmsCollection, mycoord.gr, after = listTag)
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
#' orgmsCollection.init (orgmsCollection)
orgmsCollection.init <- function (orgmsCollection) {
  orgmsCollection = GRangesList()
  return (orgmsCollection)
}
