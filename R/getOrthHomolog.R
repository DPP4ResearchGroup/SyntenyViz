#' Search for orthologous genes in a target species
#'
#' @description This function uses the `orthogene` package to search for orthologous genes for a given target species.
#'
#' @param species A character string specifying the target species (e.g., "mouse").
#' @param gene_id A character string specifying the gene ID (e.g., "ENSG00000139618").
#' @param gene_id_type A character string specifying the type of gene ID provided. Options are "ensembl_gene_id" or "symbol".
#' @param verbose A logical value indicating whether to print additional information during the function execution. Defaults to FALSE.
#' @param debug A logical value for additional debugging output. Defaults to FALSE.
#'
#' @return A data frame containing the orthologous gene(s) and their associated information.
#'
#' @examples
#' \dontrun{
#'  # Example usage of the getOrthHomolog function
#'  getOrthHomolog(species = "mouse", gene_id = "ENSG00000139618", gene_id_type = "ensembl_gene_id")
#' }
#'
#' @importFrom orthogene get_orthologs
#' @export
getOrthHomolog <- function(species, gene_id, gene_id_type = "ensembl_gene_id", verbose = FALSE, debug = FALSE) {
    
    # Debug: Print function call details
    if (debug) {
        cat("DEBUG: Function called with parameters:\n")
        cat("  species =", species, "\n")
        cat("  gene_id =", gene_id, "\n")
        cat("  gene_id_type =", gene_id_type, "\n")
        cat("  verbose =", verbose, "\n")
        cat("  debug =", debug, "\n")
    }
    
    # Input validation with detailed error messages
    if (missing(species) || missing(gene_id)) {
        stop("Both 'species' and 'gene_id' must be provided.")
    }
    
    if (!is.character(species) || length(species) != 1) {
        stop("'species' must be a single character string.")
    }
    
    if (!is.character(gene_id) || length(gene_id) != 1) {
        stop("'gene_id' must be a single character string.")
    }
    
    if (!gene_id_type %in% c("ensembl_gene_id", "symbol")) {
        stop("Invalid 'gene_id_type'. Must be 'ensembl_gene_id' or 'symbol'.")
    }
    
    # Check package dependencies
    if (!requireNamespace("orthogene", quietly = TRUE)) {
        stop("Package 'orthogene' is required but not installed. Install with: BiocManager::install('orthogene')")
    }
    
    if (debug) {
        cat("DEBUG: All input validation passed\n")
        cat("DEBUG: Checking orthogene package availability\n")
    }
    
    # Try-catch for better error handling
    tryCatch({
        if (verbose || debug) {
            message("Searching for orthologous genes...")
        }
        
        if (debug) {
            cat("DEBUG: Calling orthogene::get_orthologs with:\n")
            cat("  genes =", gene_id, "\n")
            cat("  species =", species, "\n")
            cat("  input_type =", gene_id_type, "\n")
        }
        
        result <- orthogene::get_orthologs(
            genes = gene_id,
            species = species,
            input_type = gene_id_type,
            verbose = verbose
        )
        
        if (debug) {
            cat("DEBUG: orthogene::get_orthologs completed\n")
            cat("DEBUG: Result class =", class(result), "\n")
            if (is.data.frame(result)) {
                cat("DEBUG: Result dimensions =", dim(result), "\n")
                cat("DEBUG: Result columns =", paste(colnames(result), collapse = ", "), "\n")
            }
        }
        
        if (verbose || debug) {
            message("Orthologs found.")
        }
        
        if (is.null(result) || (is.data.frame(result) && nrow(result) == 0)) {
            warning("No orthologs found for the given gene. Please check the species and gene ID.")
            if (debug) {
                cat("DEBUG: No results found, returning NULL\n")
            }
            return(NULL)
        }
        
        if (debug) {
            cat("DEBUG: Returning result with", nrow(result), "rows\n")
        }
        
        return(result)
        
    }, error = function(e) {
        if (debug) {
            cat("DEBUG: Error occurred in getOrthHomolog:\n")
            cat("  Error message:", e$message, "\n")
            cat("  Call stack:\n")
            print(sys.calls())
        }
        stop("Error in getOrthHomolog: ", e$message)
    }, warning = function(w) {
        if (debug) {
            cat("DEBUG: Warning occurred in getOrthHomolog:\n")
            cat("  Warning message:", w$message, "\n")
        }
        warning(w$message)
    })
}