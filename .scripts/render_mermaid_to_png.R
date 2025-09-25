#!/usr/bin/env Rscript
# Render Mermaid Flowchart to PNG
# This script converts the Mermaid flowchart to a PNG image

# Load required libraries
if (!requireNamespace("mermaid", quietly = TRUE)) {
  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
  }
  remotes::install_github("mikey-harper/mermaid")
}

if (!requireNamespace("DiagrammeR", quietly = TRUE)) {
  install.packages("DiagrammeR")
}

library(DiagrammeR)
library(magrittr)

# Read the Mermaid content from the markdown file
mermaid_content <- readLines("SYNTENYVIZ_WORKFLOW_FLOWCHART.md")

# Extract the Mermaid code block
start_line <- which(grepl("```mermaid", mermaid_content))
end_line <- which(grepl("```", mermaid_content))[2]  # Second occurrence

if (length(start_line) > 0 && length(end_line) > 0) {
  mermaid_code <- paste(mermaid_content[(start_line + 1):(end_line - 1)], collapse = "\n")
  
  cat("Mermaid code extracted successfully\n")
  cat("Code length:", nchar(mermaid_code), "characters\n")
  cat("Updated flowchart with proper flowchart shapes and connections\n")
  
  # Create the diagram using DiagrammeR
  diagram <- mermaid(mermaid_code)
  
  # Export to PNG
  export_graph(
    graph = diagram,
    file_name = "SyntenyViz_Workflow_Flowchart.png",
    file_type = "PNG",
    width = 2000,
    height = 3000
  )
  
  cat("PNG file created: SyntenyViz_Workflow_Flowchart.png\n")
  
} else {
  cat("Error: Could not find Mermaid code block in the markdown file\n")
}
