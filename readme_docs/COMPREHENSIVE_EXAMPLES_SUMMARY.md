# SyntenyViz Comprehensive Examples Summary

This document summarizes the comprehensive examples and vignettes created for the SyntenyViz package.

## Files Created

### 1. Comprehensive User Example
**File**: `examples/comprehensive_user_example.R`

A complete R script that demonstrates all major functions and capabilities of the SyntenyViz package. This script includes:

- **Basic Setup**: Coordinate formatting and GRanges conversion
- **Gene Annotation**: Gene subset extraction and annotation
- **Visualization**: Single and multi-species synteny plots
- **Ortholog Analysis**: Ortholog search and similarity calculations
- **Ortholog Coordinates**: Coordinate retrieval and mapping for orthologs
- **Synteny Block Visualization**: Enhanced synteny block plots with ortholog connections
- **Synteny Analysis**: Synteny similarity calculations between species
- **Evolutionary Analysis**: Evolutionary and patristic distance analysis
- **Phylogenetic Operations**: Tree-based distance calculations
- **Database Management**: Organism and package management
- **Error Handling**: Comprehensive error handling examples
- **Debugging**: Debug mode demonstrations

### 2. Comprehensive Workflow Vignette
**File**: `vignettes/SyntenyViz_comprehensive_workflow.Rmd`

A detailed R Markdown vignette that provides a step-by-step guide through the complete SyntenyViz workflow. This vignette includes:

- **Introduction**: Package overview and learning objectives
- **Getting Started**: Installation and setup instructions
- **Basic Workflow**: Single species analysis
- **Multi-Species Analysis**: Comparative synteny visualization
- **Ortholog Analysis**: Gene orthology and similarity calculations
- **Synteny Similarity**: Quantitative synteny conservation analysis
- **Evolutionary Analysis**: Distance-based evolutionary analysis
- **Advanced Features**: Phylogenetic tree operations
- **Best Practices**: Error handling and performance tips
- **Conclusion**: Summary and next steps

## Key Features Demonstrated

### Core Functionality
1. **Coordinate Management**
   - `coordFormat()`: Convert coordinate strings to GRanges objects
   - Coordinate validation and error handling

2. **Gene Analysis**
   - `geneSubset()`: Extract genes from genomic regions
   - Gene annotation and metadata extraction

3. **Visualization**
   - `synvizPlot()`: Single species synteny plots
   - `multisynvizPlots()`: Multi-species comparative plots
   - `synvizPlotData()`: Data preparation for plotting

4. **Ortholog Analysis**
   - `getOrthHomolog()`: Search for orthologous genes
   - `getOrthologCoordinates()`: Retrieve genomic coordinates for orthologs
   - `calculateOrthologSimilarity()`: Calculate various similarity metrics
   - Multiple similarity types: sequence, functional, evolutionary, composite

5. **Synteny Block Visualization**
   - `createSyntenyBlockData()`: Create synteny block data structures
   - `plotSyntenyBlocks()`: Visualize synteny blocks with ortholog connections
   - `getOrthologSyntenySummary()`: Generate synteny conservation metrics
   - Support for comparative and overlay plot types

6. **Synteny Analysis**
   - `calculateSyntenySimilarity()`: Quantify synteny conservation
   - Overlap and order score calculations
   - Ortholog pair identification

7. **Evolutionary Analysis**
   - `loadEvolutionaryDistances()`: Load evolutionary distance data
   - `getEvolutionaryDistances()`: Query evolutionary distances
   - `loadPatristicDistances()`: Load patristic distance data
   - `getPatristicDistances()`: Query patristic distances

8. **Phylogenetic Operations**
   - `calculatePatristicDistance()`: Calculate distances from trees
   - `patristicToDivergenceTime()`: Convert distances to time
   - `divergenceTimeToPatristic()`: Convert time to distances
   - `validatePatristicDistances()`: Validate against trees

9. **Database Management**
   - `getPkgs()`: Get organism-specific packages
   - `orgmsCollection.init()`: Initialize organism collections
   - `orgmsAdd()`: Add organisms to collections

## Example Workflow

The examples follow a logical progression:

1. **Setup**: Define genomic coordinates and convert to GRanges
2. **Gene Extraction**: Extract and annotate genes from regions
3. **Visualization**: Create synteny plots for single and multiple species
4. **Ortholog Search**: Find orthologous genes across species
5. **Ortholog Coordinates**: Retrieve genomic coordinates for orthologs
6. **Synteny Block Visualization**: Create enhanced synteny plots with ortholog connections
7. **Similarity Analysis**: Calculate various similarity metrics
8. **Synteny Quantification**: Measure synteny conservation
9. **Evolutionary Analysis**: Work with evolutionary distances
10. **Advanced Features**: Integrate phylogenetic information

## Data Sources

The examples use:
- **DPP4 Gene**: Dipeptidyl peptidase 4 gene as a case study
- **Multiple Species**: Human, mouse, and rat comparisons
- **Genomic Coordinates**: Real genomic coordinates for DPP4 regions
- **Evolutionary Data**: Pre-loaded evolutionary and patristic distances

## Error Handling

Both examples include comprehensive error handling:
- Input validation
- Graceful error recovery
- Debug mode demonstrations
- Edge case handling

## Performance Considerations

The examples demonstrate:
- Efficient coordinate handling
- Optimized gene extraction
- Caching strategies
- Memory management tips

## Usage Instructions

### Running the User Example
```r
# Source the comprehensive example
source("examples/comprehensive_user_example.R")
```

### Building the Vignette
```r
# Build the vignette
devtools::build_vignettes()

# View the vignette
browseVignettes("SyntenyViz")
```

## Dependencies

The examples require:
- **SyntenyViz**: Main package
- **dplyr**: Data manipulation
- **grid**: Plotting utilities
- **BiocManager**: Bioconductor package management
- **GenomicRanges**: Genomic range operations
- **Gviz**: Genomic visualization
- **orthogene**: Ortholog mapping
- **stringr**: String manipulation
- **yaml**: YAML file handling
- **rlist**: List operations

## Target Audience

These examples are designed for:
- **Beginners**: New users learning SyntenyViz
- **Intermediate Users**: Users wanting to explore advanced features
- **Researchers**: Scientists conducting comparative genomics studies
- **Developers**: Contributors to the SyntenyViz package

## Educational Value

The examples provide:
- **Step-by-step guidance**: Clear progression through workflows
- **Real-world examples**: Practical use cases with real data
- **Best practices**: Recommended approaches and techniques
- **Troubleshooting**: Common issues and solutions
- **Performance tips**: Optimization strategies

## Future Enhancements

Potential improvements:
- Interactive examples using Shiny
- Additional species combinations
- More complex genomic regions
- Integration with external databases
- Automated testing examples

## Conclusion

These comprehensive examples provide a complete guide to using SyntenyViz for synteny analysis and comparative genomics. They demonstrate all major package features while providing practical, real-world examples that users can adapt for their own research needs.

The examples serve as both educational materials and reference implementations, helping users understand not just what SyntenyViz can do, but how to use it effectively in their own research workflows.

