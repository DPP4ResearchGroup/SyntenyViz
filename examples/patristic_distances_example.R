# Example: Using Patristic Distances in SyntenyViz
# This script demonstrates the new patristic distance functionality

# Load required packages
library(SyntenyViz)

# Example 1: Basic patristic distance operations
cat("=== Example 1: Basic Patristic Distance Operations ===\n")

# Load all available patristic distances
patristic_distances <- loadPatristicDistances()
cat("Loaded", length(patristic_distances), "patristic distances\n\n")

# Get information about available distances
distances_info <- getPatristicDistances()
cat("First few species pairs:\n")
print(head(distances_info[, c("species_pair", "patristic_distance", "divergence_time_mya")]))

# Example 2: Filtering and querying distances
cat("\n=== Example 2: Filtering and Querying ===\n")

# Get all distances involving humans
human_distances <- getPatristicDistances(species1 = "human")
cat("Distances involving humans:\n")
print(human_distances[, c("species_pair", "patristic_distance", "divergence_time_mya")])

# Get close evolutionary relationships (distance < 0.1)
close_distances <- getPatristicDistances(max_distance = 0.1)
cat("\nClose evolutionary relationships (distance < 0.1):\n")
print(close_distances[, c("species_pair", "patristic_distance", "divergence_time_mya")])

# Example 3: Converting between metrics
cat("\n=== Example 3: Converting Between Metrics ===\n")

# Convert patristic distance to divergence time
human_chimp_distance <- 0.0123
divergence_time <- patristicToDivergenceTime(human_chimp_distance)
cat("Human-Chimpanzee patristic distance:", human_chimp_distance, "\n")
cat("Estimated divergence time:", round(divergence_time, 1), "MYA\n")

# Convert divergence time back to patristic distance
estimated_distance <- divergenceTimeToPatristic(6.5)
cat("6.5 MYA divergence time corresponds to patristic distance:", round(estimated_distance, 4), "\n")

# Calculate evolutionary similarity
similarity <- calculateEvolutionarySimilarity(human_chimp_distance)
cat("Human-Chimpanzee evolutionary similarity:", round(similarity, 3), "\n")

# Example 4: Confidence levels and validation
cat("\n=== Example 4: Confidence Levels ===\n")

# Check confidence levels for different species pairs
species_pairs <- c("human-chimpanzee", "human-mouse", "human-chicken")
for (pair in species_pairs) {
    confidence <- getDistanceConfidence(pair)
    cat(pair, ":", confidence, "\n")
}

# Example 5: Summary statistics
cat("\n=== Example 5: Summary Statistics ===\n")

summary_stats <- getPatristicDistanceSummary()
cat("Total species pairs:", summary_stats$total_pairs, "\n")
cat("Mean distance:", round(summary_stats$mean_distance, 4), "\n")
cat("Distance range:", round(summary_stats$min_distance, 4), "to", round(summary_stats$max_distance, 4), "\n")
cat("Close pairs (< 0.1):", summary_stats$close_pairs, "\n")
cat("Medium pairs (0.1-0.5):", summary_stats$medium_pairs, "\n")
cat("Distant pairs (≥ 0.5):", summary_stats$distant_pairs, "\n")

# Example 6: Working with phylogenetic trees (if ape package is available)
cat("\n=== Example 6: Phylogenetic Tree Operations ===\n")

if (requireNamespace("ape", quietly = TRUE)) {
    # Create a simple example tree
    library(ape)
    
    # Example tree with 4 species
    tree_text <- "((human:0.0123,chimpanzee:0.0123):0.0111,gorilla:0.0234,orangutan:0.0456);"
    example_tree <- read.tree(text = tree_text)
    
    cat("Example phylogenetic tree:\n")
    print(example_tree)
    
    # Calculate patristic distance from tree
    tree_distance <- calculatePatristicDistance(example_tree, "human", "gorilla")
    cat("Patristic distance from tree (human-gorilla):", tree_distance, "\n")
    
    # Compare with stored distance
    stored_distance <- patristic_distances[["human-gorilla"]]
    cat("Stored distance (human-gorilla):", stored_distance, "\n")
    cat("Difference:", abs(tree_distance - stored_distance), "\n")
    
} else {
    cat("Package 'ape' not available. Install it to use phylogenetic tree functions.\n")
}

# Example 7: Practical application in ortholog analysis
cat("\n=== Example 7: Practical Application ===\n")

# Simulate ortholog data
ortholog_data <- data.frame(
    gene_id_1 = c("ENSG00000139618", "ENSG00000157764"),
    gene_id_2 = c("ENSMUSG00000041147", "ENSMUSG00000026471"),
    species1 = c("human", "human"),
    species2 = c("mouse", "mouse"),
    stringsAsFactors = FALSE
)

cat("Sample ortholog data:\n")
print(ortholog_data)

# Get evolutionary distance for human-mouse comparison
human_mouse_distance <- patristic_distances[["human-mouse"]]
cat("\nHuman-Mouse evolutionary distance:", human_mouse_distance, "\n")
cat("Estimated divergence time:", round(human_mouse_distance * 1000, 1), "MYA\n")

# Calculate evolutionary similarity
evo_similarity <- calculateEvolutionarySimilarity(human_mouse_distance)
cat("Evolutionary similarity:", round(evo_similarity, 3), "\n")

# Example 8: Error handling and edge cases
cat("\n=== Example 8: Error Handling ===\n")

# Try to get confidence for non-existent species pair
non_existent_confidence <- getDistanceConfidence("human-dragon")
cat("Non-existent species pair confidence:", non_existent_confidence, "\n")

# Try to load distances with debug mode
debug_distances <- loadPatristicDistances(debug = TRUE)
cat("Debug mode loaded", length(debug_distances), "distances\n")

cat("\n=== Example Complete ===\n")
cat("This demonstrates the key features of the new patristic distance system.\n")
cat("The system provides scientifically validated evolutionary distances based on\n")
cat("published phylogenetic studies with fossil calibrations.\n")

