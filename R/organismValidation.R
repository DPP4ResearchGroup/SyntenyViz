#' Validate organism support for specific operations
#'
#' @description This function checks if an organism supports specific operations
#' and returns detailed capability information.
#'
#' @param orgm A character string specifying the organism abbreviation
#' @param operation A character string specifying the operation ("ortholog_search", "plotting", "synteny_analysis")
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing support status, capabilities, and alternatives
#'
#' @examples
#' \dontrun{
#'   # Check if human supports plotting
#'   validation <- validateOrganismSupport("Hsapiens", "plotting")
#' }
#'
#' @export
validateOrganismSupport <- function(orgm, operation, verbose = FALSE) {
    
    # Input validation
    if (missing(orgm) || missing(operation)) {
        stop("Both 'orgm' and 'operation' parameters are required")
    }
    
    if (!is.character(orgm) || length(orgm) != 1) {
        stop("'orgm' must be a single character string")
    }
    
    if (!is.character(operation) || length(operation) != 1) {
        stop("'operation' must be a single character string")
    }
    
    if (!operation %in% c("ortholog_search", "plotting", "synteny_analysis")) {
        stop("'operation' must be one of: 'ortholog_search', 'plotting', 'synteny_analysis'")
    }
    
    if (verbose) {
        message("Validating organism support for: ", orgm, " (", operation, ")")
    }
    
    tryCatch({
        # Get organism capabilities
        capabilities <- getOrganismCapabilitiesInternal(orgm, verbose = verbose)
        
        # Check specific operation support
        supported <- FALSE
        if (operation == "ortholog_search") {
            supported <- capabilities$ortholog_search
        } else if (operation == "plotting") {
            supported <- capabilities$plotting
        } else if (operation == "synteny_analysis") {
            supported <- capabilities$synteny_analysis
        }
        
        # Get alternatives if not supported
        alternatives <- character(0)
        if (!supported) {
            alternatives <- suggestOrganismAlternatives(orgm, operation)
        }
        
        result <- list(
            supported = supported,
            capabilities = capabilities,
            alternatives = alternatives,
            organism = orgm,
            operation = operation
        )
        
        if (verbose) {
            if (supported) {
                message("Organism ", orgm, " supports ", operation)
            } else {
                message("Organism ", orgm, " does NOT support ", operation)
                if (length(alternatives) > 0) {
                    message("Suggested alternatives: ", paste(alternatives, collapse = ", "))
                }
            }
        }
        
        return(result)
        
    }, error = function(e) {
        stop("Error in validateOrganismSupport: ", e$message)
    })
}

#' Get supported operations for an organism
#'
#' @description This function returns a list of all supported operations for an organism.
#'
#' @param orgm A character string specifying the organism abbreviation
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing supported operations and capability details
#'
#' @examples
#' \dontrun{
#'   # Get all capabilities for human
#'   capabilities <- getSupportedOperations("Hsapiens")
#' }
#'
#' @export
getSupportedOperations <- function(orgm, verbose = FALSE) {
    
    # Input validation
    if (missing(orgm)) {
        stop("'orgm' parameter is required")
    }
    
    if (!is.character(orgm) || length(orgm) != 1) {
        stop("'orgm' must be a single character string")
    }
    
    if (verbose) {
        message("Getting supported operations for: ", orgm)
    }
    
    tryCatch({
        # Get organism capabilities
        capabilities <- getOrganismCapabilities(orgm, verbose = verbose)
        
        # List supported operations
        supported_ops <- character(0)
        if (capabilities$ortholog_search) supported_ops <- c(supported_ops, "ortholog_search")
        if (capabilities$plotting) supported_ops <- c(supported_ops, "plotting")
        if (capabilities$synteny_analysis) supported_ops <- c(supported_ops, "synteny_analysis")
        
        result <- list(
            organism = orgm,
            supported_operations = supported_ops,
            capabilities = capabilities
        )
        
        if (verbose) {
            message("Supported operations for ", orgm, ": ", paste(supported_ops, collapse = ", "))
        }
        
        return(result)
        
    }, error = function(e) {
        stop("Error in getSupportedOperations: ", e$message)
    })
}

#' Check plotting compatibility for organism list
#'
#' @description This function validates plotting compatibility for a list of organisms.
#'
#' @param orgms_list A character vector of organism abbreviations
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing compatibility status and details
#'
#' @examples
#' \dontrun{
#'   # Check plotting compatibility for multiple organisms
#'   compatibility <- checkPlottingCompatibility(c("Hsapiens", "Mmusculus", "Athaliana"))
#' }
#'
#' @export
checkPlottingCompatibility <- function(orgms_list, verbose = FALSE) {
    
    # Input validation
    if (missing(orgms_list)) {
        stop("'orgms_list' parameter is required")
    }
    
    if (!is.character(orgms_list) || length(orgms_list) == 0) {
        stop("'orgms_list' must be a non-empty character vector")
    }
    
    if (verbose) {
        message("Checking plotting compatibility for ", length(orgms_list), " organisms")
    }
    
    tryCatch({
        # Check each organism
        compatible_orgms <- character(0)
        incompatible_orgms <- character(0)
        warnings <- character(0)
        
        for (orgm in orgms_list) {
            validation <- validateOrganismSupport(orgm, "plotting", verbose = FALSE)
            if (validation$supported) {
                compatible_orgms <- c(compatible_orgms, orgm)
            } else {
                incompatible_orgms <- c(incompatible_orgms, orgm)
                warnings <- c(warnings, paste("Organism", orgm, "not supported for plotting"))
            }
        }
        
        # Check if we have enough organisms for plotting
        if (length(compatible_orgms) == 0) {
            warning("No organisms in the list support plotting")
        } else if (length(compatible_orgms) < length(orgms_list)) {
            warning("Only ", length(compatible_orgms), " out of ", length(orgms_list), " organisms support plotting")
        }
        
        result <- list(
            compatible_organisms = compatible_orgms,
            incompatible_organisms = incompatible_orgms,
            all_compatible = length(incompatible_orgms) == 0,
            warnings = warnings,
            total_organisms = length(orgms_list),
            compatible_count = length(compatible_orgms)
        )
        
        if (verbose) {
            message("Plotting compatibility check complete:")
            message("  Compatible: ", length(compatible_orgms), " organisms")
            message("  Incompatible: ", length(incompatible_orgms), " organisms")
        }
        
        return(result)
        
    }, error = function(e) {
        stop("Error in checkPlottingCompatibility: ", e$message)
    })
}

#' Suggest alternative organisms for unsupported ones
#'
#' @description This function suggests alternative organisms when the requested organism
#' doesn't support a specific operation.
#'
#' @param unsupported_orgms A character vector of unsupported organism abbreviations
#' @param operation A character string specifying the operation
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A character vector of suggested alternative organisms
#'
#' @examples
#' \dontrun{
#'   # Suggest alternatives for plotting
#'   alternatives <- suggestOrganismAlternatives("Athaliana", "plotting")
#' }
#'
#' @export
suggestOrganismAlternatives <- function(unsupported_orgms, operation, verbose = FALSE) {
    
    # Input validation
    if (missing(unsupported_orgms) || missing(operation)) {
        stop("Both 'unsupported_orgms' and 'operation' parameters are required")
    }
    
    if (!is.character(unsupported_orgms) || length(unsupported_orgms) == 0) {
        stop("'unsupported_orgms' must be a non-empty character vector")
    }
    
    if (!is.character(operation) || length(operation) != 1) {
        stop("'operation' must be a single character string")
    }
    
    if (!operation %in% c("ortholog_search", "plotting", "synteny_analysis")) {
        stop("'operation' must be one of: 'ortholog_search', 'plotting', 'synteny_analysis'")
    }
    
    if (verbose) {
        message("Suggesting alternatives for ", length(unsupported_orgms), " organisms (", operation, ")")
    }
    
    tryCatch({
        # Get all organisms that support the operation
        all_orgms <- c("Hsapiens", "Mmusculus", "Rnorvegicus", "Mmulatta", "Ptroglodytes", 
                      "Cfamiliaris", "Btaurus", "Sscrofa", "Ggallus", "Drerio", 
                      "Dmelanogaster", "Celegans", "Scerevisiae", "Athaliana", 
                      "Osativa", "Xtropicalis", "Agambiae", "Spombe", "Klactis", 
                      "Ncrassa", "Moryzae", "Egossypii")
        
        supported_orgms <- character(0)
        for (orgm in all_orgms) {
            # Get capabilities directly to avoid circular call
            capabilities <- getOrganismCapabilitiesInternal(orgm, verbose = FALSE)
            supported <- FALSE
            if (operation == "ortholog_search") {
                supported <- capabilities$ortholog_search
            } else if (operation == "plotting") {
                supported <- capabilities$plotting
            } else if (operation == "synteny_analysis") {
                supported <- capabilities$synteny_analysis
            }
            if (supported) {
                supported_orgms <- c(supported_orgms, orgm)
            }
        }
        
        # Filter out the unsupported organisms
        alternatives <- setdiff(supported_orgms, unsupported_orgms)
        
        # Prioritize alternatives based on taxonomic similarity (simplified)
        if (operation == "plotting") {
            # For plotting, prioritize model organisms
            priority_orgms <- c("Hsapiens", "Mmusculus", "Drerio", "Dmelanogaster", "Celegans", "Scerevisiae")
            alternatives <- c(intersect(alternatives, priority_orgms), 
                            setdiff(alternatives, priority_orgms))
        }
        
        if (verbose) {
            message("Found ", length(alternatives), " alternative organisms")
        }
        
        return(alternatives)
        
    }, error = function(e) {
        stop("Error in suggestOrganismAlternatives: ", e$message)
    })
}

#' Get detailed organism capabilities (internal)
#'
#' @description This function returns detailed capability information for an organism.
#' This is the internal implementation used by other functions.
#'
#' @param orgm A character string specifying the organism abbreviation
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing detailed capability information
#'
#' @examples
#' \dontrun{
#'   # Get detailed capabilities for human
#'   capabilities <- getOrganismCapabilitiesInternal("Hsapiens")
#' }
#'
#' @export
getOrganismCapabilitiesInternal <- function(orgm, verbose = FALSE) {
    
    # Input validation
    if (missing(orgm)) {
        stop("'orgm' parameter is required")
    }
    
    if (!is.character(orgm) || length(orgm) != 1) {
        stop("'orgm' must be a single character string")
    }
    
    if (verbose) {
        message("Getting capabilities for: ", orgm)
    }
    
    tryCatch({
        # Organism capability matrix (simplified version)
        capability_matrix <- list(
            "Hsapiens" = list(ortholog_search = TRUE, plotting = TRUE, synteny_analysis = TRUE, support_level = "Full"),
            "Mmusculus" = list(ortholog_search = TRUE, plotting = TRUE, synteny_analysis = TRUE, support_level = "Full"),
            "Rnorvegicus" = list(ortholog_search = TRUE, plotting = TRUE, synteny_analysis = TRUE, support_level = "Full"),
            "Mmulatta" = list(ortholog_search = TRUE, plotting = TRUE, synteny_analysis = TRUE, support_level = "Full"),
            "Ptroglodytes" = list(ortholog_search = TRUE, plotting = TRUE, synteny_analysis = TRUE, support_level = "Full"),
            "Cfamiliaris" = list(ortholog_search = TRUE, plotting = TRUE, synteny_analysis = TRUE, support_level = "Full"),
            "Btaurus" = list(ortholog_search = TRUE, plotting = TRUE, synteny_analysis = TRUE, support_level = "Full"),
            "Sscrofa" = list(ortholog_search = TRUE, plotting = TRUE, synteny_analysis = TRUE, support_level = "Full"),
            "Ggallus" = list(ortholog_search = TRUE, plotting = TRUE, synteny_analysis = TRUE, support_level = "Full"),
            "Drerio" = list(ortholog_search = TRUE, plotting = TRUE, synteny_analysis = TRUE, support_level = "Full"),
            "Dmelanogaster" = list(ortholog_search = TRUE, plotting = TRUE, synteny_analysis = TRUE, support_level = "Full"),
            "Celegans" = list(ortholog_search = TRUE, plotting = TRUE, synteny_analysis = FALSE, support_level = "Partial"),
            "Scerevisiae" = list(ortholog_search = TRUE, plotting = TRUE, synteny_analysis = TRUE, support_level = "Full"),
            "Athaliana" = list(ortholog_search = TRUE, plotting = FALSE, synteny_analysis = FALSE, support_level = "Ortholog Only"),
            "Osativa" = list(ortholog_search = TRUE, plotting = FALSE, synteny_analysis = FALSE, support_level = "Ortholog Only"),
            "Xtropicalis" = list(ortholog_search = TRUE, plotting = FALSE, synteny_analysis = FALSE, support_level = "Ortholog Only"),
            "Agambiae" = list(ortholog_search = TRUE, plotting = FALSE, synteny_analysis = FALSE, support_level = "Ortholog Only"),
            "Spombe" = list(ortholog_search = TRUE, plotting = FALSE, synteny_analysis = FALSE, support_level = "Ortholog Only"),
            "Klactis" = list(ortholog_search = TRUE, plotting = FALSE, synteny_analysis = FALSE, support_level = "Ortholog Only"),
            "Ncrassa" = list(ortholog_search = TRUE, plotting = FALSE, synteny_analysis = FALSE, support_level = "Ortholog Only"),
            "Moryzae" = list(ortholog_search = TRUE, plotting = FALSE, synteny_analysis = FALSE, support_level = "Ortholog Only"),
            "Egossypii" = list(ortholog_search = TRUE, plotting = FALSE, synteny_analysis = FALSE, support_level = "Ortholog Only")
        )
        
        if (orgm %in% names(capability_matrix)) {
            capabilities <- capability_matrix[[orgm]]
        } else {
            # Unknown organism - assume minimal support
            capabilities <- list(
                ortholog_search = FALSE,
                plotting = FALSE,
                synteny_analysis = FALSE,
                support_level = "Unknown"
            )
            warning("Unknown organism: ", orgm, " - assuming no support")
        }
        
        # Add additional metadata
        capabilities$organism <- orgm
        capabilities$genome_assembly <- getGenomeAssembly(orgm)
        capabilities$database_support <- checkDatabaseAvailability(orgm)
        
        if (verbose) {
            message("Capabilities for ", orgm, ":")
            message("  Ortholog search: ", capabilities$ortholog_search)
            message("  Plotting: ", capabilities$plotting)
            message("  Synteny analysis: ", capabilities$synteny_analysis)
            message("  Support level: ", capabilities$support_level)
        }
        
        return(capabilities)
        
    }, error = function(e) {
        stop("Error in getOrganismCapabilitiesInternal: ", e$message)
    })
}

#' Check database availability for organism (internal)
#'
#' @description This function checks if required databases are available for an organism.
#' This is the internal implementation used by other functions.
#'
#' @param orgm A character string specifying the organism abbreviation
#'
#' @return A list containing database availability information
#'
#' @examples
#' \dontrun{
#'   # Check database availability for human
#'   db_status <- checkDatabaseAvailabilityInternal("Hsapiens")
#' }
#'
#' @export
checkDatabaseAvailabilityInternal <- function(orgm) {
    
    # Input validation
    if (missing(orgm)) {
        stop("'orgm' parameter is required")
    }
    
    if (!is.character(orgm) || length(orgm) != 1) {
        stop("'orgm' must be a single character string")
    }
    
    tryCatch({
        # Database mapping
        db_mapping <- list(
            "Hsapiens" = c("org.Hs.eg.db", "TxDb.Hsapiens.UCSC.hg38.knownGene"),
            "Mmusculus" = c("org.Mm.eg.db", "TxDb.Mmusculus.UCSC.mm10.knownGene"),
            "Rnorvegicus" = c("org.Rn.eg.db", "TxDb.Rnorvegicus.UCSC.rn6.refGene"),
            "Mmulatta" = c("org.Mmu.eg.db", "TxDb.Mmulatta.UCSC.rheMac10.refGene"),
            "Ptroglodytes" = c("org.Pt.eg.db", "TxDb.Ptroglodytes.UCSC.panTro6.refGene"),
            "Cfamiliaris" = c("org.Cf.eg.db", "TxDb.Cfamiliaris.UCSC.canFam3.refGene"),
            "Btaurus" = c("org.Bt.eg.db", "TxDb.Btaurus.UCSC.bosTau9.refGene"),
            "Sscrofa" = c("org.Ss.eg.db", "TxDb.Sscrofa.UCSC.susScr11.refGene"),
            "Ggallus" = c("org.Gg.eg.db", "TxDb.Ggallus.UCSC.galGal6.refGene"),
            "Drerio" = c("org.Dr.eg.db", "TxDb.Drerio.UCSC.danRer11.refGene"),
            "Dmelanogaster" = c("org.Dm.eg.db", "TxDb.Dmelanogaster.UCSC.dm6.ensGene"),
            "Celegans" = c("org.Ce.eg.db", "TxDb.Celegans.UCSC.ce11.refGene"),
            "Scerevisiae" = c("org.Sc.sgd.db", "TxDb.Scerevisiae.UCSC.sacCer3.sgdGene"),
            "Athaliana" = c("org.At.tair.db"),
            "Osativa" = character(0),
            "Xtropicalis" = character(0),
            "Agambiae" = c("org.Ag.eg.db"),
            "Spombe" = c("org.Spombe.eg.db"),
            "Klactis" = character(0),
            "Ncrassa" = character(0),
            "Moryzae" = character(0),
            "Egossypii" = character(0)
        )
        
        required_dbs <- db_mapping[[orgm]]
        if (is.null(required_dbs)) {
            required_dbs <- character(0)
        }
        
        # Check availability
        available_dbs <- character(0)
        missing_dbs <- character(0)
        
        for (db in required_dbs) {
            if (requireNamespace(db, quietly = TRUE)) {
                available_dbs <- c(available_dbs, db)
            } else {
                missing_dbs <- c(missing_dbs, db)
            }
        }
        
        result <- list(
            organism = orgm,
            required_databases = required_dbs,
            available_databases = available_dbs,
            missing_databases = missing_dbs,
            all_available = length(missing_dbs) == 0
        )
        
        return(result)
        
    }, error = function(e) {
        stop("Error in checkDatabaseAvailabilityInternal: ", e$message)
    })
}
