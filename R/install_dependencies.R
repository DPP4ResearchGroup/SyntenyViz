#' Install required dependencies for SyntenyViz
#'
#' This function installs the required Bioconductor and CRAN packages
#' needed for SyntenyViz to work properly.
#'
#' @param packages Character vector of package names to install. If NULL,
#'   installs the default required packages.
#' @param update Logical. Should BiocManager::install update all packages?
#' @return Invisibly returns TRUE if all packages were installed successfully.
#' @export
#' @examples
#' \dontrun{
#' install_dependencies()
#' install_dependencies(c("Gviz", "GenomicRanges"))
#' }
install_dependencies <- function(packages = NULL, update = FALSE) {
    # Install BiocManager if not available
    if (!requireNamespace("BiocManager", quietly = TRUE)) {
        install.packages("BiocManager")
    }
    
    # Default required packages
    if (is.null(packages)) {
        packages <- c("Gviz", "GenomicRanges", "orthogene")
    }
    
    # Install packages
    BiocManager::install(packages, update = update, ask = FALSE)
    
    # Check if all packages are now available
    missing_packages <- packages[!sapply(packages, requireNamespace, quietly = TRUE)]
    
    if (length(missing_packages) > 0) {
        warning("The following packages could not be installed: ", 
                paste(missing_packages, collapse = ", "))
        return(FALSE)
    }
    
    message("All required packages installed successfully!")
    return(TRUE)
}