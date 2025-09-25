# Working Examples and Vignettes

`SyntenyViz` includes comprehensive examples and training materials demonstrating all package capabilities, including the new ortholog coordinate retrieval and synteny block visualization features.

## Available Examples

### Comprehensive User Example
- **File**: `examples/comprehensive_user_example.R`
- **Features**: Complete workflow including ortholog analysis, coordinate retrieval, and synteny block visualization
- **New Sections**: 
  - Ortholog coordinate retrieval (Step 5.5)
  - Synteny block visualization (Step 5.6)

### Vignettes
Access via `RStudio`:
```
install_github("DPP4ResearchGroup/SyntenyViz", build_vignettes = TRUE)
browseVignettes("SyntenyViz")
```

### Online Documentation
A `PDF` can be accessed from `SyntenyViz` [homepage](https://dpp4researchgroup.github.io/SyntenyViz/).

## New Features Demonstrated

- **Ortholog Coordinate Retrieval**: `getOrthologCoordinates()` function usage
- **Synteny Block Data Creation**: `createSyntenyBlockData()` workflow
- **Enhanced Visualization**: `plotSyntenyBlocks()` with comparative and overlay plot types
- **Conservation Metrics**: `getOrthologSyntenySummary()` for quantitative analysis