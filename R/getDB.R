#' Search for orgDB
#'
#' Search if there is a corresponding annotation database orgDB is available for the given organism.
#'
#' @section getDB complementing functions:
#' A collection of complementing functions that required by the main functions:
#' \code{getPkgs}
#' , which includes following functions:
#' \enumerate{
#'   \item{\code{getOrgDB}}
#'   \item{\code{getTxDB}}
#' }
#'
#' @family orgmOrgDB
#' @family getDB
#'
#' @param orgm An organism that of interest. Options include:\cr
#' Btaurus(Bt) - Bos taurus - Cow \cr
#' Celegans(Ce) - Caenorhabditis elegans - Roundworm \cr
#' Cfamiliaris(Cf) - Canis familiaris - Dog \cr
#' Dmelanogaster(Dm) - Drosophila melanogaster - Fruitfly \cr
#' Drerio(Dr) - Danio rerio - Zebrafish \cr
#' Ggallus(Gg) - Gallus gallus - Chicken \cr
#' Hsapiens(Hs) - Homo Sapiens - Human \cr
#' Mmulatta(Mmu) - Macaca mulatta - Rhesus macaque \cr
#' Mmusculus(Mm) - Mus musculus - House mouse \cr
#' Ptroglodytes(Pt) - Pan troglodytes - Chimpanzee \cr
#' Rnorvegicus(Rn) - Rattus norvegicus - Brown rat \cr
#' Scerevisiae(Sc) - Saccharomyces cerevisiae - Brewer's yeast \cr
#' Sscrofa(Ss) - Sus scrofa - Wild swine
#'
#' @param orgOrgDB A data.frame that contains available orgDB object, e.g. \code{\link{orgmOrgDB}}.
#'
#' @export
#' @examples
#' orgm <- "Hsapiens"
#' getOrgDB(orgm,orgmOrgDB)
getOrgDB <- function (orgm, orgOrgDB) {
  if (!orgm == "Mmulatta") {
    orgAbbrv <- substring (orgm, 1, 2)
  } else {
    orgAbbrv <- "Mmu"
  }
  orgIndex <- match (orgAbbrv, orgOrgDB$dbSpecies)
  if (!is.na(orgIndex)) {
    orgmTargetOrgDb <- paste (orgOrgDB$dbClass[orgIndex],
                              orgOrgDB$dbSpecies[orgIndex],
                              orgOrgDB$dbSource[orgIndex],
                              orgOrgDB$dbType[orgIndex],
                              sep='.')
    return (orgmTargetOrgDb)
  } else {
    warning (paste (orgm, "is not available, please select a different organism or checking your spelling"))
    returnValue()
  }
}

#'Search for TxDB
#'
#' Search if there is a corresponding annotation database TxDB is available for the given organism.
#'
#' @section getDB complementing functions:
#' A collection of complementing functions that required by the main functions:
#' \code{getPkgs}
#' , which includes following functions:
#' \enumerate{
#'   \item{\code{getOrgDB}}
#'   \item{\code{getTxDB}}
#' }
#'
#' @export
#' @inheritParams getOrgDB
#' @param orgTxDB A data.frame that contains currently TxDB objects, e.g. \code{\link{orgmTxDB}}.
#' @family orgTxDB
#' @family getDB
#' @examples
#' orgm <- "Hsapiens"
#' getTxDB (orgm, orgmTxDB)
getTxDB <- function (orgm, orgTxDB) {
  orgIndex <- match (orgm, orgTxDB$dbSpecies)
  if (!is.na(orgIndex)) {
    orgmTargetDb <- paste (orgTxDB$dbClass[orgIndex],
                           orgTxDB$dbSpecies[orgIndex],
                           orgTxDB$dbSource[orgIndex],
                           orgTxDB$dbAbbv[orgIndex],
                           orgTxDB$dbType[orgIndex],
                           sep='.')
    return (orgmTargetDb)
  } else {
    warning (paste (orgm, "is not available, please select a different organism"))
    returnValue()
  }
}

#'Download organism AnnotationDbi
#'
#'Download required AnnotationDbi class object if there is a corresponding database is available
#'for the given organism.
#'
#' @section getDB main function:
#' main function includes: \code{getPkgs}
#'
#' @export
#' @inheritParams getOrgDB
#' @param orgDB A data.frame collection that contains available AnnotationDbi objs.
#'       e.g. \code{\link{orgmTxDB}} or \code{\link{orgmOrgDB}}.
#' @family getDB
#' @examples
#' orgm <- "Hsapiens"
#' getPkgs (orgm, orgmTxDB)
getPkgs <- function (orgm, orgDB) {
  if (orgDB$dbClass[1] == "org") {
    pkg <- getOrgDB (orgm, orgDB)
  } else {
    pkg <- getTxDB (orgm, orgDB)
  }
  if  (!is.null(pkg)) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      BiocManager::install(pkg)
      library(pkg)}
  } else {
    pkg <- "NA"
    warning (paste(orgm, " is not a valid organism name"))
  }
  return(pkg)
}
