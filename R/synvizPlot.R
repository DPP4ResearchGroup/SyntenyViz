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
  atrack <- AnnotationTrack(geneRetrive, group = IDs, name = orgm)
  gtrack <- GenomeAxisTrack ()
  gen <- genome (geneRetrive)[[1]]
  itrack <- IdeogramTrack(genome = gen, chromosome = chr, name = paste(orgm, "chromosome", chr))
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
  plotTracks(synvizData, showId = TRUE, add=TRUE)
}

#'multisynvizPlots
#'A multi synteny plot for comparison and new insight discovery
#'
#' @inheritParams orgmsAdd
#'
#' @family SynvizPlot
#' @export
#' @examples
#' \dontrun {
#'   orgmsList <- orgmsCollection.init (orgmsList)
#'   orgm <- "Hsapiens"
#'   mycoords.list <- "2:16e7:16.5e7"
#'   orgmsList <- orgmsAdd (orgm, orgmTxDB, mycoords.list, orgmsList)
#'   multisynvizPlots(orgmsList)
#' }
multisynvizPlots <- function (orgmsCollection) {
  orgmSize <- length (orgmsCollection)
  # Max allowed multiplots limits to 3 as version v0.0.0.9000
  if (orgmSize > 3) {
    warning ("Maximum allowed multiplots limit is 3 synteny plots at one time")
    returnValue()
    stop()
  }

  grid.newpage()
  plotNumber <- 1
  while (plotNumber <= orgmSize) {
    orgmItem <- orgmsCollection[[plotNumber]]
    pushViewport(viewport(height=1/orgmSize, y=plotNumber/orgmSize, just ="top"))
    grid.rect()

    # get orgmName
    orgHandle <- as.character(genome(orgmItem))
    orgIndex <- match (orgHandle, orgmTxDB$dbAbbv)
    orgName <- orgmTxDB$dbSpecies[orgIndex]

    synvizPlot (orgmItem, orgName)
    popViewport(1)
    plotNumber = plotNumber + 1
  }
}
