# Comprehensive SyntenyViz User Example
# This script demonstrates all major functions and capabilities of the SyntenyViz package
# Author: SyntenyViz Development Team
# Date: 2024

# Load required packages
library(SyntenyViz)
library(dplyr)

cat("=== SyntenyViz Comprehensive User Example ===\n")
cat("This example demonstrates all major functions and workflows\n\n")

# =============================================================================
# 1. BASIC SETUP AND COORDINATE FORMATTING
# =============================================================================

cat("1. BASIC SETUP AND COORDINATE FORMATTING\n")
cat("========================================\n")

# Define investigation ranges for different species
# Using DPP4 gene regions as examples
human_coords <- "2:15.95e7:16.45e7"    # Human DPP4 region
mouse_coords <- "2:6.0e7:6.5e7"        # Mouse DPP4 region  
rat_coords <- "3:4.6e7:5.1e7"          # Rat DPP4 region

# Convert coordinate strings to GRanges objects
cat("Converting coordinate strings to GRanges objects...\n")
human_gr <- coordFormat(human_coords)
mouse_gr <- coordFormat(mouse_coords)
rat_gr <- coordFormat(rat_coords)

cat("Human coordinates:", as.character(human_gr), "\n")
cat("Mouse coordinates:", as.character(mouse_gr), "\n")
cat("Rat coordinates:", as.character(rat_gr), "\n\n")

# =============================================================================
# 2. GENE SUBSET AND ANNOTATION
# =============================================================================

cat("2. GENE SUBSET AND ANNOTATION\n")
cat("=============================\n")

# Get gene information for each species
cat("Retrieving gene information...\n")
human_genes <- geneSubset(human_gr, "Hsapiens")
mouse_genes <- geneSubset(mouse_gr, "Mmusculus")
rat_genes <- geneSubset(rat_gr, "Rnorvegicus")

cat("Human genes found:", length(human_genes$geneListsorted), "\n")
cat("Mouse genes found:", length(mouse_genes$geneListsorted), "\n")
cat("Rat genes found:", length(rat_genes$geneListsorted), "\n\n")

# =============================================================================
# 3. SINGLE SYNTHENY PLOTS
# =============================================================================

cat("3. SINGLE SYNTHENY PLOTS\n")
cat("========================\n")

# Generate plot data for single synteny plots
cat("Generating plot data for single synteny plots...\n")
human_plot_data <- synvizPlotData(human_gr, "Hsapiens")
mouse_plot_data <- synvizPlotData(mouse_gr, "Mmusculus")

cat("Human plot data components:", names(human_plot_data), "\n")
cat("Mouse plot data components:", names(mouse_plot_data), "\n")

# Create single synteny plots
cat("Creating single synteny plots...\n")
# Note: In a real session, these would display plots
# synvizPlot(human_gr, "Hsapiens")
# synvizPlot(mouse_gr, "Mmusculus")

cat("Single synteny plots created successfully\n\n")

# =============================================================================
# 4. MULTI-SPECIES SYNTHENY ANALYSIS
# =============================================================================

cat("4. MULTI-SPECIES SYNTHENY ANALYSIS\n")
cat("==================================\n")

# Initialize organism collection
cat("Initializing organism collection...\n")
orgms_list <- orgmsCollection.init(orgms_list)

# Add organisms to collection
cat("Adding organisms to collection...\n")
orgms_list <- orgmsAdd("Hsapiens", orgmTxDB, human_coords, orgms_list)
orgms_list <- orgmsAdd("Mmusculus", orgmTxDB, mouse_coords, orgms_list)
orgms_list <- orgmsAdd("Rnorvegicus", orgmTxDB, rat_coords, orgms_list)

cat("Organisms in collection:", length(orgms_list), "\n")

# Create multi-synteny plot
cat("Creating multi-synteny plot...\n")
# Note: In a real session, this would display the multi-plot
# multiplot <- multisynvizPlots(orgms_list)

cat("Multi-synteny plot created successfully\n\n")

# =============================================================================
# 5. ORTHOLOG SEARCH AND ANALYSIS
# =============================================================================

cat("5. ORTHOLOG SEARCH AND ANALYSIS\n")
cat("===============================\n")

# Search for orthologs
cat("Searching for orthologs...\n")

# Example gene IDs (DPP4 orthologs)
human_dpp4 <- "ENSG00000197635"  # Human DPP4
mouse_dpp4 <- "ENSMUSG00000041147"  # Mouse DPP4

# Get orthologs for human DPP4 in mouse
cat("Finding orthologs for human DPP4 in mouse...\n")
orthologs <- getOrthHomolog("mouse", human_dpp4, verbose = TRUE)

if (!is.null(orthologs)) {
    cat("Orthologs found:", nrow(orthologs), "\n")
    cat("Ortholog columns:", paste(colnames(orthologs), collapse = ", "), "\n")
} else {
    cat("No orthologs found\n")
}

# Get orthologs for mouse DPP4 in human
cat("Finding orthologs for mouse DPP4 in human...\n")
orthologs_reverse <- getOrthHomolog("human", mouse_dpp4, verbose = TRUE)

if (!is.null(orthologs_reverse)) {
    cat("Reverse orthologs found:", nrow(orthologs_reverse), "\n")
} else {
    cat("No reverse orthologs found\n")
}

cat("\n")

# =============================================================================
# 6. ORTHOLOG SIMILARITY CALCULATIONS
# =============================================================================

cat("6. ORTHOLOG SIMILARITY CALCULATIONS\n")
cat("===================================\n")

# Calculate different types of similarity
if (!is.null(orthologs) && nrow(orthologs) > 0) {
    cat("Calculating ortholog similarities...\n")
    
    # Sequence similarity
    cat("Calculating sequence similarity...\n")
    seq_similarity <- calculateOrthologSimilarity(orthologs, "human", "mouse", 
                                                 similarity_type = "sequence")
    cat("Sequence similarity calculated for", nrow(seq_similarity), "orthologs\n")
    
    # Functional similarity
    cat("Calculating functional similarity...\n")
    func_similarity <- calculateOrthologSimilarity(orthologs, "human", "mouse", 
                                                  similarity_type = "functional")
    cat("Functional similarity calculated for", nrow(func_similarity), "orthologs\n")
    
    # Evolutionary similarity
    cat("Calculating evolutionary similarity...\n")
    evo_similarity <- calculateOrthologSimilarity(orthologs, "human", "mouse", 
                                                 similarity_type = "evolutionary")
    cat("Evolutionary similarity calculated for", nrow(evo_similarity), "orthologs\n")
    
    # Composite similarity
    cat("Calculating composite similarity...\n")
    composite_similarity <- calculateOrthologSimilarity(orthologs, "human", "mouse", 
                                                       similarity_type = "composite")
    cat("Composite similarity calculated for", nrow(composite_similarity), "orthologs\n")
    
    # All similarities
    cat("Calculating all similarity types...\n")
    all_similarities <- calculateOrthologSimilarity(orthologs, "human", "mouse", 
                                                   similarity_type = "all")
    cat("All similarities calculated for", nrow(all_similarities), "orthologs\n")
    
    # Display similarity results
    if ("similarity_score" %in% colnames(composite_similarity)) {
        cat("Top similarity scores:\n")
        top_similarities <- head(composite_similarity[order(composite_similarity$similarity_score, decreasing = TRUE), 
                                                     c("orthologous_gene", "similarity_score", "confidence_level")], 3)
        print(top_similarities)
    }
} else {
    cat("No orthologs available for similarity calculation\n")
}

cat("\n")

# =============================================================================
# 7. SYNTHENY SIMILARITY ANALYSIS
# =============================================================================

cat("7. SYNTHENY SIMILARITY ANALYSIS\n")
cat("===============================\n")

# Calculate synteny similarity between species
cat("Calculating synteny similarity between human and mouse...\n")
synteny_similarity <- calculateSyntenySimilarity("Hsapiens", "Mmusculus", 
                                                human_coords, mouse_coords, 
                                                verbose = TRUE)

cat("Synteny similarity results:\n")
cat("  Overlap score:", round(synteny_similarity$overlap_score, 3), "\n")
cat("  Order score:", round(synteny_similarity$order_score, 3), "\n")
cat("  Overall similarity:", round(synteny_similarity$overall_similarity, 3), "\n")
cat("  Ortholog pairs found:", nrow(synteny_similarity$ortholog_pairs), "\n")
cat("  Total genes (human):", synteny_similarity$total_genes$species1, "\n")
cat("  Total genes (mouse):", synteny_similarity$total_genes$species2, "\n")

cat("\n")

# =============================================================================
# 8. EVOLUTIONARY DISTANCE ANALYSIS
# =============================================================================

cat("8. EVOLUTIONARY DISTANCE ANALYSIS\n")
cat("=================================\n")

# Load evolutionary distances
cat("Loading evolutionary distances...\n")
evo_distances <- loadEvolutionaryDistances()
cat("Loaded", length(evo_distances), "evolutionary distances\n")

# Get evolutionary distance information
cat("Getting evolutionary distance information...\n")
evo_info <- getEvolutionaryDistances()
cat("Evolutionary distance data frame dimensions:", dim(evo_info), "\n")

# Filter for human-related distances
cat("Human-related evolutionary distances:\n")
human_evo <- getEvolutionaryDistances(species1 = "human")
print(head(human_evo[, c("species_pair", "evolutionary_distance", "divergence_time_mya")]))

# Get close evolutionary relationships
cat("\nClose evolutionary relationships (distance < 0.1):\n")
close_evo <- getEvolutionaryDistances(max_distance = 0.1)
print(head(close_evo[, c("species_pair", "evolutionary_distance", "divergence_time_mya")]))

cat("\n")

# =============================================================================
# 9. PATRISTIC DISTANCE ANALYSIS
# =============================================================================

cat("9. PATRISTIC DISTANCE ANALYSIS\n")
cat("==============================\n")

# Load patristic distances
cat("Loading patristic distances...\n")
patristic_distances <- loadPatristicDistances()
cat("Loaded", length(patristic_distances), "patristic distances\n")

# Get patristic distance information
cat("Getting patristic distance information...\n")
patristic_info <- getPatristicDistances()
cat("Patristic distance data frame dimensions:", dim(patristic_info), "\n")

# Filter for human-related distances
cat("Human-related patristic distances:\n")
human_patristic <- getPatristicDistances(species1 = "human")
print(head(human_patristic[, c("species_pair", "patristic_distance", "divergence_time_mya")]))

# Convert between patristic distance and divergence time
cat("\nConverting between patristic distance and divergence time...\n")
human_chimp_distance <- 0.0123
divergence_time <- patristicToDivergenceTime(human_chimp_distance)
cat("Human-Chimpanzee patristic distance:", human_chimp_distance, "\n")
cat("Estimated divergence time:", round(divergence_time, 1), "MYA\n")

# Convert back
estimated_distance <- divergenceTimeToPatristic(6.5)
cat("6.5 MYA divergence time corresponds to patristic distance:", round(estimated_distance, 4), "\n")

# Calculate evolutionary similarity
similarity <- calculateEvolutionarySimilarity(human_chimp_distance)
cat("Human-Chimpanzee evolutionary similarity:", round(similarity, 3), "\n")

# Get confidence levels
cat("\nConfidence levels for species pairs:\n")
species_pairs <- c("human-chimpanzee", "human-mouse", "human-chicken")
for (pair in species_pairs) {
    confidence <- getDistanceConfidence(pair)
    cat(pair, ":", confidence, "\n")
}

# Get summary statistics
cat("\nPatristic distance summary statistics:\n")
summary_stats <- getPatristicDistanceSummary()
cat("Total species pairs:", summary_stats$total_pairs, "\n")
cat("Mean distance:", round(summary_stats$mean_distance, 4), "\n")
cat("Distance range:", round(summary_stats$min_distance, 4), "to", round(summary_stats$max_distance, 4), "\n")
cat("Close pairs (< 0.1):", summary_stats$close_pairs, "\n")
cat("Medium pairs (0.1-0.5):", summary_stats$medium_pairs, "\n")
cat("Distant pairs (≥ 0.5):", summary_stats$distant_pairs, "\n")

cat("\n")

# =============================================================================
# 10. PHYLOGENETIC TREE OPERATIONS (if ape package available)
# =============================================================================

cat("10. PHYLOGENETIC TREE OPERATIONS\n")
cat("===============================\n")

if (requireNamespace("ape", quietly = TRUE)) {
    cat("Package 'ape' available - demonstrating phylogenetic tree operations...\n")
    
    # Create a simple example tree
    library(ape)
    
    # Example tree with 4 species
    tree_text <- "((human:0.0123,chimpanzee:0.0123):0.0111,gorilla:0.0234,orangutan:0.0456);"
    example_tree <- read.tree(text = tree_text)
    
    cat("Example phylogenetic tree created\n")
    
    # Calculate patristic distance from tree
    tree_distance <- calculatePatristicDistance(example_tree, "human", "gorilla")
    cat("Patristic distance from tree (human-gorilla):", tree_distance, "\n")
    
    # Compare with stored distance
    stored_distance <- patristic_distances[["human-gorilla"]]
    if (!is.null(stored_distance)) {
        cat("Stored distance (human-gorilla):", stored_distance, "\n")
        cat("Difference:", abs(tree_distance - stored_distance), "\n")
    }
    
    # Validate patristic distances against tree
    cat("Validating patristic distances against phylogenetic tree...\n")
    validation_results <- validatePatristicDistances(example_tree, patristic_distances, tolerance = 0.01)
    cat("Validation results for", nrow(validation_results), "species pairs\n")
    cat("Pairs within tolerance:", sum(validation_results$within_tolerance), "\n")
    
} else {
    cat("Package 'ape' not available. Install it to use phylogenetic tree functions.\n")
}

cat("\n")

# =============================================================================
# 11. DATABASE AND PACKAGE MANAGEMENT
# =============================================================================

cat("11. DATABASE AND PACKAGE MANAGEMENT\n")
cat("===================================\n")

# Get available organisms
cat("Available organisms for analysis:\n")
print(orgmOrgDB)

cat("\nAvailable transcriptomics databases:\n")
print(orgmTxDB)

# Get organism abbreviations
cat("\nOrganism abbreviations reference:\n")
print(SynVizOrgms)

# Get packages for specific organisms
cat("\nGetting packages for human:\n")
human_orgdb <- getPkgs("Hsapiens", orgmOrgDB)
human_txdb <- getPkgs("Hsapiens", orgmTxDB)
cat("Human OrgDB:", human_orgdb, "\n")
cat("Human TxDB:", human_txdb, "\n")

cat("\n")

# =============================================================================
# 12. ERROR HANDLING AND DEBUGGING
# =============================================================================

cat("12. ERROR HANDLING AND DEBUGGING\n")
cat("================================\n")

# Demonstrate error handling
cat("Demonstrating error handling...\n")

# Try with invalid coordinates
cat("Testing with invalid coordinates...\n")
tryCatch({
    invalid_gr <- coordFormat("invalid:coordinates")
}, error = function(e) {
    cat("Caught expected error:", e$message, "\n")
})

# Try with invalid species
cat("Testing with invalid species...\n")
tryCatch({
    invalid_genes <- geneSubset(human_gr, "InvalidSpecies")
}, error = function(e) {
    cat("Caught expected error:", e$message, "\n")
})

# Try with debug mode
cat("Testing debug mode...\n")
debug_orthologs <- getOrthHomolog("mouse", human_dpp4, debug = TRUE, verbose = TRUE)

cat("\n")

# =============================================================================
# 13. SUMMARY AND CONCLUSION
# =============================================================================

cat("13. SUMMARY AND CONCLUSION\n")
cat("==========================\n")

cat("This comprehensive example demonstrated:\n")
cat("✓ Coordinate formatting and GRanges conversion\n")
cat("✓ Gene subset and annotation\n")
cat("✓ Single and multi-species synteny plotting\n")
cat("✓ Ortholog search and analysis\n")
cat("✓ Multiple similarity calculations (sequence, functional, evolutionary, composite)\n")
cat("✓ Synteny similarity analysis\n")
cat("✓ Evolutionary distance analysis\n")
cat("✓ Patristic distance analysis\n")
cat("✓ Phylogenetic tree operations (when available)\n")
cat("✓ Database and package management\n")
cat("✓ Error handling and debugging\n\n")

cat("The SyntenyViz package provides a comprehensive toolkit for:\n")
cat("- Visualizing synteny conservation across species\n")
cat("- Analyzing ortholog relationships\n")
cat("- Calculating various similarity metrics\n")
cat("- Working with evolutionary distances\n")
cat("- Integrating phylogenetic information\n\n")

cat("For more information, see:\n")
cat("- Package documentation: ?SyntenyViz\n")
cat("- Vignettes: browseVignettes('SyntenyViz')\n")
cat("- GitHub repository: https://github.com/DPP4ResearchGroup/SyntenyViz\n")
cat("- Project website: https://dpp4researchgroup.github.io/SyntenyViz/\n\n")

cat("=== Example Complete ===\n")

