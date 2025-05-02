#' Search for orthologous genes in a target species
#'
#' @description This function uses the `orthogene` package to search for orthologous genes for a given target species.
#'
#' @param species A character string specifying the target species (e.g., "mouse").
#' @param gene_id A character string specifying the gene ID (e.g., "ENSG00000139618").
#' @param gene_id_type A character string specifying the type of gene ID provided. Options are "ensembl_gene_id" or "symbol".
#' @param verbose A logical value indicating whether to print additional information during the function execution. Defaults to FALSE.
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
getOrthHomolog <- function(species, gene_id, gene_id_type = "ensembl_gene_id", verbose = FALSE) {
    if (missing(species) || missing(gene_id)) {
        stop("Both 'species' and 'gene_id' must be provided.")
    }
    
    if (!gene_id_type %in% c("ensembl_gene_id", "symbol")) {
        stop("Invalid 'gene_id_type'. Must be 'ensembl_gene_id' or 'symbol'.")
    }
    
    if (verbose) {
        message("Searching for orthologous genes...")
    }
    
    # Use orthogene to find orthologs
    result <- orthogene::get_orthologs(
        genes = gene_id,
        species = species,
        input_type = gene_id_type,
        verbose = verbose
    )
    
    if (verbose) {
        message("Search complete.")
    }
    
    return(result)
}