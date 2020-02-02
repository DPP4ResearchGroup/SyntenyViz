#' A list contains expected output for test functions.
#'
#' An expected output contains:
#' \describe{
#'   \item{add}{A GRangesList object contains info derived from \code{orgm} = "Hsapiens"
#'      and \code{mycoords.list} is "2:16e7:16.5e7" under tag "add"}
#'   \item{init}{An empty GRangesList under tag "init"}
#' }
#'
#' @docType data
#'
#' @usage data(orgmsCollectionTestResult)
#'
#' @format GRangesList
#'
#' @keywords datasets
#'
#' @family orgmsCollection
#'
#' @source org.Hs.eg.db and TxDb.Hsapiens.UCSC.hg38.knownGene
#'
#' @examples
#' data(orgmsCollectionTestResult)
#' exp_init <- orgmsCollectionTestResult$init
#' exp_add  <- orgmsCollectionTestResult$add

"orgmsCollectionTestResult"
