# geneSubset
#' Search and annotate genes against known gene databases based on AnnotationDbi
#'
#' @inheritParams getOrgDB
#' @inheritParams coordFormat
#'
#' @export
#' @return A target search range as a GRanges object
#' @examples
#' \dontrun{
#'   mycoords.list <- "2:16e7:16.5e7"
#'   mycoords.gr <- coordFormat (mycoords.list)
#'   orgm <- "Hsapiens"
#'   geneSubset (mycoords.gr, orgm)
#' }

geneSubset <- function (mycoords.gr, orgm) {
  orgmTargetDB <- getPkgs (orgm, orgmOrgDB)

  # v0.0.9000 adapts TxDb
  # TxDb is available for Human = Hs, Mouse = Mm, Rat = Rn, Yeast = Sc, Zebrafish = Dr, Cow = Bt

  if (!"NA" %in% orgmTargetDB) {
    targetGenesPool <- sub(".db", "SYMBOL", orgmTargetDB)
    genes <- as.data.frame (get (targetGenesPool))
    # seqinfo class function restoreSeqlevels to set seqlevels in TxDb obj to original values
    targetTxDB <- getPkgs (orgm, orgmTxDB)

    restoreSeqlevels (get (targetTxDB))

    # subset TxDB known gene against target
    TxDBGeneCollection <- genes (get (targetTxDB))
    geneList <- subsetByOverlaps (TxDBGeneCollection, mycoords.gr)
    geneListsorted <- sort (sortSeqlevels (geneList))
    chr <- as.character (unique (seqnames (geneList)))
    seqlevels (geneList) <- as.character (chr)
    geneListsorted$gene_name <- lapply (geneListsorted$gene_id, function(x) {genes[genes$gene_id %in% x, ]$symbol})
    returnList <- list (geneListsorted = geneListsorted, chr = chr)
    return (returnList)
  } else {
    warning (paste("due to", orgm, "is not available, geneSubset function is not callable"))
    returnList <- list (returnValue(), returnValue())
    return (returnList)
  }
}
