#'synvizPlotData
#' A data retrive function to prepare the data for \code{synvizPlot}.
#'
#' @inheritParams coordFormat
#' @inheritParams geneSubset
#'
#' @return A list that consists of AnnotationTrack, GenomeAxisTrack and IdeogramTrack
#' to feed into the function \code{synvizPlot}
#'
#' @export
#' @family SynvizPlot
#' @examples
#' \dontrun{
#'   orgm <- "Hsapiens"
#'   mycoords.list <- "2:16e7:16.5e7"
#'   mycoords.gr <- coordFormat (mycoords.list)
#'   synvizPlotData (mycoords.gr, orgm)
#' }
synvizPlotData <- function (mycoords.gr, orgm) {
  geneData <- geneSubset (mycoords.gr, orgm)
  geneRetrive <- geneData $ geneListsorted
  chr <- geneData $ chr
  # gene name list cleaning
  IDs <- unlist(lapply(geneRetrive$gene_name, function(x) { if(identical(x, character(0))) "NA" else x } ))
  atrack <- AnnotationTrack(geneRetrive, group = IDs)
  gtrack <- GenomeAxisTrack ()
  gen <- genome (geneRetrive)[[1]]
  itrack <- IdeogramTrack(genome = gen, chromosome = chr)
  synvizData <- list (itrack = itrack, gtrack = gtrack, atrack =atrack)
  return (synvizData)
}

#'synvizPlot
#'A plot function to plot synteny conversation across species.
#'
#' @inheritParams coordFormat
#' @inheritParams geneSubset
#'
#' @export
#' @family SynvizPlot
#' @return A synteny plot of a given gene region within a given organism
#'
#' @examples
#' \dontrun{
#'   orgm <- "Hsapiens"
#'   mycoords.list <- "2:16e7:16.5e7"
#'   mycoords.gr <- coordFormat (mycoords.list)
#'   synvizPlot (mycoords.gr, orgm)
#' }
synvizPlot <- function (mycoords.gr, orgm) {
  synvizData <- synvizPlotData (mycoords.gr, orgm)
  plotTracks(synvizData, showId = TRUE)
}
