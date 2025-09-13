## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 10,
  fig.height = 6,
  fig.align = "center",
  warning = FALSE,
  message = FALSE
)

# Load required packages
library(SyntenyViz)
library(dplyr)
library(grid)

# Preload libraries for better vignette performance
pkgs <- c("org.Hs.eg.db", "org.Mm.eg.db", "org.Rn.eg.db", 
          "TxDb.Hsapiens.UCSC.hg38.knownGene",
          "TxDb.Mmusculus.UCSC.mm10.knownGene", 
          "TxDb.Rnorvegicus.UCSC.rn6.refGene")

for (pkg in pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    BiocManager::install(pkg)
  }
  library(pkg, character.only = TRUE)
}


## ----installation-------------------------------------------------------------
# Install SyntenyViz from GitHub
# devtools::install_github("DPP4ResearchGroup/SyntenyViz")

# Load the package
library(SyntenyViz)

# Check package version
packageVersion("SyntenyViz")


## ----available-organisms------------------------------------------------------
# View available organisms
cat("Available organisms for analysis:\n")
print(orgmOrgDB)

cat("\nAvailable transcriptomics databases:\n")
print(orgmTxDB)

cat("\nOrganism abbreviations reference:\n")
print(SynVizOrgms)


## ----define-coordinates-------------------------------------------------------
# Define investigation ranges for DPP4 gene regions
human_coords <- "2:15.95e7:16.45e7"    # Human DPP4 region
mouse_coords <- "2:6.0e7:6.5e7"        # Mouse DPP4 region  
rat_coords <- "3:4.6e7:5.1e7"          # Rat DPP4 region

cat("Defined coordinate ranges:\n")
cat("Human DPP4 region:", human_coords, "\n")
cat("Mouse DPP4 region:", mouse_coords, "\n")
cat("Rat DPP4 region:", rat_coords, "\n")


## ----convert-coordinates------------------------------------------------------
# Convert coordinate strings to GRanges objects
human_gr <- coordFormat(human_coords)
mouse_gr <- coordFormat(mouse_coords)
rat_gr <- coordFormat(rat_coords)

# Display the GRanges objects
cat("Human GRanges object:\n")
print(human_gr)

cat("\nMouse GRanges object:\n")
print(mouse_gr)

cat("\nRat GRanges object:\n")
print(rat_gr)


## ----extract-genes------------------------------------------------------------
# Extract genes from each species
human_genes <- geneSubset(human_gr, "Hsapiens")
mouse_genes <- geneSubset(mouse_gr, "Mmusculus")
rat_genes <- geneSubset(rat_gr, "Rnorvegicus")

# Display gene counts
cat("Genes found in each species:\n")
cat("Human:", length(human_genes$geneListsorted), "genes\n")
cat("Mouse:", length(mouse_genes$geneListsorted), "genes\n")
cat("Rat:", length(rat_genes$geneListsorted), "genes\n")

# Show some gene information
if (length(human_genes$geneListsorted) > 0) {
  cat("\nFirst few human genes:\n")
  print(head(as.data.frame(human_genes$geneListsorted)[, c("gene_id", "gene_name")]))
}


## ----single-plots, fig.cap="Single species synteny plots showing gene organization around DPP4 in human and mouse"----
# Create single synteny plots
par(mfrow = c(2, 1))

# Human synteny plot
synvizPlot(human_gr, "Hsapiens")

# Mouse synteny plot  
synvizPlot(mouse_gr, "Mmusculus")

par(mfrow = c(1, 1))


## ----multi-species-setup------------------------------------------------------
# Initialize organism collection
orgms_list <- orgmsCollection.init(orgms_list)

# Add organisms to collection
orgms_list <- orgmsAdd("Hsapiens", orgmTxDB, human_coords, orgms_list)
orgms_list <- orgmsAdd("Mmusculus", orgmTxDB, mouse_coords, orgms_list)
orgms_list <- orgmsAdd("Rnorvegicus", orgmTxDB, rat_coords, orgms_list)

cat("Organisms in collection:", length(orgms_list), "\n")


## ----multi-species-plot, fig.cap="Multi-species synteny plot comparing DPP4 regions across human, mouse, and rat", fig.height=8----
# Create multi-species synteny plot
multiplot <- multisynvizPlots(orgms_list)


## ----ortholog-search----------------------------------------------------------
# Define example gene IDs (DPP4 orthologs)
human_dpp4 <- "ENSG00000197635"  # Human DPP4
mouse_dpp4 <- "ENSMUSG00000041147"  # Mouse DPP4

# Search for orthologs
cat("Searching for orthologs of human DPP4 in mouse...\n")
orthologs <- getOrthHomolog("mouse", human_dpp4, verbose = TRUE)

if (!is.null(orthologs) && nrow(orthologs) > 0) {
  cat("Orthologs found:", nrow(orthologs), "\n")
  print(head(orthologs))
} else {
  cat("No orthologs found\n")
}

# Search in reverse direction
cat("\nSearching for orthologs of mouse DPP4 in human...\n")
orthologs_reverse <- getOrthHomolog("human", mouse_dpp4, verbose = TRUE)

if (!is.null(orthologs_reverse) && nrow(orthologs_reverse) > 0) {
  cat("Reverse orthologs found:", nrow(orthologs_reverse), "\n")
  print(head(orthologs_reverse))
} else {
  cat("No reverse orthologs found\n")
}


## ----similarity-calculations--------------------------------------------------
# Calculate different types of similarity
if (!is.null(orthologs) && nrow(orthologs) > 0) {
  
  # Sequence similarity
  cat("Calculating sequence similarity...\n")
  seq_similarity <- calculateOrthologSimilarity(orthologs, "human", "mouse", 
                                               similarity_type = "sequence")
  
  # Functional similarity
  cat("Calculating functional similarity...\n")
  func_similarity <- calculateOrthologSimilarity(orthologs, "human", "mouse", 
                                                similarity_type = "functional")
  
  # Evolutionary similarity
  cat("Calculating evolutionary similarity...\n")
  evo_similarity <- calculateOrthologSimilarity(orthologs, "human", "mouse", 
                                               similarity_type = "evolutionary")
  
  # Composite similarity (combines all types)
  cat("Calculating composite similarity...\n")
  composite_similarity <- calculateOrthologSimilarity(orthologs, "human", "mouse", 
                                                     similarity_type = "composite")
  
  # Display results
  if ("similarity_score" %in% colnames(composite_similarity)) {
    cat("\nTop similarity scores:\n")
    top_similarities <- head(composite_similarity[order(composite_similarity$similarity_score, decreasing = TRUE), 
                                                 c("orthologous_gene", "similarity_score", "confidence_level")], 5)
    print(top_similarities)
  }
  
} else {
  cat("No orthologs available for similarity calculation\n")
}


## ----synteny-similarity-------------------------------------------------------
# Calculate synteny similarity between species
cat("Calculating synteny similarity between human and mouse...\n")
synteny_similarity <- calculateSyntenySimilarity("Hsapiens", "Mmusculus", 
                                                human_coords, mouse_coords, 
                                                verbose = TRUE)

# Display results
cat("\nSynteny similarity results:\n")
cat("  Overlap score:", round(synteny_similarity$overlap_score, 3), "\n")
cat("  Order score:", round(synteny_similarity$order_score, 3), "\n")
cat("  Overall similarity:", round(synteny_similarity$overall_similarity, 3), "\n")
cat("  Ortholog pairs found:", nrow(synteny_similarity$ortholog_pairs), "\n")
cat("  Total genes (human):", synteny_similarity$total_genes$species1, "\n")
cat("  Total genes (mouse):", synteny_similarity$total_genes$species2, "\n")

# Show ortholog pairs
if (nrow(synteny_similarity$ortholog_pairs) > 0) {
  cat("\nOrtholog pairs:\n")
  print(head(synteny_similarity$ortholog_pairs))
}


## ----evolutionary-distances---------------------------------------------------
# Load evolutionary distances
cat("Loading evolutionary distances...\n")
evo_distances <- loadEvolutionaryDistances()
cat("Loaded", length(evo_distances), "evolutionary distances\n")

# Get evolutionary distance information
evo_info <- getEvolutionaryDistances()
cat("Evolutionary distance data frame dimensions:", dim(evo_info), "\n")

# Filter for human-related distances
cat("\nHuman-related evolutionary distances:\n")
human_evo <- getEvolutionaryDistances(species1 = "human")
print(head(human_evo[, c("species_pair", "evolutionary_distance", "divergence_time_mya")]))

# Get close evolutionary relationships
cat("\nClose evolutionary relationships (distance < 0.1):\n")
close_evo <- getEvolutionaryDistances(max_distance = 0.1)
print(head(close_evo[, c("species_pair", "evolutionary_distance", "divergence_time_mya")]))


## ----patristic-distances------------------------------------------------------
# Load patristic distances
cat("Loading patristic distances...\n")
patristic_distances <- loadPatristicDistances()
cat("Loaded", length(patristic_distances), "patristic distances\n")

# Get patristic distance information
patristic_info <- getPatristicDistances()
cat("Patristic distance data frame dimensions:", dim(patristic_info), "\n")

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


## ----phylogenetic-trees-------------------------------------------------------
# Check if ape package is available for phylogenetic operations
if (requireNamespace("ape", quietly = TRUE)) {
  cat("Package 'ape' available - demonstrating phylogenetic tree operations...\n")
  
  library(ape)
  
  # Create a simple example tree
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
  cat("\nValidating patristic distances against phylogenetic tree...\n")
  validation_results <- validatePatristicDistances(example_tree, patristic_distances, tolerance = 0.01)
  cat("Validation results for", nrow(validation_results), "species pairs\n")
  cat("Pairs within tolerance:", sum(validation_results$within_tolerance), "\n")
  
} else {
  cat("Package 'ape' not available. Install it to use phylogenetic tree functions.\n")
  cat("Install with: install.packages('ape')\n")
}


## ----summary-statistics-------------------------------------------------------
# Get summary statistics for patristic distances
cat("Patristic distance summary statistics:\n")
summary_stats <- getPatristicDistanceSummary()
cat("Total species pairs:", summary_stats$total_pairs, "\n")
cat("Mean distance:", round(summary_stats$mean_distance, 4), "\n")
cat("Distance range:", round(summary_stats$min_distance, 4), "to", round(summary_stats$max_distance, 4), "\n")
cat("Close pairs (< 0.1):", summary_stats$close_pairs, "\n")
cat("Medium pairs (0.1-0.5):", summary_stats$medium_pairs, "\n")
cat("Distant pairs (≥ 0.5):", summary_stats$distant_pairs, "\n")


## ----error-handling-----------------------------------------------------------
# Demonstrate proper error handling
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


## ----performance-tips---------------------------------------------------------
cat("Performance optimization tips:\n")
cat("1. Use appropriate coordinate ranges - smaller ranges are faster\n")
cat("2. Cache results when possible using R's caching mechanisms\n")
cat("3. Use debug=FALSE in production code to reduce output\n")
cat("4. Consider using parallel processing for large-scale analyses\n")
cat("5. Pre-load required databases to avoid repeated loading\n")


## ----citation-----------------------------------------------------------------
citation("SyntenyViz")

