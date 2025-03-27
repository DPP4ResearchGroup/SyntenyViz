if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}

if (!requireNamespace("Gviz", quietly = TRUE)) {
    BiocManager::install("Gviz")
}

if (!requireNamespace("GenomicRanges", quietly = TRUE)) {
    BiocManager::install("GenomicRanges")
}
