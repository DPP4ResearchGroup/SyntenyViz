#' A list of available orgDB objects as a data.frame
#'
#' orgmOrgDB is a data.frame that contains currently available orgDB objects from bioconductor
#'
#' @docType data
#'
#' @usage data(orgmOrgDB)
#'
#' @format
#'
#' @keywords datasets
#'
#' @source Currently available orgDB objects from
#' \href{http://bioconductor.org/packages/release/BiocViews.html#___AnnotationData}{bioconductor}
#'
#' @family orgmOrgDB
#'
#' @examples
#' data(orgmOrgDB)
#' databaseClass <- orgmOrgDB$dbClass
#' databaseSources <- orgmOrgDB$dbSource
#' species <- orgmOrgDB$dbSpecies
#' databaseTypes <- orgmOrgDB$dbAbbv

"orgmOrgDB"
