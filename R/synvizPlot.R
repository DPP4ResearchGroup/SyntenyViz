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
#' \donttest{
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
#' \donttest{
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
#' @return A multi synteny plot.
#'
#' @export
#' @family SynvizPlot
#' @examples
#' \donttest{
#'   orgmsList <- orgmsCollection.init (orgmsList)
#'   orgm <- "Hsapiens"
#'   mycoords.list <- "2:16e7:16.5e7"
#'   orgmsList <- orgmsAdd (orgm, orgmTxDB, mycoords.list, orgmsList)
#'   multisynvizPlots(orgmsList)
#' }
multisynvizPlots <- function (orgmsCollection, verbose = FALSE) {
  
  # Enhanced input validation
  if (missing(orgmsCollection)) {
    stop("'orgmsCollection' parameter is required")
  }
  
  if (!is.list(orgmsCollection) || length(orgmsCollection) == 0) {
    stop("'orgmsCollection' must be a non-empty list")
  }
  
  orgmSize <- length(orgmsCollection)
  
  # Max allowed multiplots limits to 3 as version v0.0.0.9000
  if (orgmSize > 3) {
    warning("Maximum allowed multiplots limit is 3 synteny plots at one time")
    if (verbose) {
      message("Consider splitting your analysis into multiple plots with 3 or fewer organisms each")
    }
    return(invisible(NULL))
  }
  
  # Pre-validate all organisms before plotting
  if (verbose) {
    message("Pre-validating organisms for plotting...")
  }
  
  tryCatch({
    # Extract organism names for validation
    orgm_names <- character(0)
    for (i in seq_along(orgmsCollection)) {
      orgmItem <- orgmsCollection[[i]]
      if (inherits(orgmItem, "GRanges")) {
        orgHandle <- as.character(genome(orgmItem))
        orgIndex <- match(orgHandle, orgmTxDB$dbAbbv)
        if (!is.na(orgIndex)) {
          orgName <- as.character(orgmTxDB$dbSpecies[orgIndex])
          orgm_names <- c(orgm_names, orgName)
        } else {
          warning("Unknown organism in collection at index ", i, ": ", orgHandle)
        }
      } else {
        warning("Invalid object type in collection at index ", i, ": ", class(orgmItem))
      }
    }
    
    # Check plotting compatibility
    if (length(orgm_names) > 0) {
      compatibility <- checkPlottingCompatibility(orgm_names, verbose = verbose)
      if (!compatibility$all_compatible) {
        warning("Some organisms do not support plotting: ", 
                paste(compatibility$incompatible_organisms, collapse = ", "))
        if (verbose) {
          message("Consider using alternative organisms or removing unsupported ones")
        }
      }
    }
    
    # Proceed with plotting
    if (verbose) {
      message("Starting multi-species plot generation...")
    }
    
    grid.newpage()
    plotNumber <- 1
    successful_plots <- 0
    
    while (plotNumber <= orgmSize) {
      tryCatch({
        orgmItem <- orgmsCollection[[plotNumber]]
        
        # Validate organism item
        if (!inherits(orgmItem, "GRanges")) {
          warning("Skipping invalid object at index ", plotNumber, ": ", class(orgmItem))
          plotNumber <- plotNumber + 1
          next
        }
        
        pushViewport(viewport(height=1/orgmSize, y=plotNumber/orgmSize, just ="top"))
        grid.rect()
        
        # Get organism name with error handling
        orgHandle <- as.character(genome(orgmItem))
        orgIndex <- match(orgHandle, orgmTxDB$dbAbbv)
        
        if (is.na(orgIndex)) {
          warning("Unknown organism: ", orgHandle, " - skipping plot")
          popViewport(1)
          plotNumber <- plotNumber + 1
          next
        }
        
        orgName <- as.character(orgmTxDB$dbSpecies[orgIndex])
        
        # Validate organism support
        validation <- validateOrganismSupport(orgName, "plotting", verbose = FALSE)
        if (!validation$supported) {
          warning("Organism ", orgName, " does not support plotting - skipping")
          if (verbose && length(validation$alternatives) > 0) {
            message("Suggested alternatives: ", paste(validation$alternatives[1:min(3, length(validation$alternatives))], collapse = ", "))
          }
          popViewport(1)
          plotNumber <- plotNumber + 1
          next
        }
        
        # Generate plot
        synvizPlot(orgmItem, orgName)
        successful_plots <- successful_plots + 1
        
        popViewport(1)
        plotNumber <- plotNumber + 1
        
      }, error = function(e) {
        warning("Error plotting organism at index ", plotNumber, ": ", e$message)
        if (verbose) {
          message("Skipping to next organism...")
        }
        popViewport(1)
        plotNumber <<- plotNumber + 1
      })
    }
    
    if (verbose) {
      message("Multi-species plot generation complete. Successful plots: ", successful_plots, " out of ", orgmSize)
    }
    
    if (successful_plots == 0) {
      warning("No plots were successfully generated")
    }
    
  }, error = function(e) {
    error_report <- createErrorReport(e, "multisynvizPlots", 
                                    list(orgmsCollection = orgmsCollection), verbose = verbose)
    if (verbose) {
      message("Error in multisynvizPlots:")
      message("  ", error_report$error_context$error_message)
      message("Quick fixes:")
      for (fix in error_report$quick_fixes) {
        message("  - ", fix)
      }
    }
    stop("Error in multisynvizPlots: ", e$message)
  })
}
