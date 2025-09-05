#' Convert ortholog coordinate data frames to GRanges objects
#'
#' @description This function converts ortholog coordinate data frames to GRanges objects
#' with proper metadata for use with multisynvizPlots and other plotting functions.
#'
#' @param coords_data A data frame containing gene coordinates (from getOrthologCoordinates)
#' @param species A character string specifying the species abbreviation
#' @param genome_assembly A character string specifying the genome assembly (optional)
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A GRanges object with proper metadata for plotting functions
#'
#' @examples
#' \dontrun{
#'   # Convert ortholog coordinates to GRanges
#'   coords_gr <- convertToGRanges(ortholog_coords$source, "Hsapiens", "hg38")
#' }
#'
#' @importFrom GenomicRanges GRanges makeGRangesFromDataFrame
#' @importFrom S4Vectors metadata
#' @export
convertToGRanges <- function(coords_data, species, genome_assembly = NULL, verbose = FALSE) {
    
    # Input validation
    if (missing(coords_data) || missing(species)) {
        stop("Both 'coords_data' and 'species' parameters are required")
    }
    
    if (!is.data.frame(coords_data)) {
        stop("'coords_data' must be a data frame")
    }
    
    if (!is.character(species) || length(species) != 1) {
        stop("'species' must be a single character string")
    }
    
    # Required columns check
    required_cols <- c("seqnames", "start", "end")
    missing_cols <- setdiff(required_cols, colnames(coords_data))
    if (length(missing_cols) > 0) {
        stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
    }
    
    if (verbose) {
        message("Converting coordinates to GRanges for species: ", species)
    }
    
    tryCatch({
        # Get genome assembly if not provided
        if (is.null(genome_assembly)) {
            genome_assembly <- getGenomeAssembly(species)
        }
        
        # Create GRanges object
        gr <- makeGRangesFromDataFrame(
            coords_data,
            keep.extra.columns = TRUE,
            starts.in.df.are.0based = FALSE
        )
        
        # Add metadata
        metadata(gr) <- list(
            species = species,
            genome_assembly = genome_assembly,
            coordinate_source = "ortholog_coordinates",
            conversion_timestamp = Sys.time()
        )
        
        # Validate coordinate ranges
        if (verbose) {
            message("Validating coordinate ranges...")
        }
        
        # Check for invalid coordinates
        invalid_coords <- which(start(gr) > end(gr) | start(gr) < 1)
        if (length(invalid_coords) > 0) {
            warning("Found ", length(invalid_coords), " invalid coordinate ranges")
            if (verbose) {
                message("Invalid coordinates at indices: ", paste(invalid_coords, collapse = ", "))
            }
        }
        
        if (verbose) {
            message("Successfully converted ", length(gr), " coordinates to GRanges")
        }
        
        return(gr)
        
    }, error = function(e) {
        stop("Error in convertToGRanges: ", e$message)
    })
}

#' Validate coordinate format compatibility
#'
#' @description This function validates that coordinate data is compatible with target functions.
#'
#' @param coords A GRanges object or data frame containing coordinates
#' @param target_function A character string specifying the target function ("multisynvizPlots", "plotSyntenyBlocks", etc.)
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing compatibility status and required conversions
#'
#' @examples
#' \dontrun{
#'   # Validate coordinates for multisynvizPlots
#'   validation <- validateCoordinateFormat(coords_gr, "multisynvizPlots")
#' }
#'
#' @export
validateCoordinateFormat <- function(coords, target_function, verbose = FALSE) {
    
    # Input validation
    if (missing(coords) || missing(target_function)) {
        stop("Both 'coords' and 'target_function' parameters are required")
    }
    
    if (!is.character(target_function) || length(target_function) != 1) {
        stop("'target_function' must be a single character string")
    }
    
    if (verbose) {
        message("Validating coordinate format for: ", target_function)
    }
    
    tryCatch({
        result <- list(
            compatible = TRUE,
            required_conversions = character(0),
            warnings = character(0),
            errors = character(0)
        )
        
        # Check if coords is GRanges object
        if (!inherits(coords, "GRanges")) {
            result$compatible <- FALSE
            result$required_conversions <- c(result$required_conversions, "convert_to_granges")
            result$warnings <- c(result$warnings, "Coordinates must be converted to GRanges object")
        }
        
        # Check for required metadata based on target function
        if (target_function == "multisynvizPlots") {
            if (inherits(coords, "GRanges")) {
                if (is.null(metadata(coords)$species)) {
                    result$warnings <- c(result$warnings, "Missing species metadata")
                }
                if (is.null(metadata(coords)$genome_assembly)) {
                    result$warnings <- c(result$warnings, "Missing genome assembly metadata")
                }
            }
        }
        
        # Check coordinate validity
        if (inherits(coords, "GRanges")) {
            invalid_ranges <- which(start(coords) > end(coords) | start(coords) < 1)
            if (length(invalid_ranges) > 0) {
                result$compatible <- FALSE
                result$errors <- c(result$errors, paste("Found", length(invalid_ranges), "invalid coordinate ranges"))
            }
        }
        
        # Check for empty coordinates
        if (length(coords) == 0) {
            result$warnings <- c(result$warnings, "Empty coordinate data")
        }
        
        if (verbose) {
            if (result$compatible) {
                message("Coordinates are compatible with ", target_function)
            } else {
                message("Coordinates are NOT compatible with ", target_function)
                if (length(result$errors) > 0) {
                    message("Errors: ", paste(result$errors, collapse = "; "))
                }
            }
            if (length(result$warnings) > 0) {
                message("Warnings: ", paste(result$warnings, collapse = "; "))
            }
        }
        
        return(result)
        
    }, error = function(e) {
        stop("Error in validateCoordinateFormat: ", e$message)
    })
}

#' Standardize coordinates for different plotting functions
#'
#' @description This function standardizes coordinates to ensure compatibility with different plotting functions.
#'
#' @param coords A GRanges object or data frame containing coordinates
#' @param target_format A character string specifying the target format ("multisynvizPlots", "plotSyntenyBlocks", etc.)
#' @param species A character string specifying the species (required for GRanges conversion)
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A standardized GRanges object compatible with the target function
#'
#' @examples
#' \dontrun{
#'   # Standardize coordinates for multisynvizPlots
#'   std_coords <- standardizeCoordinates(coords_df, "multisynvizPlots", "Hsapiens")
#' }
#'
#' @export
standardizeCoordinates <- function(coords, target_format, species = NULL, verbose = FALSE) {
    
    # Input validation
    if (missing(coords) || missing(target_format)) {
        stop("Both 'coords' and 'target_format' parameters are required")
    }
    
    if (!is.character(target_format) || length(target_format) != 1) {
        stop("'target_format' must be a single character string")
    }
    
    if (verbose) {
        message("Standardizing coordinates for: ", target_format)
    }
    
    tryCatch({
        # Convert to GRanges if needed
        if (!inherits(coords, "GRanges")) {
            if (is.null(species)) {
                stop("'species' parameter is required when converting data frame to GRanges")
            }
            coords <- convertToGRanges(coords, species, verbose = verbose)
        }
        
        # Apply format-specific standardizations
        if (target_format == "multisynvizPlots") {
            # Ensure proper metadata for multisynvizPlots
            if (is.null(metadata(coords)$species)) {
                if (!is.null(species)) {
                    metadata(coords)$species <- species
                } else {
                    warning("Species metadata missing and not provided")
                }
            }
            
            if (is.null(metadata(coords)$genome_assembly)) {
                if (!is.null(metadata(coords)$species)) {
                    metadata(coords)$genome_assembly <- getGenomeAssembly(metadata(coords)$species)
                } else if (!is.null(species)) {
                    metadata(coords)$genome_assembly <- getGenomeAssembly(species)
                } else {
                    warning("Genome assembly metadata missing and cannot be determined")
                }
            }
        }
        
        if (target_format == "plotSyntenyBlocks") {
            # Ensure coordinates have proper gene information
            if (!"gene_id" %in% colnames(mcols(coords))) {
                warning("Missing gene_id column - may affect synteny block visualization")
            }
        }
        
        # Validate final coordinates
        validation <- validateCoordinateFormat(coords, target_format, verbose = verbose)
        if (!validation$compatible) {
            warning("Standardized coordinates may still have compatibility issues")
        }
        
        if (verbose) {
            message("Coordinates standardized successfully for ", target_format)
        }
        
        return(coords)
        
    }, error = function(e) {
        stop("Error in standardizeCoordinates: ", e$message)
    })
}

#' Get genome assembly for species
#'
#' @description This function returns the appropriate genome assembly for a given species.
#'
#' @param species A character string specifying the species abbreviation
#'
#' @return A character string with the genome assembly name
#'
#' @examples
#' \dontrun{
#'   # Get genome assembly for human
#'   assembly <- getGenomeAssembly("Hsapiens")
#' }
#'
#' @export
getGenomeAssembly <- function(species) {
    
    # Input validation
    if (missing(species) || !is.character(species) || length(species) != 1) {
        stop("'species' must be a single character string")
    }
    
    # Genome assembly mapping
    assembly_map <- list(
        "Hsapiens" = "hg38",
        "Mmusculus" = "mm10",
        "Rnorvegicus" = "rn6",
        "Mmulatta" = "rheMac10",
        "Ptroglodytes" = "panTro6",
        "Cfamiliaris" = "canFam3",
        "Btaurus" = "bosTau9",
        "Sscrofa" = "susScr11",
        "Ggallus" = "galGal6",
        "Drerio" = "danRer11",
        "Dmelanogaster" = "dm6",
        "Celegans" = "ce11",
        "Scerevisiae" = "sacCer3"
    )
    
    if (species %in% names(assembly_map)) {
        return(assembly_map[[species]])
    } else {
        warning("Unknown species: ", species, " - returning default assembly")
        return("unknown")
    }
}
