# SyntenyViz Simplified Function Logic Flow

## Core Function Logic and Data Flow

This simplified flowchart shows the essential logic flow between SyntenyViz functions, focusing on the main data processing pipeline.

```mermaid
flowchart TD
    %% Input Processing
    START([Start]) --> COORDS[Coordinate Strings]
    COORDS --> COORD_FORMAT[coordFormat]
    COORD_FORMAT --> GRANGES[GRanges Object]
    
    %% Gene Annotation
    GRANGES --> GENE_SUBSET[geneSubset]
    GENE_SUBSET --> GET_PKGS[getPkgs]
    GET_PKGS --> GET_ORG_DB[getOrgDB]
    GET_ORG_DB --> GET_TX_DB[getTxDB]
    GET_TX_DB --> ANNOTATED_GENES[Annotated Genes]
    
    %% Visualization
    ANNOTATED_GENES --> SYNVIZ_PLOT_DATA[synvizPlotData]
    SYNVIZ_PLOT_DATA --> SYNVIZ_PLOT[synvizPlot]
    SYNVIZ_PLOT --> SINGLE_PLOT[Single Species Plot]
    
    %% Multi-Species Analysis
    SINGLE_PLOT --> ORGMS_INIT[orgmsCollection.init]
    ORGMS_INIT --> ORGMS_ADD[orgmsAdd]
    ORGMS_ADD --> MULTISYNVIZ[multisynvizPlots]
    MULTISYNVIZ --> MULTI_PLOT[Multi-Species Plot]
    
    %% Ortholog Analysis
    MULTI_PLOT --> GET_ORTH[getOrthHomolog]
    GET_ORTH --> ORTHOLOGS[Ortholog Pairs]
    
    %% Similarity Calculations
    ORTHOLOGS --> SEQ_SIM[calculateSequenceSimilarity]
    ORTHOLOGS --> FUNC_SIM[calculateFunctionalSimilarity]
    ORTHOLOGS --> EVO_SIM[calculateEvolutionarySimilarity]
    
    SEQ_SIM --> COMP_SIM[calculateCompositeSimilarity]
    FUNC_SIM --> COMP_SIM
    EVO_SIM --> COMP_SIM
    COMP_SIM --> COMPOSITE_SCORE[Composite Similarity]
    
    %% Synteny Analysis
    COMPOSITE_SCORE --> SYNTENY_SIM[calculateSyntenySimilarity]
    SYNTENY_SIM --> SYNTENY_SCORE[Synteny Similarity]
    
    %% Patristic Distance Analysis
    SYNTENY_SCORE --> LOAD_PAT[loadPatristicDistances]
    LOAD_PAT --> GET_PAT[getPatristicDistances]
    GET_PAT --> PAT_TO_DIV[patristicToDivergenceTime]
    PAT_TO_DIV --> DIV_TO_PAT[divergenceTimeToPatristic]
    
    %% Validation and Summary
    DIV_TO_PAT --> VALIDATE[validatePatristicDistances]
    VALIDATE --> GET_CONF[getDistanceConfidence]
    GET_CONF --> GET_SUMMARY[getPatristicDistanceSummary]
    GET_SUMMARY --> FINAL_RESULTS[Final Analysis Results]
    
    FINAL_RESULTS --> END([End])
    
    %% Styling
    classDef inputBox fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef processBox fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef outputBox fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef startEndBox fill:#ffebee,stroke:#d32f2f,stroke-width:3px
    
    class COORDS,GRANGES,ANNOTATED_GENES,ORTHOLOGS,COMPOSITE_SCORE,SYNTENY_SCORE,FINAL_RESULTS inputBox
    class COORD_FORMAT,GENE_SUBSET,GET_PKGS,GET_ORG_DB,GET_TX_DB,SYNVIZ_PLOT_DATA,SYNVIZ_PLOT,ORGMS_INIT,ORGMS_ADD,MULTISYNVIZ,GET_ORTH,SEQ_SIM,FUNC_SIM,EVO_SIM,COMP_SIM,SYNTENY_SIM,LOAD_PAT,GET_PAT,PAT_TO_DIV,DIV_TO_PAT,VALIDATE,GET_CONF,GET_SUMMARY processBox
    class SINGLE_PLOT,MULTI_PLOT outputBox
    class START,END startEndBox
```

## Function Logic Summary

### **1. Data Input and Processing**
- **coordFormat**: Converts coordinate strings to GRanges objects
- **geneSubset**: Annotates genes using organism-specific databases
- **getPkgs, getOrgDB, getTxDB**: Manage database access and package dependencies

### **2. Visualization Pipeline**
- **synvizPlotData**: Prepares data for visualization
- **synvizPlot**: Creates single-species synteny plots
- **orgmsCollection.init, orgmsAdd**: Manages multi-species collections
- **multisynvizPlots**: Generates comparative multi-species plots

### **3. Ortholog Analysis**
- **getOrthHomolog**: Identifies orthologous gene pairs across species

### **4. Multi-dimensional Similarity Analysis**
- **calculateSequenceSimilarity**: Sequence-based similarity (40% weight)
- **calculateFunctionalSimilarity**: Functional similarity based on GO terms (35% weight)
- **calculateEvolutionarySimilarity**: Evolutionary distance-based similarity (25% weight)
- **calculateCompositeSimilarity**: Combines all similarity metrics with weights

### **5. Synteny Conservation Analysis**
- **calculateSyntenySimilarity**: Quantifies gene order conservation between species

### **6. Evolutionary Distance Analysis**
- **loadPatristicDistances**: Loads patristic distance database
- **getPatristicDistances**: Retrieves specific species pair distances
- **patristicToDivergenceTime**: Converts distances to divergence times
- **divergenceTimeToPatristic**: Converts times back to distances

### **7. Quality Control and Validation**
- **validatePatristicDistances**: Validates distance data integrity
- **getDistanceConfidence**: Assigns confidence levels to distances
- **getPatristicDistanceSummary**: Generates comprehensive summary statistics

## Key Logic Principles

### **Data Flow Dependencies**
1. **Coordinate Input** → **GRanges Creation** → **Gene Annotation**
2. **Gene Data** → **Visualization** → **Multi-Species Analysis**
3. **Ortholog Data** → **Similarity Calculations** → **Synteny Analysis**
4. **Distance Data** → **Validation** → **Summary Statistics**

### **Function Integration**
- Each function builds upon previous outputs
- Clear input/output specifications
- Modular design allows independent function calls
- Comprehensive error handling throughout

### **Scientific Rigor**
- Multiple validation approaches
- Confidence level assignments
- Uncertainty quantification
- Cross-validation with phylogenetic data

This simplified flowchart provides a clear overview of how data flows through the SyntenyViz package, from initial coordinate input to final comprehensive analysis results.
