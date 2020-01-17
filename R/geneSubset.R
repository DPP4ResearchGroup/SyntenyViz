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
  targetGenesPool <- sub(".db", "SYMBOL", orgmTargetDB)
  genes <- as.data.frame (get (targetGenesPool))

  # v0.0.9000 adapts TxDb
  # TxDb is available for Human = Hs, Mouse = Mm, Rat = Rn, Yeast = Sc, Zebrafish = Dr, Cow = Bt

  if (!is.na (orgmTargetDB)) {
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
    return (geneListsorted)
  } else {
    warning (paste("due to", orgm, "is not available, geneSubset function is not callable"))
    returnValue ()
  }
}
