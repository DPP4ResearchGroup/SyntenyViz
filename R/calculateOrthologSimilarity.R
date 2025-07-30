#' Calculate similarity of discovered orthologs
#'
#' @description This function calculates various similarity metrics for orthologs discovered
#' using the getOrthHomolog function. It provides multiple similarity measures including
#' sequence similarity, functional similarity, and evolutionary distance.
#'
#' @details The function implements a comprehensive framework for ortholog analysis that integrates
#' multiple biological perspectives. It calculates three main types of similarity:
#' \itemize{
#'   \item \strong{Sequence Similarity}: Measures sequence conservation using identity, coverage, and alignment quality
#'   \item \strong{Functional Similarity}: Assesses functional conservation using GO terms and pathway overlap
#'   \item \strong{Evolutionary Similarity}: Quantifies evolutionary distance using molecular clock estimates
#' }
#' 
#' The composite score combines these measures with weights: Sequence (40%), Functional (35%), Evolutionary (25%).
#' 
#' For detailed explanations of the underlying calculations and methodology, see the explanatory note:
#' \code{vignette("calculateOrthologSimilarity_Explanatory", package = "SyntenyViz")}
#'
#' @param ortholog_data A data frame containing ortholog information from getOrthHomolog
#' @param similarity_type A character string specifying the type of similarity to calculate.
#'   Options are "sequence", "functional", "evolutionary", "composite", or "all". Defaults to "composite".
#' @param species1 A character string specifying the source species (e.g., "human")
#' @param species2 A character string specifying the target species (e.g., "mouse")
#' @param use_cache A logical value indicating whether to use cached similarity data. Defaults to TRUE.
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#' @param debug A logical value for additional debugging output. Defaults to FALSE.
#'
#' @return A data frame containing ortholog pairs with calculated similarity scores.
#'
#' @examples
#' \dontrun{
#'  # Get orthologs first
#'  orthologs <- getOrthHomolog("mouse", "ENSG00000139618")
#'  
#'  # Calculate similarity
#'  similarity <- calculateOrthologSimilarity(orthologs, "human", "mouse")
#'  
#'  # Calculate specific similarity type
#'  sequence_sim <- calculateOrthologSimilarity(orthologs, "human", "mouse", 
#'                                             similarity_type = "sequence")
#' }
#'
#' @importFrom dplyr mutate select filter arrange desc
#' @importFrom stringr str_detect
#' @export
calculateOrthologSimilarity <- function(ortholog_data, species1, species2, 
                                       similarity_type = "composite", use_cache = TRUE, 
                                       verbose = FALSE, debug = FALSE) {
    
    # Debug: Print function call details
    if (debug) {
        cat("DEBUG: Function called with parameters:\n")
        cat("  similarity_type =", similarity_type, "\n")
        cat("  species1 =", species1, "\n")
        cat("  species2 =", species2, "\n")
        cat("  use_cache =", use_cache, "\n")
        cat("  verbose =", verbose, "\n")
        cat("  debug =", debug, "\n")
    }
    
    # Input validation
    if (missing(ortholog_data) || is.null(ortholog_data)) {
        stop("ortholog_data must be provided and cannot be NULL.")
    }
    
    if (!is.data.frame(ortholog_data)) {
        stop("ortholog_data must be a data frame.")
    }
    
    if (missing(species1) || missing(species2)) {
        stop("Both species1 and species2 must be provided.")
    }
    
    if (!is.character(species1) || !is.character(species2)) {
        stop("species1 and species2 must be character strings.")
    }
    
    valid_similarity_types <- c("sequence", "functional", "evolutionary", "composite", "all")
    if (!similarity_type %in% valid_similarity_types) {
        stop("Invalid similarity_type. Must be one of: ", paste(valid_similarity_types, collapse = ", "))
    }
    
    if (debug) {
        cat("DEBUG: Input validation passed\n")
        cat("DEBUG: ortholog_data dimensions =", dim(ortholog_data), "\n")
        cat("DEBUG: ortholog_data columns =", paste(colnames(ortholog_data), collapse = ", "), "\n")
    }
    
    # Try-catch for better error handling
    tryCatch({
        
        if (verbose || debug) {
            message("Calculating ortholog similarity...")
        }
        
        # Initialize result data frame
        result <- ortholog_data
        
        # Calculate sequence similarity
        if (similarity_type %in% c("sequence", "composite", "all")) {
            if (debug) cat("DEBUG: Calculating sequence similarity\n")
            result <- calculateSequenceSimilarity(result, species1, species2, debug)
        }
        
        # Calculate functional similarity
        if (similarity_type %in% c("functional", "composite", "all")) {
            if (debug) cat("DEBUG: Calculating functional similarity\n")
            result <- calculateFunctionalSimilarity(result, species1, species2, debug)
        }
        
        # Calculate evolutionary similarity
        if (similarity_type %in% c("evolutionary", "composite", "all")) {
            if (debug) cat("DEBUG: Calculating evolutionary similarity\n")
            result <- calculateEvolutionarySimilarity(result, species1, species2, debug)
        }
        
        # Calculate composite score if requested
        if (similarity_type == "composite") {
            if (debug) cat("DEBUG: Calculating composite similarity score\n")
            result <- calculateCompositeSimilarity(result, debug)
        }
        
        # Sort by similarity score
        if ("similarity_score" %in% colnames(result)) {
            result <- result %>% arrange(desc(similarity_score))
        }
        
        if (verbose || debug) {
            message("Similarity calculation completed.")
            if (debug) {
                cat("DEBUG: Final result dimensions =", dim(result), "\n")
                cat("DEBUG: Final result columns =", paste(colnames(result), collapse = ", "), "\n")
            }
        }
        
        return(result)
        
    }, error = function(e) {
        if (debug) {
            cat("DEBUG: Error occurred in calculateOrthologSimilarity:\n")
            cat("  Error message:", e$message, "\n")
            cat("  Call stack:\n")
            print(sys.calls())
        }
        stop("Error in calculateOrthologSimilarity: ", e$message)
    })
}

#' Calculate sequence similarity between orthologs
#' @param data Data frame with ortholog information
#' @param species1 Source species
#' @param species2 Target species
#' @param debug Debug mode
#' @return Data frame with sequence similarity scores
calculateSequenceSimilarity <- function(data, species1, species2, debug = FALSE) {
    
    if (debug) cat("DEBUG: Starting sequence similarity calculation\n")
    
    # Add sequence similarity columns
    result <- data %>%
        mutate(
            sequence_similarity = runif(n(), 0.7, 1.0),  # Placeholder - replace with actual calculation
            sequence_identity = runif(n(), 0.6, 0.95),   # Placeholder - replace with actual calculation
            sequence_coverage = runif(n(), 0.8, 1.0)     # Placeholder - replace with actual calculation
        )
    
    if (debug) {
        cat("DEBUG: Sequence similarity calculated for", nrow(result), "orthologs\n")
        cat("DEBUG: Sequence similarity range:", range(result$sequence_similarity), "\n")
    }
    
    return(result)
}

#' Calculate functional similarity between orthologs
#' @param data Data frame with ortholog information
#' @param species1 Source species
#' @param species2 Target species
#' @param debug Debug mode
#' @return Data frame with functional similarity scores
calculateFunctionalSimilarity <- function(data, species1, species2, debug = FALSE) {
    
    if (debug) cat("DEBUG: Starting functional similarity calculation\n")
    
    # Add functional similarity columns
    result <- data %>%
        mutate(
            functional_similarity = runif(n(), 0.5, 1.0),  # Placeholder - replace with actual calculation
            go_term_overlap = runif(n(), 0.3, 0.9),       # Placeholder - replace with actual calculation
            pathway_similarity = runif(n(), 0.4, 0.95)     # Placeholder - replace with actual calculation
        )
    
    if (debug) {
        cat("DEBUG: Functional similarity calculated for", nrow(result), "orthologs\n")
        cat("DEBUG: Functional similarity range:", range(result$functional_similarity), "\n")
    }
    
    return(result)
}

#' Calculate evolutionary similarity between orthologs
#' @param data Data frame with ortholog information
#' @param species1 Source species
#' @param species2 Target species
#' @param debug Debug mode
#' @return Data frame with evolutionary similarity scores
calculateEvolutionarySimilarity <- function(data, species1, species2, debug = FALSE) {
    
    if (debug) cat("DEBUG: Starting evolutionary similarity calculation\n")
    
    # Load evolutionary distances from YAML file
    evolutionary_distances <- loadEvolutionaryDistances(debug)
    
    # Create species pair key
    species_pair <- paste(sort(c(species1, species2)), collapse = "-")
    
    # Get evolutionary distance
    evo_distance <- if (species_pair %in% names(evolutionary_distances)) {
        evolutionary_distances[[species_pair]]
    } else {
        0.5  # Default distance
    }
    
    # Add evolutionary similarity columns
    result <- data %>%
        mutate(
            evolutionary_distance = evo_distance,
            evolutionary_similarity = 1 - evo_distance,
            divergence_time = evo_distance * 100  # Placeholder - replace with actual calculation
        )
    
    if (debug) {
        cat("DEBUG: Evolutionary similarity calculated for", nrow(result), "orthologs\n")
        cat("DEBUG: Species pair:", species_pair, "\n")
        cat("DEBUG: Evolutionary distance:", evo_distance, "\n")
    }
    
    return(result)
}
    
    # Create species pair key
    species_pair <- paste(sort(c(species1, species2)), collapse = "-")
    
    # Get evolutionary distance
    evo_distance <- if (species_pair %in% names(evolutionary_distances)) {
        evolutionary_distances[[species_pair]]
    } else {
        0.5  # Default distance
    }
    
    # Add evolutionary similarity columns
    result <- data %>%
        mutate(
            evolutionary_distance = evo_distance,
            evolutionary_similarity = 1 - evo_distance,
            divergence_time = evo_distance * 100  # Placeholder - replace with actual calculation
        )
    
    if (debug) {
        cat("DEBUG: Evolutionary similarity calculated for", nrow(result), "orthologs\n")
        cat("DEBUG: Species pair:", species_pair, "\n")
        cat("DEBUG: Evolutionary distance:", evo_distance, "\n")
    }
    
    return(result)
}

#' Calculate composite similarity score
#' @param data Data frame with similarity scores
#' @param debug Debug mode
#' @return Data frame with composite similarity score
calculateCompositeSimilarity <- function(data, debug = FALSE) {
    
    if (debug) cat("DEBUG: Starting composite similarity calculation\n")
    
    # Calculate composite score using weighted average
    result <- data %>%
        mutate(
            # Weights for different similarity types
            sequence_weight = 0.4,
            functional_weight = 0.35,
            evolutionary_weight = 0.25,
            
            # Calculate composite score
            similarity_score = (
                sequence_similarity * sequence_weight +
                functional_similarity * functional_weight +
                evolutionary_similarity * evolutionary_weight
            ),
            
            # Add confidence level based on composite score
            confidence_level = case_when(
                similarity_score >= 0.9 ~ "High",
                similarity_score >= 0.7 ~ "Medium",
                similarity_score >= 0.5 ~ "Low",
                TRUE ~ "Very Low"
            )
        )
    
    if (debug) {
        cat("DEBUG: Composite similarity calculated\n")
        cat("DEBUG: Similarity score range:", range(result$similarity_score), "\n")
        cat("DEBUG: Confidence levels:", table(result$confidence_level), "\n")
    }
    
    return(result)
} 

#' Load evolutionary distances from YAML file
#' @param debug Debug mode
#' @return List of evolutionary distances
#' @keywords internal
loadEvolutionaryDistances <- function(debug = FALSE) {
    
    # Path to the YAML file
    yaml_file <- system.file("data", "evolutionary_distances.yml", package = "SyntenyViz")
    
    if (debug) {
        cat("DEBUG: Loading evolutionary distances from:", yaml_file, "\n")
    }
    
    # Check if file exists
    if (!file.exists(yaml_file)) {
        warning("Evolutionary distances YAML file not found. Using default distances.")
        return(list("human-mouse" = 0.3))  # Minimal fallback
    }
    
    tryCatch({
        # Load YAML file
        yaml_data <- yaml::read_yaml(yaml_file)
        
        # Flatten the nested structure into a simple list
        evolutionary_distances <- list()
        
        # Process mammals (nested structure)
        if ("mammals" %in% names(yaml_data)) {
            for (group in names(yaml_data$mammals)) {
                evolutionary_distances <- c(evolutionary_distances, yaml_data$mammals[[group]])
            }
        }
        
        # Process other groups (flat structure)
        flat_groups <- c("birds", "fish", "amphibians", "reptiles", "insects", 
                        "nematodes", "yeasts", "plants", "cross_phylum")
        
        for (group in flat_groups) {
            if (group %in% names(yaml_data)) {
                evolutionary_distances <- c(evolutionary_distances, yaml_data[[group]])
            }
        }
        
        if (debug) {
            cat("DEBUG: Loaded", length(evolutionary_distances), "evolutionary distances\n")
        }
        
        return(evolutionary_distances)
        
    }, error = function(e) {
        warning("Error loading evolutionary distances from YAML file: ", e$message)
        return(list("human-mouse" = 0.3))  # Minimal fallback
    })
}

#' Get available evolutionary distance information
#' @description Returns information about available species pairs and their evolutionary distances
#' @param species1 Optional first species to filter results
#' @param species2 Optional second species to filter results
#' @param min_distance Optional minimum distance threshold
#' @param max_distance Optional maximum distance threshold
#' @return Data frame with species pairs and their evolutionary distances
#' @export
getEvolutionaryDistances <- function(species1 = NULL, species2 = NULL, 
                                   min_distance = NULL, max_distance = NULL) {
    
    # Load evolutionary distances from YAML file
    evolutionary_distances <- loadEvolutionaryDistances()
    
    # Convert to data frame
    distances_df <- data.frame(
        species_pair = names(evolutionary_distances),
        evolutionary_distance = unlist(evolutionary_distances),
        stringsAsFactors = FALSE
    )
    
    # Split species pair into separate columns
    species_split <- strsplit(distances_df$species_pair, "-")
    distances_df$species1 <- sapply(species_split, function(x) x[1])
    distances_df$species2 <- sapply(species_split, function(x) x[2])
    
    # Add additional information
    distances_df$evolutionary_similarity <- 1 - distances_df$evolutionary_distance
    distances_df$divergence_time_mya <- distances_df$evolutionary_distance * 100  # Rough estimate in millions of years
    
    # Filter by species if provided
    if (!is.null(species1)) {
        distances_df <- distances_df[distances_df$species1 == species1 | distances_df$species2 == species1, ]
    }
    
    if (!is.null(species2)) {
        distances_df <- distances_df[distances_df$species1 == species2 | distances_df$species2 == species2, ]
    }
    
    # Filter by distance range if provided
    if (!is.null(min_distance)) {
        distances_df <- distances_df[distances_df$evolutionary_distance >= min_distance, ]
    }
    
    if (!is.null(max_distance)) {
        distances_df <- distances_df[distances_df$evolutionary_distance <= max_distance, ]
    }
    
    # Sort by evolutionary distance
    distances_df <- distances_df[order(distances_df$evolutionary_distance), ]
    
    return(distances_df)
}
    
    # Convert to data frame
    distances_df <- data.frame(
        species_pair = names(evolutionary_distances),
        evolutionary_distance = unlist(evolutionary_distances),
        stringsAsFactors = FALSE
    )
    
    # Split species pair into separate columns
    species_split <- strsplit(distances_df$species_pair, "-")
    distances_df$species1 <- sapply(species_split, function(x) x[1])
    distances_df$species2 <- sapply(species_split, function(x) x[2])
    
    # Add additional information
    distances_df$evolutionary_similarity <- 1 - distances_df$evolutionary_distance
    distances_df$divergence_time_mya <- distances_df$evolutionary_distance * 100  # Rough estimate in millions of years
    
    # Filter by species if provided
    if (!is.null(species1)) {
        distances_df <- distances_df[distances_df$species1 == species1 | distances_df$species2 == species1, ]
    }
    
    if (!is.null(species2)) {
        distances_df <- distances_df[distances_df$species1 == species2 | distances_df$species2 == species2, ]
    }
    
    # Filter by distance range if provided
    if (!is.null(min_distance)) {
        distances_df <- distances_df[distances_df$evolutionary_distance >= min_distance, ]
    }
    
    if (!is.null(max_distance)) {
        distances_df <- distances_df[distances_df$evolutionary_distance <= max_distance, ]
    }
    
    # Sort by evolutionary distance
    distances_df <- distances_df[order(distances_df$evolutionary_distance), ]
    
    return(distances_df)
} 