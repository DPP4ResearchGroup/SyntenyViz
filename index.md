---
layout: default
title: SyntenyViz - Synteny Visualization R Package
description: A comprehensive R package for synteny visualization and comparative genomics analysis
keywords: synteny, visualization, R package, genomics, comparative genomics, bioinformatics
author: DPP4ResearchGroup
date: 2024-01-01
last_modified_at: 2024-01-01
absorb: true
---

# Welcome to SyntenyViz

<div class="synviz-showcase">
  <img src="{{ '/assets/images/SynViz.png' | relative_url }}" alt="SyntenyViz Visualization Example" class="synviz-main-image">
</div>

SyntenyViz is a powerful R package designed for synteny visualization and comparative genomics analysis. It provides researchers with intuitive tools to visualize and analyze genomic synteny relationships across different species, as demonstrated in the visualization above.

## Quick Navigation

### 📚 Documentation
- **[Getting Started](readme_docs/header.md)** - Overview and introduction
  - [Summary](readme_docs/Intro.md) - Package summary and features
  - [Release Status](readme_docs/Releases.md) - Current version and updates
- **[About SyntenyViz](/about/)** - Learn more about the project

### 🛠️ User Guides
- **[Installation & Quick Start](readme_docs/Ops.md)** - Setup and basic usage
- **[Orthologs Matching](readme_docs/Orthologs.md)** - Working with orthologous genes
- **[More Examples](readme_docs/Examples.md)** - Advanced usage examples

### 🔧 Troubleshooting
- **[Debugging Guide](readme_docs/DEBUGGING_GUIDE.md)** - Common debugging techniques
- **[Common Issues](readme_docs/CommonIssues.md)** - Frequently encountered problems

### 🚧 Development
- **[CI/Unit Testing](readme_docs/UnitTests.md)** - Testing framework and practices
- **[Issue Tracking](readme_docs/Issues.md)** - Bug reports and feature requests
- **[Contributing](readme_docs/Contrib.md)** - How to contribute to the project

## Features

- **Interactive Visualizations**: Create dynamic synteny plots with customizable parameters
- **Multiple Format Support**: Import data from various genomic file formats
- **Comparative Analysis**: Compare synteny across multiple species
- **Publication Ready**: Generate high-quality figures for scientific publications
- **R Integration**: Seamless integration with the R ecosystem and Bioconductor

## Installation

```r
# Install from GitHub
devtools::install_github("DPP4ResearchGroup/SyntenyViz")

# Or install from CRAN (when available)
install.packages("SyntenyViz")
```

## Quick Example

```r
library(SyntenyViz)

# Load your genomic data
data <- load_synteny_data("your_data.csv")

# Create a synteny plot
plot_synteny(data, species1 = "Human", species2 = "Mouse")
```

## Citation

If you use SyntenyViz in your research, please cite:

```bibtex
@software{syntenyviz2024,
  title={SyntenyViz: An R Package for Synteny Visualization},
  author={DPP4ResearchGroup},
  year={2024},
  url={https://github.com/DPP4ResearchGroup/SyntenyViz}
}
```
