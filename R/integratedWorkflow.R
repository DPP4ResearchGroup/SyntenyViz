#' Complete workflow from ortholog search to multisynvizPlots
#'
#' @description This function provides a complete integrated workflow from ortholog search
#' to multisynvizPlots with comprehensive error handling and validation.
#'
#' @param orthologs A data frame from getOrthHomolog() containing ortholog mappings
#' @param coords_source A character string specifying source species coordinates
#' @param coords_target A character string specifying target species coordinates
#' @param species_list A character vector of species abbreviations for plotting
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing workflow results and status information
#'
#' @examples
#' \dontrun{
#'   # Complete integrated workflow
#'   result <- orthologToMultisynvizPlot(orthologs, "2:15.95e7:16.45e7", 
#'                                      "2:6.0e7:6.5e7", c("Hsapiens", "Mmusculus"))
#' }
#'
#' @export
orthologToMultisynvizPlot <- function(orthologs, coords_source, coords_target, 
                                     species_list, verbose = FALSE) {
    
    # Input validation
    if (missing(orthologs) || missing(coords_source) || missing(coords_target) || missing(species_list)) {
        stop("All parameters are required: orthologs, coords_source, coords_target, species_list")
    }
    
    if (!is.data.frame(orthologs)) {
        stop("'orthologs' must be a data frame from getOrthHomolog()")
    }
    
    if (!is.character(species_list) || length(species_list) == 0) {
        stop("'species_list' must be a non-empty character vector")
    }
    
    if (verbose) {
        message("Starting integrated workflow: ortholog search to multisynvizPlots")
        message("Species list: ", paste(species_list, collapse = ", "))
    }
    
    tryCatch({
        # Step 1: Validate workflow compatibility
        if (verbose) {
            message("Step 1: Validating workflow compatibility...")
        }
        
        workflow_validation <- validateWorkflowCompatibility(
            list(orthologs = orthologs, coords_source = coords_source, 
                 coords_target = coords_target, species_list = species_list),
            verbose = verbose
        )
        
        if (!workflow_validation$compatible) {
            warning("Workflow validation failed - some issues detected")
            if (verbose) {
                message("Issues found:")
                for (issue in workflow_validation$issues) {
                    message("  - ", issue)
                }
            }
        }
        
        # Step 2: Get ortholog coordinates
        if (verbose) {
            message("Step 2: Retrieving ortholog coordinates...")
        }
        
        ortholog_coords <- getOrthologCoordinates(orthologs, species_list[2], species_list[1], 
                                                coords_source, coords_target, verbose = verbose)
        
        if (is.null(ortholog_coords)) {
            stop("Failed to retrieve ortholog coordinates")
        }
        
        # Step 3: Convert coordinates to GRanges for multisynvizPlots
        if (verbose) {
            message("Step 3: Converting coordinates to GRanges...")
        }
        
        source_gr <- convertToGRanges(ortholog_coords$source, species_list[1], verbose = verbose)
        target_gr <- convertToGRanges(ortholog_coords$target, species_list[2], verbose = verbose)
        
        # Step 4: Create organism collection for multisynvizPlots
        if (verbose) {
            message("Step 4: Creating organism collection...")
        }
        
        orgms_collection <- list()
        
        # Add source species
        orgms_collection <- orgmsAdd(species_list[1], orgmTxDB, coords_source, orgms_collection)
        if (is.null(orgms_collection)) {
            warning("Failed to add source species to collection")
        }
        
        # Add target species
        orgms_collection <- orgmsAdd(species_list[2], orgmTxDB, coords_target, orgms_collection)
        if (is.null(orgms_collection)) {
            warning("Failed to add target species to collection")
        }
        
        # Step 5: Generate multisynvizPlots
        if (verbose) {
            message("Step 5: Generating multi-species plots...")
        }
        
        if (length(orgms_collection) > 0) {
            multisynvizPlots(orgms_collection, verbose = verbose)
        } else {
            warning("No organisms in collection - cannot generate plots")
        }
        
        # Step 6: Create synteny block visualization (optional)
        if (verbose) {
            message("Step 6: Creating synteny block visualization...")
        }
        
        synteny_data <- createSyntenyBlockData(ortholog_coords$source, ortholog_coords$target,
                                             species_list[1], species_list[2], verbose = verbose)
        
        if (!is.null(synteny_data)) {
            plotSyntenyBlocks(synteny_data, plot_type = "comparative", verbose = verbose)
        }
        
        # Prepare results
        result <- list(
            success = TRUE,
            ortholog_coords = ortholog_coords,
            organism_collection = orgms_collection,
            synteny_data = synteny_data,
            workflow_validation = workflow_validation,
            species_used = species_list,
            coordinates = list(source = coords_source, target = coords_target)
        )
        
        if (verbose) {
            message("Integrated workflow completed successfully")
        }
        
        return(result)
        
    }, error = function(e) {
        error_report <- createErrorReport(e, "orthologToMultisynvizPlot", 
                                        list(orthologs = orthologs, coords_source = coords_source,
                                             coords_target = coords_target, species_list = species_list),
                                        verbose = verbose)
        
        if (verbose) {
            message("Error in integrated workflow:")
            message("  ", error_report$error_context$error_message)
            message("Quick fixes:")
            for (fix in error_report$quick_fixes) {
                message("  - ", fix)
            }
        }
        
        return(list(
            success = FALSE,
            error = error_report,
            species_used = species_list,
            coordinates = list(source = coords_source, target = coords_target)
        ))
    })
}

#' Validate workflow compatibility before execution
#'
#' @description This function validates that all parameters and organisms are compatible
#' for the complete workflow before execution begins.
#'
#' @param workflow_parameters A list containing workflow parameters
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing compatibility status and recommendations
#'
#' @examples
#' \dontrun{
#'   # Validate workflow before execution
#'   validation <- validateWorkflowCompatibility(
#'     list(orthologs = orthologs, coords_source = "2:15.95e7:16.45e7", 
#'          coords_target = "2:6.0e7:6.5e7", species_list = c("Hsapiens", "Mmusculus"))
#'   )
#' }
#'
#' @export
validateWorkflowCompatibility <- function(workflow_parameters, verbose = FALSE) {
    
    # Input validation
    if (missing(workflow_parameters)) {
        stop("'workflow_parameters' parameter is required")
    }
    
    if (!is.list(workflow_parameters)) {
        stop("'workflow_parameters' must be a list")
    }
    
    if (verbose) {
        message("Validating workflow compatibility...")
    }
    
    tryCatch({
        issues <- character(0)
        warnings <- character(0)
        recommendations <- character(0)
        
        # Check required parameters
        required_params <- c("orthologs", "coords_source", "coords_target", "species_list")
        missing_params <- setdiff(required_params, names(workflow_parameters))
        if (length(missing_params) > 0) {
            issues <- c(issues, paste("Missing required parameters:", paste(missing_params, collapse = ", ")))
        }
        
        # Validate orthologs
        if ("orthologs" %in% names(workflow_parameters)) {
            orthologs <- workflow_parameters$orthologs
            if (!is.data.frame(orthologs) || nrow(orthologs) == 0) {
                issues <- c(issues, "Orthologs must be a non-empty data frame")
            }
        }
        
        # Validate coordinates
        coord_params <- c("coords_source", "coords_target")
        for (param in coord_params) {
            if (param %in% names(workflow_parameters)) {
                coords <- workflow_parameters[[param]]
                if (!is.character(coords) || length(coords) != 1) {
                    issues <- c(issues, paste(param, "must be a single character string"))
                } else if (!grepl("^\\d+:\\d+[eE]?\\d*:\\d+[eE]?\\d*$", coords)) {
                    issues <- c(issues, paste("Invalid coordinate format for", param, ":", coords))
                    recommendations <- c(recommendations, "Use format 'chromosome:start:end' (e.g., '2:16e7:16.5e7')")
                }
            }
        }
        
        # Validate species list
        if ("species_list" %in% names(workflow_parameters)) {
            species_list <- workflow_parameters$species_list
            if (!is.character(species_list) || length(species_list) == 0) {
                issues <- c(issues, "Species list must be a non-empty character vector")
            } else {
                # Check plotting compatibility
                compatibility <- checkPlottingCompatibility(species_list, verbose = FALSE)
                if (!compatibility$all_compatible) {
                    warnings <- c(warnings, paste("Some species do not support plotting:", 
                                                paste(compatibility$incompatible_organisms, collapse = ", ")))
                    recommendations <- c(recommendations, "Consider using alternative species or removing unsupported ones")
                }
                
                # Check for too many species
                if (length(species_list) > 3) {
                    warnings <- c(warnings, "More than 3 species specified - multisynvizPlots is limited to 3 species")
                    recommendations <- c(recommendations, "Split analysis into multiple plots with 3 or fewer species each")
                }
            }
        }
        
        # Generate recommendations
        if (length(issues) == 0) {
            recommendations <- c(recommendations, "Workflow appears compatible - proceed with execution")
        } else {
            recommendations <- c(recommendations, "Address the issues above before executing the workflow")
        }
        
        result <- list(
            compatible = length(issues) == 0,
            issues = issues,
            warnings = warnings,
            recommendations = recommendations,
            parameters_checked = names(workflow_parameters)
        )
        
        if (verbose) {
            if (result$compatible) {
                message("Workflow compatibility validation passed")
            } else {
                message("Workflow compatibility validation failed with", length(issues), "issues")
                for (issue in issues) {
                    message("  - ", issue)
                }
            }
            if (length(warnings) > 0) {
                message("Warnings:")
                for (warning in warnings) {
                    message("  - ", warning)
                }
            }
        }
        
        return(result)
        
    }, error = function(e) {
        stop("Error in validateWorkflowCompatibility: ", e$message)
    })
}

#' Suggest workflow modifications for incompatible parameters
#'
#' @description This function suggests modifications to make incompatible workflows work.
#'
#' @param incompatible_parameters A list containing incompatible parameters
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing suggested modifications
#'
#' @examples
#' \dontrun{
#'   # Suggest modifications for incompatible workflow
#'   suggestions <- suggestWorkflowModifications(
#'     list(species_list = c("Hsapiens", "Athaliana"), coords_source = "invalid")
#'   )
#' }
#'
#' @export
suggestWorkflowModifications <- function(incompatible_parameters, verbose = FALSE) {
    
    # Input validation
    if (missing(incompatible_parameters)) {
        stop("'incompatible_parameters' parameter is required")
    }
    
    if (!is.list(incompatible_parameters)) {
        stop("'incompatible_parameters' must be a list")
    }
    
    if (verbose) {
        message("Suggesting workflow modifications...")
    }
    
    tryCatch({
        suggestions <- list(
            species_modifications = character(0),
            coordinate_modifications = character(0),
            general_modifications = character(0)
        )
        
        # Suggest species modifications
        if ("species_list" %in% names(incompatible_parameters)) {
            species_list <- incompatible_parameters$species_list
            if (is.character(species_list)) {
                compatibility <- checkPlottingCompatibility(species_list, verbose = FALSE)
                if (!compatibility$all_compatible) {
                    suggestions$species_modifications <- c(
                        suggestions$species_modifications,
                        paste("Remove unsupported species:", paste(compatibility$incompatible_organisms, collapse = ", ")),
                        paste("Consider alternatives:", paste(compatibility$compatible_organisms, collapse = ", "))
                    )
                }
                
                if (length(species_list) > 3) {
                    suggestions$species_modifications <- c(
                        suggestions$species_modifications,
                        "Split into multiple workflows with 3 or fewer species each",
                        "Use the first 3 species for this workflow"
                    )
                }
            }
        }
        
        # Suggest coordinate modifications
        coord_params <- c("coords_source", "coords_target")
        for (param in coord_params) {
            if (param %in% names(incompatible_parameters)) {
                coords <- incompatible_parameters[[param]]
                if (is.character(coords) && !grepl("^\\d+:\\d+[eE]?\\d*:\\d+[eE]?\\d*$", coords)) {
                    suggestions$coordinate_modifications <- c(
                        suggestions$coordinate_modifications,
                        paste("Fix", param, "format - use 'chromosome:start:end' (e.g., '2:16e7:16.5e7')"),
                        paste("Use coordFormat() to convert", param, "to proper format")
                    )
                }
            }
        }
        
        # General modifications
        suggestions$general_modifications <- c(
            "Use validateWorkflowCompatibility() to check parameters before execution",
            "Use validateOrganismSupport() to check individual organism capabilities",
            "Use checkPlottingCompatibility() to validate species lists",
            "Follow the comprehensive user example for proper workflow"
        )
        
        # Add specific suggestions based on issues
        if (length(suggestions$species_modifications) == 0 && 
            length(suggestions$coordinate_modifications) == 0) {
            suggestions$general_modifications <- c(
                suggestions$general_modifications,
                "Check all parameter types and formats",
                "Ensure all required parameters are provided",
                "Use verbose = TRUE for detailed error information"
            )
        }
        
        if (verbose) {
            message("Workflow modification suggestions generated:")
            message("  Species modifications: ", length(suggestions$species_modifications))
            message("  Coordinate modifications: ", length(suggestions$coordinate_modifications))
            message("  General modifications: ", length(suggestions$general_modifications))
        }
        
        return(suggestions)
        
    }, error = function(e) {
        stop("Error in suggestWorkflowModifications: ", e$message)
    })
}
