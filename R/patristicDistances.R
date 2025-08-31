#' Load patristic distances from YAML file
#' @description Loads patristic distances based on published phylogenetic studies
#' @param debug Debug mode for verbose output
#' @return List of patristic distances between species pairs
#' @export
loadPatristicDistances <- function(debug = FALSE) {
    
    # Path to the patristic distances YAML file
    yaml_file <- system.file("data", "patristic_distances.yml", package = "SyntenyViz")
    
    if (debug) {
        cat("DEBUG: Loading patristic distances from:", yaml_file, "\n")
    }
    
    # Check if file exists
    if (!file.exists(yaml_file)) {
        warning("Patristic distances YAML file not found. Using default distances.")
        return(list("human-mouse" = 0.3456))  # Minimal fallback
    }
    
    tryCatch({
        # Load YAML file
        yaml_data <- yaml::read_yaml(yaml_file)
        
        # Flatten the nested structure into a simple list
        patristic_distances <- list()
        
        # Process mammals (nested structure)
        if ("mammals" %in% names(yaml_data)) {
            for (group in names(yaml_data$mammals)) {
                patristic_distances <- c(patristic_distances, yaml_data$mammals[[group]])
            }
        }
        
        # Process other groups (flat structure)
        flat_groups <- c("birds", "fish", "amphibians", "reptiles", "insects", 
                        "nematodes", "yeasts", "plants", "cross_phylum")
        
        for (group in flat_groups) {
            if (group %in% names(yaml_data)) {
                patristic_distances <- c(patristic_distances, yaml_data[[group]])
            }
        }
        
        if (debug) {
            cat("DEBUG: Loaded", length(patristic_distances), "patristic distances\n")
        }
        
        return(patristic_distances)
        
    }, error = function(e) {
        warning("Error loading patristic distances from YAML file: ", e$message)
        return(list("human-mouse" = 0.3456))  # Minimal fallback
    })
}

#' Calculate patristic distance from phylogenetic tree
#' @description Calculates patristic distance between two species from a phylogenetic tree
#' @param tree Phylogenetic tree object (ape::phylo)
#' @param species1 First species name
#' @param species2 Second species name
#' @param debug Debug mode for verbose output
#' @return Patristic distance in substitutions per site
#' @export
calculatePatristicDistance <- function(tree, species1, species2, debug = FALSE) {
    
    if (!requireNamespace("ape", quietly = TRUE)) {
        stop("Package 'ape' is required for phylogenetic tree operations")
    }
    
    if (debug) {
        cat("DEBUG: Calculating patristic distance between", species1, "and", species2, "\n")
    }
    
    # Check if species exist in tree
    if (!all(c(species1, species2) %in% tree$tip.label)) {
        missing_species <- setdiff(c(species1, species2), tree$tip.label)
        stop("Species not found in tree: ", paste(missing_species, collapse = ", "))
    }
    
    # Calculate patristic distance
    tryCatch({
        distance_matrix <- ape::cophenetic.phylo(tree)
        patristic_distance <- distance_matrix[species1, species2]
        
        if (debug) {
            cat("DEBUG: Patristic distance:", patristic_distance, "\n")
        }
        
        return(patristic_distance)
        
    }, error = function(e) {
        warning("Error calculating patristic distance: ", e$message)
        return(NA)
    })
}

#' Get available patristic distance information
#' @description Returns information about available species pairs and their patristic distances
#' @param species1 Optional first species to filter results
#' @param species2 Optional second species to filter results
#' @param min_distance Optional minimum distance threshold
#' @param max_distance Optional maximum distance threshold
#' @return Data frame with species pairs and their patristic distances
#' @export
getPatristicDistances <- function(species1 = NULL, species2 = NULL, 
                                min_distance = NULL, max_distance = NULL) {
    
    # Load patristic distances from YAML file
    patristic_distances <- loadPatristicDistances()
    
    # Convert to data frame
    distances_df <- data.frame(
        species_pair = names(patristic_distances),
        patristic_distance = unlist(patristic_distances),
        stringsAsFactors = FALSE
    )
    
    # Split species pair into separate columns
    species_split <- strsplit(distances_df$species_pair, "-")
    distances_df$species1 <- sapply(species_split, function(x) x[1])
    distances_df$species2 <- sapply(species_split, function(x) x[2])
    
    # Add additional information
    distances_df$evolutionary_similarity <- 1 - distances_df$patristic_distance
    distances_df$divergence_time_mya <- distances_df$patristic_distance * 1000  # Rough estimate in millions of years
    
    # Filter by species if provided
    if (!is.null(species1)) {
        distances_df <- distances_df[distances_df$species1 == species1 | distances_df$species2 == species1, ]
    }
    
    if (!is.null(species2)) {
        distances_df <- distances_df[distances_df$species1 == species2 | distances_df$species2 == species2, ]
    }
    
    # Filter by distance range if provided
    if (!is.null(min_distance)) {
        distances_df <- distances_df[distances_df$patristic_distance >= min_distance, ]
    }
    
    if (!is.null(max_distance)) {
        distances_df <- distances_df[distances_df$patristic_distance <= max_distance, ]
    }
    
    # Sort by patristic distance
    distances_df <- distances_df[order(distances_df$patristic_distance), ]
    
    return(distances_df)
}

#' Convert patristic distance to divergence time
#' @description Converts patristic distance to estimated divergence time using molecular clock
#' @param patristic_distance Patristic distance in substitutions per site
#' @param mutation_rate Mutation rate per site per year (default: 1e-9)
#' @param generation_time Generation time in years (default: 1)
#' @return Divergence time in millions of years
#' @export
patristicToDivergenceTime <- function(patristic_distance, mutation_rate = 1e-9, generation_time = 1) {
    
    # Formula: T = d / (2 * μ * g)
    # where T = divergence time, d = patristic distance, μ = mutation rate, g = generation time
    divergence_time_years <- patristic_distance / (2 * mutation_rate * generation_time)
    divergence_time_mya <- divergence_time_years / 1e6
    
    return(divergence_time_mya)
}

#' Convert divergence time to patristic distance
#' @description Converts divergence time to patristic distance using molecular clock
#' @param divergence_time_mya Divergence time in millions of years
#' @param mutation_rate Mutation rate per site per year (default: 1e-9)
#' @param generation_time Generation time in years (default: 1)
#' @return Patristic distance in substitutions per site
#' @export
divergenceTimeToPatristic <- function(divergence_time_mya, mutation_rate = 1e-9, generation_time = 1) {
    
    # Formula: d = 2 * μ * g * T
    # where d = patristic distance, μ = mutation rate, g = generation time, T = divergence time
    divergence_time_years <- divergence_time_mya * 1e6
    patristic_distance <- 2 * mutation_rate * generation_time * divergence_time_years
    
    return(patristic_distance)
}

#' Calculate evolutionary similarity from patristic distance
#' @description Calculates evolutionary similarity score from patristic distance
#' @param patristic_distance Patristic distance in substitutions per site
#' @param max_distance Maximum expected distance for normalization (default: 1.0)
#' @return Evolutionary similarity score (0-1)
#' @export
calculateEvolutionarySimilarity <- function(patristic_distance, max_distance = 1.0) {
    
    # Normalize patristic distance to 0-1 scale
    normalized_distance <- pmin(patristic_distance / max_distance, 1.0)
    
    # Calculate similarity as 1 - normalized distance
    evolutionary_similarity <- 1 - normalized_distance
    
    return(evolutionary_similarity)
}

#' Validate patristic distances against phylogenetic tree
#' @description Validates patristic distances by comparing with distances from a phylogenetic tree
#' @param tree Phylogenetic tree object (ape::phylo)
#' @param patristic_distances List of patristic distances to validate
#' @param tolerance Tolerance for differences (default: 0.01)
#' @param debug Debug mode for verbose output
#' @return Data frame with validation results
#' @export
validatePatristicDistances <- function(tree, patristic_distances, tolerance = 0.01, debug = FALSE) {
    
    if (!requireNamespace("ape", quietly = TRUE)) {
        stop("Package 'ape' is required for phylogenetic tree operations")
    }
    
    if (debug) {
        cat("DEBUG: Validating patristic distances against phylogenetic tree\n")
    }
    
    # Calculate distance matrix from tree
    tree_distances <- ape::cophenetic.phylo(tree)
    
    # Initialize results
    validation_results <- data.frame(
        species_pair = character(),
        patristic_distance = numeric(),
        tree_distance = numeric(),
        difference = numeric(),
        within_tolerance = logical(),
        stringsAsFactors = FALSE
    )
    
    # Validate each species pair
    for (pair_name in names(patristic_distances)) {
        species_names <- strsplit(pair_name, "-")[[1]]
        
        if (length(species_names) == 2 && 
            all(species_names %in% rownames(tree_distances))) {
            
            patristic_dist <- patristic_distances[[pair_name]]
            tree_dist <- tree_distances[species_names[1], species_names[2]]
            difference <- abs(patristic_dist - tree_dist)
            within_tolerance <- difference <= tolerance
            
            validation_results <- rbind(validation_results, data.frame(
                species_pair = pair_name,
                patristic_distance = patristic_dist,
                tree_distance = tree_dist,
                difference = difference,
                within_tolerance = within_tolerance,
                stringsAsFactors = FALSE
            ))
        }
    }
    
    if (debug) {
        cat("DEBUG: Validated", nrow(validation_results), "species pairs\n")
        cat("DEBUG: Pairs within tolerance:", sum(validation_results$within_tolerance), "\n")
    }
    
    return(validation_results)
}

#' Get confidence levels for patristic distances
#' @description Returns confidence levels based on data source and methodology
#' @param species_pair Species pair name (e.g., "human-chimpanzee")
#' @return Confidence level description
#' @export
getDistanceConfidence <- function(species_pair) {
    
    # Load patristic distances to check if pair exists
    patristic_distances <- loadPatristicDistances()
    
    if (!species_pair %in% names(patristic_distances)) {
        return("Unknown species pair")
    }
    
    # Define confidence levels based on data source
    high_confidence_pairs <- c(
        "human-chimpanzee", "human-gorilla", "human-orangutan",
        "mouse-rat", "dog-wolf", "cow-sheep", "sheep-goat"
    )
    
    medium_confidence_pairs <- c(
        "human-mouse", "human-macaque", "chicken-duck",
        "zebrafish-medaka", "arabidopsis-rice"
    )
    
    if (species_pair %in% high_confidence_pairs) {
        return("High confidence - Fossil calibrated")
    } else if (species_pair %in% medium_confidence_pairs) {
        return("Medium confidence - Molecular clock estimate")
    } else {
        return("Lower confidence - Extrapolated estimate")
    }
}

#' Summary statistics for patristic distances
#' @description Provides summary statistics for all available patristic distances
#' @return List with summary statistics
#' @export
getPatristicDistanceSummary <- function() {
    
    # Load patristic distances
    patristic_distances <- loadPatristicDistances()
    
    # Convert to numeric vector
    distances <- unlist(patristic_distances)
    
    # Calculate summary statistics
    summary_stats <- list(
        total_pairs = length(distances),
        mean_distance = mean(distances, na.rm = TRUE),
        median_distance = median(distances, na.rm = TRUE),
        min_distance = min(distances, na.rm = TRUE),
        max_distance = max(distances, na.rm = TRUE),
        sd_distance = sd(distances, na.rm = TRUE),
        range = max(distances, na.rm = TRUE) - min(distances, na.rm = TRUE)
    )
    
    # Add distance categories
    summary_stats$close_pairs <- sum(distances < 0.1, na.rm = TRUE)
    summary_stats$medium_pairs <- sum(distances >= 0.1 & distances < 0.5, na.rm = TRUE)
    summary_stats$distant_pairs <- sum(distances >= 0.5, na.rm = TRUE)
    
    return(summary_stats)
}
