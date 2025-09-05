#' Get ortholog coordinates for target species
#'
#' @description This function retrieves genomic coordinates for orthologous genes 
#' in a target species based on ortholog mappings from getOrthHomolog().
#'
#' @param orthologs A data frame from getOrthHomolog() containing ortholog mappings
#' @param target_species A character string specifying the target species abbreviation (e.g., "Mmusculus")
#' @param source_species A character string specifying the source species abbreviation (e.g., "Hsapiens")
#' @param coords_source A character string specifying source species coordinates (e.g., "2:15.95e7:16.45e7")
#' @param coords_target A character string specifying target species coordinates (e.g., "2:6.0e7:6.5e7")
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing:
#'   - source: Data frame with ortholog gene coordinates in source species
#'   - target: Data frame with ortholog gene coordinates in target species
#'   - ortholog_mappings: Data frame showing ortholog relationships
#'
#' @examples
#' \dontrun{
#'   # Get orthologs first
#'   orthologs <- getOrthHomolog("mouse", "ENSG00000139618", verbose = TRUE)
#'   
#'   # Get coordinates for orthologs
#'   coords <- getOrthologCoordinates(orthologs, "Mmusculus", "Hsapiens", 
#'                                   "2:15.95e7:16.45e7", "2:6.0e7:6.5e7")
#' }
#'
#' @importFrom dplyr filter mutate select
#' @export
getOrthologCoordinates <- function(orthologs, target_species, source_species, 
                                  coords_source, coords_target, verbose = FALSE) {
    
    # Input validation
    if (missing(orthologs) || missing(target_species) || missing(source_species) || 
        missing(coords_source) || missing(coords_target)) {
        stop("All parameters must be provided: orthologs, target_species, source_species, coords_source, coords_target")
    }
    
    if (!is.data.frame(orthologs)) {
        stop("'orthologs' must be a data frame from getOrthHomolog()")
    }
    
    if (!all(c(is.character(target_species), is.character(source_species), 
               is.character(coords_source), is.character(coords_target)))) {
        stop("Species and coordinate parameters must be character strings")
    }
    
    if (verbose) {
        message("Retrieving ortholog coordinates for ", nrow(orthologs), " ortholog pairs")
    }
    
    tryCatch({
        # Get gene information for both species regions
        source_gr <- coordFormat(coords_source)
        target_gr <- coordFormat(coords_target)
        
        source_genes <- geneSubset(source_gr, source_species)
        target_genes <- geneSubset(target_gr, target_species)
        
        if (is.null(source_genes$geneListsorted) || is.null(target_genes$geneListsorted)) {
            stop("Could not retrieve genes for one or both regions")
        }
        
        # Extract gene information
        source_gene_df <- as.data.frame(source_genes$geneListsorted)
        target_gene_df <- as.data.frame(target_genes$geneListsorted)
        
        # Find orthologs in source species
        source_orthologs <- source_gene_df[source_gene_df$gene_id %in% orthologs$input_gene, ]
        
        # Find orthologs in target species
        target_orthologs <- target_gene_df[target_gene_df$gene_id %in% orthologs$orthologous_gene, ]
        
        if (verbose) {
            message("Found ", nrow(source_orthologs), " source orthologs and ", nrow(target_orthologs), " target orthologs")
        }
        
        # Create ortholog mappings
        ortholog_mappings <- merge(orthologs, source_orthologs, 
                                 by.x = "input_gene", by.y = "gene_id", all.x = TRUE)
        ortholog_mappings <- merge(ortholog_mappings, target_orthologs, 
                                 by.x = "orthologous_gene", by.y = "gene_id", all.x = TRUE)
        
        # Add species information
        source_orthologs$species <- source_species
        target_orthologs$species <- target_species
        
        result <- list(
            source = source_orthologs,
            target = target_orthologs,
            ortholog_mappings = ortholog_mappings
        )
        
        if (verbose) {
            message("Successfully retrieved coordinates for ", nrow(source_orthologs), " ortholog pairs")
        }
        
        return(result)
        
    }, error = function(e) {
        stop("Error in getOrthologCoordinates: ", e$message)
    })
}
