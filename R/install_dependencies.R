#' Install required dependencies for SyntenyViz
#'
#' @name install_dependencies
#' @importFrom BiocManager install
#' @export
#'
if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}

if (!requireNamespace("Gviz", quietly = TRUE)) {
    BiocManager::install("Gviz")
}

if (!requireNamespace("GenomicRanges", quietly = TRUE)) {
    BiocManager::install("GenomicRanges")
}

if (!requireNamespace("orthogene", quietly = TRUE)) {
    BiocManager::install("orthogene")
}