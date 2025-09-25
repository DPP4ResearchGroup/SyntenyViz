#' Get detailed organism capabilities report
#'
#' @description This function returns a detailed capability report for an organism
#' including all supported operations, database requirements, and metadata.
#'
#' @param orgm A character string specifying the organism abbreviation
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing detailed capability report
#'
#' @examples
#' \dontrun{
#'   # Get detailed capabilities for human
#'   report <- getOrganismCapabilities("Hsapiens")
#' }
#'
#' @export
getOrganismCapabilities <- function(orgm, verbose = FALSE) {
    
    # Input validation
    if (missing(orgm)) {
        stop("'orgm' parameter is required")
    }
    
    if (!is.character(orgm) || length(orgm) != 1) {
        stop("'orgm' must be a single character string")
    }
    
    if (verbose) {
        message("Generating detailed capability report for: ", orgm)
    }
    
    tryCatch({
        # Get basic capabilities from organismValidation.R
        capabilities <- getOrganismCapabilitiesInternal(orgm, verbose = FALSE)
        
        # Get database availability
        db_status <- checkDatabaseAvailabilityInternal(orgm)
        
        # Get genome assembly information
        genome_assembly <- getGenomeAssembly(orgm)
        
        # Create detailed report
        report <- list(
            organism = orgm,
            capabilities = capabilities,
            database_status = db_status,
            genome_assembly = genome_assembly,
            support_level = capabilities$support_level,
            recommendations = character(0),
            warnings = character(0)
        )
        
        # Generate recommendations based on capabilities
        if (capabilities$ortholog_search && !capabilities$plotting) {
            report$recommendations <- c(report$recommendations, 
                                      "This organism supports ortholog search but not plotting")
            report$recommendations <- c(report$recommendations, 
                                      "Consider using ortholog search results for basic analysis")
        }
        
        if (!db_status$all_available) {
            report$warnings <- c(report$warnings, 
                               paste("Missing databases:", paste(db_status$missing_databases, collapse = ", ")))
            report$recommendations <- c(report$recommendations, 
                                      "Install missing databases for full functionality")
        }
        
        if (capabilities$support_level == "Ortholog Only") {
            report$recommendations <- c(report$recommendations, 
                                      "Consider using alternative organisms for plotting and synteny analysis")
        }
        
        if (verbose) {
            message("Capability report generated for ", orgm)
            message("  Support level: ", capabilities$support_level)
            message("  Ortholog search: ", capabilities$ortholog_search)
            message("  Plotting: ", capabilities$plotting)
            message("  Synteny analysis: ", capabilities$synteny_analysis)
            message("  Database status: ", if (db_status$all_available) "Complete" else "Incomplete")
        }
        
        return(report)
        
    }, error = function(e) {
        stop("Error in getOrganismCapabilities: ", e$message)
    })
}

#' Validate organism compatibility for specific operations
#'
#' @description This function validates that a list of organisms is compatible
#' for specific operations and provides detailed compatibility information.
#'
#' @param orgms_list A character vector of organism abbreviations
#' @param operations A character vector of operations to validate
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing compatibility validation results
#'
#' @examples
#' \dontrun{
#'   # Validate organisms for plotting
#'   validation <- validateOrganismCompatibility(c("Hsapiens", "Mmusculus"), "plotting")
#' }
#'
#' @export
validateOrganismCompatibility <- function(orgms_list, operations, verbose = FALSE) {
    
    # Input validation
    if (missing(orgms_list) || missing(operations)) {
        stop("Both 'orgms_list' and 'operations' parameters are required")
    }
    
    if (!is.character(orgms_list) || length(orgms_list) == 0) {
        stop("'orgms_list' must be a non-empty character vector")
    }
    
    if (!is.character(operations) || length(operations) == 0) {
        stop("'operations' must be a non-empty character vector")
    }
    
    if (verbose) {
        message("Validating organism compatibility for ", length(orgms_list), " organisms and ", length(operations), " operations")
    }
    
    tryCatch({
        # Validate each operation
        operation_results <- list()
        overall_compatible <- TRUE
        
        for (operation in operations) {
            if (operation == "plotting") {
                compatibility <- checkPlottingCompatibility(orgms_list, verbose = FALSE)
            } else {
                # Check individual organism support for other operations
                compatible_orgms <- character(0)
                incompatible_orgms <- character(0)
                
                for (orgm in orgms_list) {
                    validation <- validateOrganismSupport(orgm, operation, verbose = FALSE)
                    if (validation$supported) {
                        compatible_orgms <- c(compatible_orgms, orgm)
                    } else {
                        incompatible_orgms <- c(incompatible_orgms, orgm)
                    }
                }
                
                compatibility <- list(
                    compatible_organisms = compatible_orgms,
                    incompatible_organisms = incompatible_orgms,
                    all_compatible = length(incompatible_orgms) == 0,
                    total_organisms = length(orgms_list),
                    compatible_count = length(compatible_orgms)
                )
            }
            
            operation_results[[operation]] <- compatibility
            if (!compatibility$all_compatible) {
                overall_compatible <- FALSE
            }
        }
        
        # Generate summary
        summary <- list(
            overall_compatible = overall_compatible,
            total_organisms = length(orgms_list),
            total_operations = length(operations),
            operation_results = operation_results
        )
        
        if (verbose) {
            if (overall_compatible) {
                message("All organisms are compatible with all operations")
            } else {
                message("Some organisms are not compatible with some operations")
                for (operation in operations) {
                    result <- operation_results[[operation]]
                    if (!result$all_compatible) {
                        message("  ", operation, ": ", result$compatible_count, "/", result$total_organisms, " compatible")
                    }
                }
            }
        }
        
        return(summary)
        
    }, error = function(e) {
        stop("Error in validateOrganismCompatibility: ", e$message)
    })
}

#' Generate comprehensive organism support report
#'
#' @description This function generates a comprehensive report of organism support
#' across all available organisms and operations.
#'
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing comprehensive organism support report
#'
#' @examples
#' \dontrun{
#'   # Generate comprehensive organism support report
#'   report <- generateOrganismReport()
#' }
#'
#' @export
generateOrganismReport <- function(verbose = FALSE) {
    
    if (verbose) {
        message("Generating comprehensive organism support report...")
    }
    
    tryCatch({
        # Get all available organisms
        all_orgms <- c("Hsapiens", "Mmusculus", "Rnorvegicus", "Mmulatta", "Ptroglodytes", 
                      "Cfamiliaris", "Btaurus", "Sscrofa", "Ggallus", "Drerio", 
                      "Dmelanogaster", "Celegans", "Scerevisiae", "Athaliana", 
                      "Osativa", "Xtropicalis", "Agambiae", "Spombe", "Klactis", 
                      "Ncrassa", "Moryzae", "Egossypii")
        
        # Generate report for each organism
        organism_reports <- list()
        support_levels <- list(
            Full = character(0),
            Partial = character(0),
            "Ortholog Only" = character(0),
            Unknown = character(0)
        )
        
        for (orgm in all_orgms) {
            tryCatch({
                report <- getOrganismCapabilities(orgm, verbose = FALSE)
                organism_reports[[orgm]] <- report
                support_levels[[report$support_level]] <- c(support_levels[[report$support_level]], orgm)
            }, error = function(e) {
                if (verbose) {
                    message("Error generating report for ", orgm, ": ", e$message)
                }
                support_levels$Unknown <- c(support_levels$Unknown, orgm)
            })
        }
        
        # Generate summary statistics
        total_orgms <- length(all_orgms)
        successful_reports <- length(organism_reports)
        
        # Count by support level
        support_counts <- sapply(support_levels, length)
        
        # Count by capability
        ortholog_search_count <- sum(sapply(organism_reports, function(x) x$capabilities$ortholog_search))
        plotting_count <- sum(sapply(organism_reports, function(x) x$capabilities$plotting))
        synteny_analysis_count <- sum(sapply(organism_reports, function(x) x$capabilities$synteny_analysis))
        
        # Generate comprehensive report
        comprehensive_report <- list(
            summary = list(
                total_organisms = total_orgms,
                successful_reports = successful_reports,
                support_level_counts = support_counts,
                capability_counts = list(
                    ortholog_search = ortholog_search_count,
                    plotting = plotting_count,
                    synteny_analysis = synteny_analysis_count
                )
            ),
            support_levels = support_levels,
            organism_reports = organism_reports,
            recommendations = character(0)
        )
        
        # Generate recommendations
        if (support_counts["Full"] > 0) {
            comprehensive_report$recommendations <- c(
                comprehensive_report$recommendations,
                paste("Use", support_counts["Full"], "organisms with full support for comprehensive analysis")
            )
        }
        
        if (support_counts["Ortholog Only"] > 0) {
            comprehensive_report$recommendations <- c(
                comprehensive_report$recommendations,
                paste("Consider", support_counts["Ortholog Only"], "organisms for ortholog-only analysis")
            )
        }
        
        if (verbose) {
            message("Comprehensive organism support report generated:")
            message("  Total organisms: ", total_orgms)
            message("  Successful reports: ", successful_reports)
            message("  Full support: ", support_counts["Full"])
            message("  Partial support: ", support_counts["Partial"])
            message("  Ortholog only: ", support_counts["Ortholog Only"])
            message("  Unknown: ", support_counts["Unknown"])
        }
        
        return(comprehensive_report)
        
    }, error = function(e) {
        stop("Error in generateOrganismReport: ", e$message)
    })
}

#' Check database availability for organism
#'
#' @description This function checks if required databases are available for an organism
#' and provides installation guidance.
#'
#' @param orgm A character string specifying the organism abbreviation
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing database availability information and installation guidance
#'
#' @examples
#' \dontrun{
#'   # Check database availability for human
#'   db_status <- checkDatabaseAvailability("Hsapiens")
#' }
#'
#' @export
checkDatabaseAvailability <- function(orgm, verbose = FALSE) {
    
    # Input validation
    if (missing(orgm)) {
        stop("'orgm' parameter is required")
    }
    
    if (!is.character(orgm) || length(orgm) != 1) {
        stop("'orgm' must be a single character string")
    }
    
    if (verbose) {
        message("Checking database availability for: ", orgm)
    }
    
    tryCatch({
        # Database mapping (same as in organismValidation.R)
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
        
        # Generate installation commands
        installation_commands <- character(0)
        if (length(missing_dbs) > 0) {
            installation_commands <- paste0("BiocManager::install(c(\"", paste(missing_dbs, collapse = "\", \""), "\"))")
        }
        
        result <- list(
            organism = orgm,
            required_databases = required_dbs,
            available_databases = available_dbs,
            missing_databases = missing_dbs,
            all_available = length(missing_dbs) == 0,
            installation_commands = installation_commands
        )
        
        if (verbose) {
            message("Database availability check complete for ", orgm)
            message("  Required: ", length(required_dbs), " databases")
            message("  Available: ", length(available_dbs), " databases")
            message("  Missing: ", length(missing_dbs), " databases")
            if (length(missing_dbs) > 0) {
                message("  Installation command: ", installation_commands)
            }
        }
        
        return(result)
        
    }, error = function(e) {
        stop("Error in checkDatabaseAvailability: ", e$message)
    })
}

#' Suggest organism alternatives for unsupported ones (enhanced)
#'
#' @description This function suggests alternative organisms when the requested organism
#' doesn't support a specific operation, with detailed reasoning.
#'
#' @param unsupported_orgms A character vector of unsupported organism abbreviations
#' @param operation A character string specifying the operation
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing suggested alternatives with detailed reasoning
#'
#' @examples
#' \dontrun{
#'   # Suggest alternatives for plotting
#'   alternatives <- suggestOrganismAlternativesEnhanced("Athaliana", "plotting")
#' }
#'
#' @export
suggestOrganismAlternativesEnhanced <- function(unsupported_orgms, operation, verbose = FALSE) {
    
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
            validation <- validateOrganismSupport(orgm, operation, verbose = FALSE)
            if (validation$supported) {
                supported_orgms <- c(supported_orgms, orgm)
            }
        }
        
        # Filter out the unsupported organisms
        alternatives <- setdiff(supported_orgms, unsupported_orgms)
        
        # Prioritize alternatives based on taxonomic similarity and support level
        if (operation == "plotting") {
            # For plotting, prioritize model organisms with full support
            priority_orgms <- c("Hsapiens", "Mmusculus", "Drerio", "Dmelanogaster", "Celegans", "Scerevisiae")
            alternatives <- c(intersect(alternatives, priority_orgms), 
                            setdiff(alternatives, priority_orgms))
        }
        
        # Generate detailed suggestions
        suggestions <- list(
            alternatives = alternatives,
            reasoning = character(0),
            recommendations = character(0)
        )
        
        if (length(alternatives) > 0) {
            suggestions$reasoning <- c(
                "These organisms support the requested operation",
                "They have been prioritized based on taxonomic similarity and support level"
            )
            
            if (operation == "plotting") {
                suggestions$recommendations <- c(
                    "Consider using model organisms for better database support",
                    "Check database availability before selecting alternatives",
                    "Use validateOrganismSupport() to verify capabilities"
                )
            }
        } else {
            suggestions$reasoning <- c("No alternative organisms found that support the requested operation")
            suggestions$recommendations <- c(
                "Consider using a different operation",
                "Check if the operation is supported by any organisms",
                "Use generateOrganismReport() to see all available capabilities"
            )
        }
        
        if (verbose) {
            message("Found ", length(alternatives), " alternative organisms")
            if (length(alternatives) > 0) {
                message("Top alternatives: ", paste(head(alternatives, 3), collapse = ", "))
            }
        }
        
        return(suggestions)
        
    }, error = function(e) {
        stop("Error in suggestOrganismAlternativesEnhanced: ", e$message)
    })
}
