#' A list of available TxDB objects as a data.frame
#'
#' orgmTxDB is a data.frame that contains currently available TxDB objects from bioconductor
#'
#' @docType data
#'
#' @usage data(orgmTxDB)
#'
#' @format A data.frame in table format
#'
#' @keywords datasets
#'
#' @source Currently available TxDb objects from
#' \href{http://bioconductor.org/packages/release/BiocViews.html#___AnnotationData}{bioconductor}
#'
#' @family orgTxDB
#'
#' @examples
#' data(orgmTxDB)
#' databaseClass <- orgmTxDB$dbClass
#' databaseSources <- orgmTxDB$dbSource
#' species <- orgmTxDB$dbSpecies
#' speciesAbbraviations <- orgmTxDB$dbAbbv
#' databaseTypes <- orgmTxDB$dbAbbv

"orgmTxDB"
