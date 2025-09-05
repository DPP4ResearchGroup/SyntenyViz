#' Handle organism-related errors with standardized messaging
#'
#' @description This function provides standardized error handling for organism-related issues
#' with specific guidance and suggestions.
#'
#' @param orgm A character string specifying the organism abbreviation
#' @param operation A character string specifying the operation that failed
#' @param error_context A character string providing additional context about the error
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing error information and suggested actions
#'
#' @examples
#' \dontrun{
#'   # Handle organism error
#'   error_info <- handleOrganismError("Athaliana", "plotting", "No plotting support")
#' }
#'
#' @export
handleOrganismError <- function(orgm, operation, error_context = "", verbose = FALSE) {
    
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
    
    if (verbose) {
        message("Handling organism error for: ", orgm, " (", operation, ")")
    }
    
    tryCatch({
        # Get organism capabilities
        capabilities <- getOrganismCapabilities(orgm, verbose = FALSE)
        
        # Generate error message
        error_message <- paste("Organism '", orgm, "' does not support '", operation, "' operation")
        if (nchar(error_context) > 0) {
            error_message <- paste(error_message, ":", error_context)
        }
        
        # Get suggestions
        suggestions <- character(0)
        if (operation == "plotting") {
            alternatives <- suggestOrganismAlternatives(orgm, "plotting", verbose = FALSE)
            if (length(alternatives) > 0) {
                suggestions <- c(suggestions, paste("Consider using these organisms for plotting:", paste(alternatives[1:min(3, length(alternatives))], collapse = ", ")))
            }
            suggestions <- c(suggestions, "Use validateOrganismSupport() to check organism capabilities before plotting")
        } else if (operation == "synteny_analysis") {
            if (capabilities$ortholog_search) {
                suggestions <- c(suggestions, "This organism supports ortholog search but not synteny analysis")
                suggestions <- c(suggestions, "Consider using ortholog search results for basic analysis")
            }
        }
        
        # Add general suggestions
        suggestions <- c(suggestions, "Use getSupportedOperations() to see what operations are supported for this organism")
        suggestions <- c(suggestions, "Use checkPlottingCompatibility() to validate organism lists before plotting")
        
        result <- list(
            error_type = "organism_unsupported",
            organism = orgm,
            operation = operation,
            error_message = error_message,
            capabilities = capabilities,
            suggestions = suggestions,
            context = error_context
        )
        
        if (verbose) {
            message("Error handled: ", error_message)
            if (length(suggestions) > 0) {
                message("Suggestions:")
                for (suggestion in suggestions) {
                    message("  - ", suggestion)
                }
            }
        }
        
        return(result)
        
    }, error = function(e) {
        stop("Error in handleOrganismError: ", e$message)
    })
}

#' Validate complete operation chain before execution
#'
#' @description This function validates an entire operation chain to identify potential
#' issues before execution begins.
#'
#' @param operations A list of operations to validate
#' @param parameters A list of parameters for the operations
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing validation results and recommendations
#'
#' @examples
#' \dontrun{
#'   # Validate workflow before execution
#'   validation <- validateOperationChain(
#'     list("ortholog_search", "coordinate_retrieval", "plotting"),
#'     list(orgms = c("Hsapiens", "Mmusculus"), coords = "2:16e7:16.5e7")
#'   )
#' }
#'
#' @export
validateOperationChain <- function(operations, parameters, verbose = FALSE) {
    
    # Input validation
    if (missing(operations) || missing(parameters)) {
        stop("Both 'operations' and 'parameters' parameters are required")
    }
    
    if (!is.list(operations) || length(operations) == 0) {
        stop("'operations' must be a non-empty list")
    }
    
    if (!is.list(parameters)) {
        stop("'parameters' must be a list")
    }
    
    if (verbose) {
        message("Validating operation chain with ", length(operations), " operations")
    }
    
    tryCatch({
        issues <- character(0)
        warnings <- character(0)
        recommendations <- character(0)
        
        # Check organism support for each operation
        if ("orgms" %in% names(parameters)) {
            orgms <- parameters$orgms
            if (is.character(orgms) && length(orgms) > 0) {
                for (operation in operations) {
                    if (operation %in% c("plotting", "synteny_analysis")) {
                        compatibility <- checkPlottingCompatibility(orgms, verbose = FALSE)
                        if (!compatibility$all_compatible) {
                            issues <- c(issues, paste("Some organisms do not support", operation))
                            warnings <- c(warnings, paste("Incompatible organisms:", paste(compatibility$incompatible_organisms, collapse = ", ")))
                        }
                    }
                }
            }
        }
        
        # Check coordinate format compatibility
        if ("coords" %in% names(parameters)) {
            coords <- parameters$coords
            if (is.character(coords) && length(coords) > 0) {
                for (coord in coords) {
                    # Basic coordinate format validation
                    if (!grepl("^\\d+:\\d+[eE]?\\d*:\\d+[eE]?\\d*$", coord)) {
                        issues <- c(issues, paste("Invalid coordinate format:", coord))
                        recommendations <- c(recommendations, "Use format 'chromosome:start:end' (e.g., '2:16e7:16.5e7')")
                    }
                }
            }
        }
        
        # Check for required parameters
        required_params <- list(
            "ortholog_search" = c("orgms"),
            "coordinate_retrieval" = c("orgms", "coords"),
            "plotting" = c("orgms"),
            "synteny_analysis" = c("orgms")
        )
        
        for (operation in operations) {
            if (operation %in% names(required_params)) {
                required <- required_params[[operation]]
                missing <- setdiff(required, names(parameters))
                if (length(missing) > 0) {
                    issues <- c(issues, paste("Missing required parameters for", operation, ":", paste(missing, collapse = ", ")))
                }
            }
        }
        
        # Generate recommendations
        if (length(issues) == 0) {
            recommendations <- c(recommendations, "Operation chain appears valid - proceed with execution")
        } else {
            recommendations <- c(recommendations, "Address the issues above before executing the operation chain")
            recommendations <- c(recommendations, "Use validateOrganismSupport() to check individual organism capabilities")
        }
        
        result <- list(
            valid = length(issues) == 0,
            issues = issues,
            warnings = warnings,
            recommendations = recommendations,
            operations = operations,
            parameters = parameters
        )
        
        if (verbose) {
            if (result$valid) {
                message("Operation chain validation passed")
            } else {
                message("Operation chain validation failed with ", length(issues), " issues")
                for (issue in issues) {
                    message("  - ", issue)
                }
            }
        }
        
        return(result)
        
    }, error = function(e) {
        stop("Error in validateOperationChain: ", e$message)
    })
}

#' Provide specific guidance for different error types
#'
#' @description This function provides specific guidance and solutions for different types of errors.
#'
#' @param error_type A character string specifying the type of error
#' @param context A list containing additional context about the error
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing guidance and solutions
#'
#' @examples
#' \dontrun{
#'   # Get guidance for coordinate format error
#'   guidance <- provideErrorGuidance("coordinate_format", list(coords = "invalid"))
#' }
#'
#' @export
provideErrorGuidance <- function(error_type, context = list(), verbose = FALSE) {
    
    # Input validation
    if (missing(error_type)) {
        stop("'error_type' parameter is required")
    }
    
    if (!is.character(error_type) || length(error_type) != 1) {
        stop("'error_type' must be a single character string")
    }
    
    if (verbose) {
        message("Providing guidance for error type: ", error_type)
    }
    
    tryCatch({
        guidance <- list(
            error_type = error_type,
            solutions = character(0),
            prevention_tips = character(0),
            related_functions = character(0)
        )
        
        if (error_type == "organism_unsupported") {
            guidance$solutions <- c(
                "Use validateOrganismSupport() to check organism capabilities before operations",
                "Use suggestOrganismAlternatives() to find compatible organisms",
                "Use checkPlottingCompatibility() to validate organism lists",
                "Consider using organisms with 'Full' support level for complete functionality"
            )
            guidance$prevention_tips <- c(
                "Always validate organism support before starting analysis",
                "Use getSupportedOperations() to see available operations for each organism",
                "Check the organism support reference documentation"
            )
            guidance$related_functions <- c("validateOrganismSupport", "suggestOrganismAlternatives", "checkPlottingCompatibility")
            
        } else if (error_type == "coordinate_format") {
            guidance$solutions <- c(
                "Use coordFormat() to convert coordinate strings to GRanges objects",
                "Ensure coordinates follow the format 'chromosome:start:end'",
                "Use validateCoordinateFormat() to check coordinate compatibility",
                "Use standardizeCoordinates() to ensure proper format for target functions"
            )
            guidance$prevention_tips <- c(
                "Always use coordFormat() for coordinate string conversion",
                "Validate coordinate format before passing to plotting functions",
                "Use the comprehensive user example as a reference"
            )
            guidance$related_functions <- c("coordFormat", "validateCoordinateFormat", "standardizeCoordinates")
            
        } else if (error_type == "database_missing") {
            guidance$solutions <- c(
                "Install required database packages using BiocManager::install()",
                "Use checkDatabaseAvailability() to verify database installation",
                "Check the organism support reference for required databases",
                "Use getOrganismCapabilities() to see database requirements"
            )
            guidance$prevention_tips <- c(
                "Install all required databases before starting analysis",
                "Use checkDatabaseAvailability() to verify installation status",
                "Follow the installation guide in the documentation"
            )
            guidance$related_functions <- c("checkDatabaseAvailability", "getOrganismCapabilities")
            
        } else if (error_type == "genome_assembly") {
            guidance$solutions <- c(
                "Use getGenomeAssembly() to get the correct assembly for your species",
                "Check the organism support reference for assembly information",
                "Ensure genome assembly metadata is properly set in GRanges objects",
                "Use standardizeCoordinates() to add proper assembly information"
            )
            guidance$prevention_tips <- c(
                "Always specify genome assembly when creating GRanges objects",
                "Use the correct assembly version for your analysis",
                "Check assembly compatibility with your data sources"
            )
            guidance$related_functions <- c("getGenomeAssembly", "standardizeCoordinates")
            
        } else {
            # Generic error guidance
            guidance$solutions <- c(
                "Check function documentation for proper usage",
                "Use verbose = TRUE for detailed error information",
                "Check the comprehensive user example for proper workflow",
                "Use validateOperationChain() to check workflow compatibility"
            )
            guidance$prevention_tips <- c(
                "Always validate inputs before function calls",
                "Use the provided validation functions",
                "Follow the documented workflow examples"
            )
            guidance$related_functions <- c("validateOperationChain", "validateOrganismSupport")
        }
        
        if (verbose) {
            message("Guidance provided for ", error_type, ":")
            message("  Solutions: ", length(guidance$solutions))
            message("  Prevention tips: ", length(guidance$prevention_tips))
            message("  Related functions: ", length(guidance$related_functions))
        }
        
        return(guidance)
        
    }, error = function(e) {
        stop("Error in provideErrorGuidance: ", e$message)
    })
}

#' Log error context for debugging
#'
#' @description This function logs detailed error context for debugging purposes.
#'
#' @param error An error object or error message
#' @param function_name A character string specifying the function where the error occurred
#' @param parameters A list of parameters passed to the function
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing error context information
#'
#' @examples
#' \dontrun{
#'   # Log error context
#'   error_context <- logErrorContext(e, "getOrthologCoordinates", list(orgm = "Hsapiens"))
#' }
#'
#' @export
logErrorContext <- function(error, function_name, parameters = list(), verbose = FALSE) {
    
    # Input validation
    if (missing(error) || missing(function_name)) {
        stop("Both 'error' and 'function_name' parameters are required")
    }
    
    if (!is.character(function_name) || length(function_name) != 1) {
        stop("'function_name' must be a single character string")
    }
    
    if (verbose) {
        message("Logging error context for function: ", function_name)
    }
    
    tryCatch({
        # Extract error message
        error_message <- if (inherits(error, "error")) {
            error$message
        } else if (is.character(error)) {
            error
        } else {
            as.character(error)
        }
        
        # Create error context
        context <- list(
            timestamp = Sys.time(),
            function_name = function_name,
            error_message = error_message,
            parameters = parameters,
            session_info = list(
                r_version = R.version.string,
                platform = R.version$platform,
                package_version = packageVersion("SyntenyViz")
            )
        )
        
        # Add system information
        context$system_info <- list(
            memory_usage = if (requireNamespace("pryr", quietly = TRUE)) {
                tryCatch(pryr::mem_used(), error = function(e) "Unknown")
            } else {
                "pryr not available"
            },
            working_directory = getwd(),
            loaded_packages = loadedNamespaces()
        )
        
        if (verbose) {
            message("Error context logged:")
            message("  Function: ", function_name)
            message("  Error: ", error_message)
            message("  Parameters: ", length(parameters))
            message("  Timestamp: ", context$timestamp)
        }
        
        return(context)
        
    }, error = function(e) {
        stop("Error in logErrorContext: ", e$message)
    })
}

#' Create comprehensive error report
#'
#' @description This function creates a comprehensive error report with context and suggestions.
#'
#' @param error An error object or error message
#' @param function_name A character string specifying the function where the error occurred
#' @param parameters A list of parameters passed to the function
#' @param verbose A logical value indicating whether to print additional information. Defaults to FALSE.
#'
#' @return A list containing comprehensive error report
#'
#' @examples
#' \dontrun{
#'   # Create comprehensive error report
#'   report <- createErrorReport(e, "multisynvizPlots", list(orgms = c("Hsapiens", "Athaliana")))
#' }
#'
#' @export
createErrorReport <- function(error, function_name, parameters = list(), verbose = FALSE) {
    
    # Input validation
    if (missing(error) || missing(function_name)) {
        stop("Both 'error' and 'function_name' parameters are required")
    }
    
    if (verbose) {
        message("Creating comprehensive error report for function: ", function_name)
    }
    
    tryCatch({
        # Log error context
        context <- logErrorContext(error, function_name, parameters, verbose = FALSE)
        
        # Determine error type
        error_message <- context$error_message
        error_type <- "unknown"
        
        if (grepl("organism.*not.*support", error_message, ignore.case = TRUE)) {
            error_type <- "organism_unsupported"
        } else if (grepl("coordinate.*format", error_message, ignore.case = TRUE)) {
            error_type <- "coordinate_format"
        } else if (grepl("database.*not.*found", error_message, ignore.case = TRUE)) {
            error_type <- "database_missing"
        } else if (grepl("genome.*assembly", error_message, ignore.case = TRUE)) {
            error_type <- "genome_assembly"
        }
        
        # Get guidance
        guidance <- provideErrorGuidance(error_type, context, verbose = FALSE)
        
        # Create comprehensive report
        report <- list(
            error_context = context,
            error_type = error_type,
            guidance = guidance,
            quick_fixes = character(0),
            next_steps = character(0)
        )
        
        # Add quick fixes based on error type
        if (error_type == "organism_unsupported") {
            report$quick_fixes <- c(
                "Use validateOrganismSupport() to check capabilities",
                "Try alternative organisms with validateOrganismSupport()",
                "Use checkPlottingCompatibility() for organism lists"
            )
        } else if (error_type == "coordinate_format") {
            report$quick_fixes <- c(
                "Use coordFormat() to convert coordinates",
                "Check coordinate format with validateCoordinateFormat()",
                "Use standardizeCoordinates() for proper formatting"
            )
        } else {
            report$quick_fixes <- c(
                "Check function documentation",
                "Use verbose = TRUE for detailed information",
                "Validate inputs before function calls"
            )
        }
        
        # Add next steps
        report$next_steps <- c(
            "Review the error context and guidance above",
            "Try the suggested quick fixes",
            "Use the related functions for validation",
            "Check the comprehensive user example for proper usage"
        )
        
        if (verbose) {
            message("Comprehensive error report created:")
            message("  Error type: ", error_type)
            message("  Quick fixes: ", length(report$quick_fixes))
            message("  Next steps: ", length(report$next_steps))
        }
        
        return(report)
        
    }, error = function(e) {
        stop("Error in createErrorReport: ", e$message)
    })
}
