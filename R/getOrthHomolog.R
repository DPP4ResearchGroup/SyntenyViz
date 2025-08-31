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
    
    # Validate input types
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

#' Calculate synteny similarity between genomic regions using orthologous genes
#'
#' @description This function calculates the degree of similarity between syntenic regions 
#' across species by comparing orthologous gene content and order.
#'
#' @param species1 A character string specifying the first species (e.g., "Hsapiens").
#' @param species2 A character string specifying the second species (e.g., "Mmusculus").
#' @param coords1 A character string specifying coordinates for species1 (e.g., "2:16e7:16.5e7").
#' @param coords2 A character string specifying coordinates for species2 (e.g., "2:6.0e7:6.5e7").
#' @param gene_id_type A character string specifying the type of gene ID. Options are "ensembl_gene_id" or "symbol".
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing similarity metrics including:
#'   - overlap_score: Proportion of orthologous genes found in both regions
#'   - order_score: Measure of gene order conservation
#'   - overall_similarity: Combined similarity score
#'   - ortholog_pairs: Data frame of orthologous gene pairs
#'   - missing_genes: Genes not found as orthologs in the other species
#'
#' @examples
#' \dontrun{
#'   # Calculate synteny similarity between human and mouse DPP4 regions
#'   similarity <- calculateSyntenySimilarity(
#'     species1 = "Hsapiens", 
#'     species2 = "Mmusculus",
#'     coords1 = "2:15.95e7:16.45e7",
#'     coords2 = "2:6.0e7:6.5e7"
#'   )
#' }
#'
#' @importFrom orthogene get_orthologs
#' @export
calculateSyntenySimilarity <- function(species1, species2, coords1, coords2, 
                                      gene_id_type = "ensembl_gene_id", verbose = FALSE) {
    
    if (missing(species1) || missing(species2) || missing(coords1) || missing(coords2)) {
        stop("All parameters must be provided: species1, species2, coords1, coords2")
    }
    
    # Validate input types
    if (!all(c(is.character(species1), is.character(species2), is.character(coords1), is.character(coords2)))) {
        stop("All parameters must be character strings")
    }
    
    if (verbose) {
        message("Calculating synteny similarity between ", species1, " and ", species2)
    }
    
    # Validate coordinate format
    coord_pattern <- "^\\d+:\\d+e\\d+:\\d+e\\d+$"
    if (!grepl(coord_pattern, coords1) || !grepl(coord_pattern, coords2)) {
        stop("Coordinates must be in format 'chromosome:start:end' (e.g., '2:16e7:16.5e7')")
    }
    
    # Get genes from both regions
    tryCatch({
        genes1 <- geneSubset(coordFormat(coords1), species1)
        genes2 <- geneSubset(coordFormat(coords2), species2)
    }, error = function(e) {
        stop(paste("Error retrieving genes:", e$message))
    })
    
    if (is.null(genes1$geneListsorted) || is.null(genes2$geneListsorted)) {
        stop("Could not retrieve genes for one or both regions")
    }
    
    # Extract gene IDs
    gene_ids_1 <- genes1$geneListsorted$gene_id
    gene_ids_2 <- genes2$geneListsorted$gene_id
    
    if (length(gene_ids_1) == 0 || length(gene_ids_2) == 0) {
        stop("No genes found in one or both regions")
    }
    
    if (verbose) {
        message("Found ", length(gene_ids_1), " genes in ", species1, " and ", length(gene_ids_2), " genes in ", species2)
    }
    
    # Find orthologs for species1 genes in species2
    orthologs_1_to_2 <- lapply(gene_ids_1, function(gene_id) {
        tryCatch({
            getOrthHomolog(species2, gene_id, gene_id_type, verbose = FALSE)
        }, error = function(e) {
            if (verbose) message("No ortholog found for ", gene_id, " in ", species2)
            return(NULL)
        })
    })
    
    # Find orthologs for species2 genes in species1
    orthologs_2_to_1 <- lapply(gene_ids_2, function(gene_id) {
        tryCatch({
            getOrthHomolog(species1, gene_id, gene_id_type, verbose = FALSE)
        }, error = function(e) {
            if (verbose) message("No ortholog found for ", gene_id, " in ", species1)
            return(NULL)
        })
    })
    
    # Calculate overlap score
    orthologs_found_1_to_2 <- sum(!sapply(orthologs_1_to_2, is.null))
    orthologs_found_2_to_1 <- sum(!sapply(orthologs_2_to_1, is.null))
    
    overlap_score_1 <- orthologs_found_1_to_2 / length(gene_ids_1)
    overlap_score_2 <- orthologs_found_2_to_1 / length(gene_ids_2)
    overlap_score <- (overlap_score_1 + overlap_score_2) / 2
    
    # Calculate order score (simplified - could be enhanced with more sophisticated algorithms)
    # For now, we'll use a basic approach based on ortholog presence
    order_score <- 1.0  # Placeholder - would need more complex implementation for actual gene order analysis
    
    # Calculate overall similarity
    overall_similarity <- (overlap_score + order_score) / 2
    
    # Prepare ortholog pairs data
    ortholog_pairs <- data.frame(
        species1_gene = character(),
        species2_gene = character(),
        stringsAsFactors = FALSE
    )
    
    for (i in seq_along(orthologs_1_to_2)) {
        if (!is.null(orthologs_1_to_2[[i]]) && nrow(orthologs_1_to_2[[i]]) > 0) {
            ortholog_pairs <- rbind(ortholog_pairs, 
                data.frame(
                    species1_gene = gene_ids_1[i],
                    species2_gene = orthologs_1_to_2[[i]]$orthologous_gene[1],
                    stringsAsFactors = FALSE
                )
            )
        }
    }
    
    # Find missing genes
    missing_genes_1 <- gene_ids_1[sapply(orthologs_1_to_2, is.null)]
    missing_genes_2 <- gene_ids_2[sapply(orthologs_2_to_1, is.null)]
    
    result <- list(
        overlap_score = overlap_score,
        order_score = order_score,
        overall_similarity = overall_similarity,
        ortholog_pairs = ortholog_pairs,
        missing_genes = list(
            species1 = missing_genes_1,
            species2 = missing_genes_2
        ),
        total_genes = list(
            species1 = length(gene_ids_1),
            species2 = length(gene_ids_2)
        ),
        orthologs_found = list(
            species1_to_2 = orthologs_found_1_to_2,
            species2_to_1 = orthologs_found_2_to_1
        )
    )
    
    if (verbose) {
        message("Similarity calculation complete:")
        message("  Overlap score: ", round(overlap_score, 3))
        message("  Overall similarity: ", round(overall_similarity, 3))
        message("  Ortholog pairs found: ", nrow(ortholog_pairs))
    }
    
    return(result)
}