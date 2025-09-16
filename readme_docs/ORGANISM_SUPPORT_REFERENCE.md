# SyntenyViz Organism Support Reference

## Overview

This document provides a comprehensive reference for organism support in SyntenyViz, including detailed capability matrices, database dependencies, and genome assembly information.

## Support Level Definitions

- **Full**: Complete support for ortholog search, plotting, and synteny analysis
- **Partial**: Support for ortholog search and plotting, but limited synteny analysis capabilities
- **Ortholog Only**: Support for ortholog search only, no plotting or synteny analysis
- **Experimental**: Limited or untested functionality, may have compatibility issues

## Complete Organism Capability Matrix

| Scientific Name | Common Name | Abbreviation | Taxonomy ID | Ortholog Search | Plotting | Synteny Analysis | Database Support | Genome Assembly | Support Level |
|----------------|-------------|--------------|-------------|----------------|----------|------------------|------------------|-----------------|---------------|
| **Mammals** |
| Homo sapiens | Human | Hsapiens | 9606 | ✅ | ✅ | ✅ | org.Hs.eg.db, TxDb.Hsapiens.UCSC.hg38.knownGene | hg38 | Full |
| Mus musculus | House mouse | Mmusculus | 10090 | ✅ | ✅ | ✅ | org.Mm.eg.db, TxDb.Mmusculus.UCSC.mm10.knownGene | mm10 | Full |
| Rattus norvegicus | Brown rat | Rnorvegicus | 10116 | ✅ | ✅ | ✅ | org.Rn.eg.db, TxDb.Rnorvegicus.UCSC.rn6.refGene | rn6 | Full |
| Macaca mulatta | Rhesus macaque | Mmulatta | 9544 | ✅ | ✅ | ✅ | org.Mmu.eg.db, TxDb.Mmulatta.UCSC.rheMac10.refGene | rheMac10 | Full |
| Pan troglodytes | Chimpanzee | Ptroglodytes | 9598 | ✅ | ✅ | ✅ | org.Pt.eg.db, TxDb.Ptroglodytes.UCSC.panTro6.refGene | panTro6 | Full |
| Canis lupus familiaris | Dog | Cfamiliaris | 9615 | ✅ | ✅ | ✅ | org.Cf.eg.db, TxDb.Cfamiliaris.UCSC.canFam3.refGene | canFam3 | Full |
| Bos taurus | Cow | Btaurus | 9913 | ✅ | ✅ | ✅ | org.Bt.eg.db, TxDb.Btaurus.UCSC.bosTau9.refGene | bosTau9 | Full |
| Sus scrofa | Wild swine | Sscrofa | 9823 | ✅ | ✅ | ✅ | org.Ss.eg.db, TxDb.Sscrofa.UCSC.susScr11.refGene | susScr11 | Full |
| **Birds** |
| Gallus gallus | Chicken | Ggallus | 9031 | ✅ | ✅ | ✅ | org.Gg.eg.db, TxDb.Ggallus.UCSC.galGal6.refGene | galGal6 | Full |
| **Fish** |
| Danio rerio | Zebrafish | Drerio | 7955 | ✅ | ✅ | ✅ | org.Dr.eg.db, TxDb.Drerio.UCSC.danRer11.refGene | danRer11 | Full |
| **Insects** |
| Drosophila melanogaster | Fruit fly | Dmelanogaster | 7227 | ✅ | ✅ | ✅ | org.Dm.eg.db, TxDb.Dmelanogaster.UCSC.dm6.ensGene | dm6 | Full |
| Anopheles gambiae | Mosquito | Agambiae | 7165 | ✅ | ❌ | ⚠️ | org.Ag.eg.db | N/A | Ortholog Only |
| **Nematodes** |
| Caenorhabditis elegans | Roundworm | Celegans | 6239 | ✅ | ✅ | ⚠️ | org.Ce.eg.db, TxDb.Celegans.UCSC.ce11.refGene | ce11 | Partial |
| **Fungi** |
| Saccharomyces cerevisiae | Brewer's yeast | Scerevisiae | 4932 | ✅ | ✅ | ✅ | org.Sc.sgd.db, TxDb.Scerevisiae.UCSC.sacCer3.sgdGene | sacCer3 | Full |
| Schizosaccharomyces pombe | Fission yeast | Spombe | 4896 | ✅ | ❌ | ⚠️ | org.Spombe.eg.db | N/A | Ortholog Only |
| Kluyveromyces lactis | Yeast | Klactis | 28985 | ✅ | ❌ | ⚠️ | N/A | N/A | Ortholog Only |
| Neurospora crassa | Bread mold | Ncrassa | 5141 | ✅ | ❌ | ⚠️ | N/A | N/A | Ortholog Only |
| Magnaporthe oryzae | Rice blast fungus | Moryzae | 318829 | ✅ | ❌ | ⚠️ | N/A | N/A | Ortholog Only |
| Eremothecium gossypii | Cotton pathogen | Egossypii | 33169 | ✅ | ❌ | ⚠️ | N/A | N/A | Ortholog Only |
| **Plants** |
| Arabidopsis thaliana | Thale cress | Athaliana | 3702 | ✅ | ❌ | ⚠️ | org.At.tair.db | N/A | Ortholog Only |
| Oryza sativa | Rice | Osativa | 4530 | ✅ | ❌ | ⚠️ | N/A | N/A | Ortholog Only |
| **Amphibians** |
| Xenopus tropicalis | Western clawed frog | Xtropicalis | 8364 | ✅ | ❌ | ⚠️ | N/A | N/A | Ortholog Only |

## Database Dependency Matrix

| Database Type | Required for | Species Count | Installation Required |
|---------------|--------------|---------------|----------------------|
| org.*.eg.db | Ortholog search | 20+ | Yes |
| org.*.tair.db | Arabidopsis | 1 | Yes |
| org.*.sgd.db | S. cerevisiae | 1 | Yes |
| org.*.plasmo.db | P. falciparum | 1 | Yes |
| TxDb.*.UCSC.* | Plotting | 13 | Yes |
| orthogene | Ortholog mapping | All | Yes |

## Genome Assembly Support

| Species | Assembly | UCSC Name | Status | Notes |
|---------|----------|-----------|--------|-------|
| Human | GRCh38 | hg38 | Current | Primary assembly |
| Mouse | GRCm39 | mm10 | Current | Primary assembly |
| Rat | Rnor_6.0 | rn6 | Current | Primary assembly |
| Chicken | GRCg6a | galGal6 | Current | Primary assembly |
| Zebrafish | GRCz11 | danRer11 | Current | Primary assembly |
| Drosophila | Release 6 | dm6 | Current | Primary assembly |
| C. elegans | WBcel235 | ce11 | Current | Primary assembly |
| S. cerevisiae | R64-1-1 | sacCer3 | Current | Primary assembly |

## Capability Flags Reference

### Ortholog Search Capabilities
- **Supported**: All organisms listed in the capability matrix
- **Requirements**: `orthogene` package, appropriate `org.*.db` package
- **Functions**: `getOrthHomolog()`, `getOrthologCoordinates()`

### Plotting Capabilities
- **Supported**: 13 organisms with "Full" support level
- **Requirements**: `TxDb.*.UCSC.*` package, `Gviz` package
- **Functions**: `synvizPlot()`, `multisynvizPlots()`, `plotSyntenyBlocks()`

### Synteny Analysis Capabilities
- **Supported**: 12 organisms with "Full" support level
- **Requirements**: Both ortholog search and plotting capabilities
- **Functions**: `createSyntenyBlockData()`, `getOrthologSyntenySummary()`

## Cross-Reference Tables

### Naming Convention Mapping

| Scientific Name | Common Name | Abbreviation | Taxonomy ID | UCSC Assembly |
|----------------|-------------|--------------|-------------|---------------|
| Homo sapiens | Human | Hsapiens | 9606 | hg38 |
| Mus musculus | House mouse | Mmusculus | 10090 | mm10 |
| Rattus norvegicus | Brown rat | Rnorvegicus | 10116 | rn6 |
| Danio rerio | Zebrafish | Drerio | 7955 | danRer11 |
| Drosophila melanogaster | Fruit fly | Dmelanogaster | 7227 | dm6 |
| Caenorhabditis elegans | Roundworm | Celegans | 6239 | ce11 |
| Saccharomyces cerevisiae | Brewer's yeast | Scerevisiae | 4932 | sacCer3 |

### Database Package Mapping

| Species | Annotation DB | Transcriptome DB | Installation Command |
|---------|---------------|------------------|---------------------|
| Hsapiens | org.Hs.eg.db | TxDb.Hsapiens.UCSC.hg38.knownGene | BiocManager::install(c("org.Hs.eg.db", "TxDb.Hsapiens.UCSC.hg38.knownGene")) |
| Mmusculus | org.Mm.eg.db | TxDb.Mmusculus.UCSC.mm10.knownGene | BiocManager::install(c("org.Mm.eg.db", "TxDb.Mmusculus.UCSC.mm10.knownGene")) |
| Drerio | org.Dr.eg.db | TxDb.Drerio.UCSC.danRer11.refGene | BiocManager::install(c("org.Dr.eg.db", "TxDb.Drerio.UCSC.danRer11.refGene")) |
| Dmelanogaster | org.Dm.eg.db | TxDb.Dmelanogaster.UCSC.dm6.ensGene | BiocManager::install(c("org.Dm.eg.db", "TxDb.Dmelanogaster.UCSC.dm6.ensGene")) |
| Celegans | org.Ce.eg.db | TxDb.Celegans.UCSC.ce11.refGene | BiocManager::install(c("org.Ce.eg.db", "TxDb.Celegans.UCSC.ce11.refGene")) |
| Scerevisiae | org.Sc.sgd.db | TxDb.Scerevisiae.UCSC.sacCer3.sgdGene | BiocManager::install(c("org.Sc.sgd.db", "TxDb.Scerevisiae.UCSC.sacCer3.sgdGene")) |

## Usage Guidelines

### For Full Support Organisms
- All SyntenyViz functions are available
- Complete workflow from ortholog search to visualization
- Recommended for comprehensive comparative genomics analysis

### For Partial Support Organisms
- Ortholog search and basic plotting available
- Limited synteny analysis capabilities
- Suitable for basic comparative analysis

### For Ortholog Only Organisms
- Ortholog search and coordinate retrieval available
- No plotting or synteny visualization
- Suitable for ortholog identification and analysis

### For Experimental Organisms
- Limited or untested functionality
- May require additional configuration
- Use with caution and validate results

## Troubleshooting

### Common Issues

1. **"Organism not supported for plotting"**
   - Check organism support level in capability matrix
   - Use `validateOrganismSupport()` to check capabilities
   - Consider alternative organisms with full support

2. **"Database not found"**
   - Install required database packages
   - Use `checkDatabaseAvailability()` to verify installation
   - Check database package names in dependency matrix

3. **"Genome assembly not found"**
   - Verify genome assembly name in assembly support table
   - Use `getGenomeAssembly()` to get correct assembly
   - Check UCSC assembly availability

4. **"Coordinate format invalid"**
   - Use format 'chromosome:start:end' (e.g., '2:16e7:16.5e7')
   - Use `coordFormat()` to convert coordinate strings
   - Validate with `validateCoordinateFormat()`

### Validation Functions

- `validateOrganismSupport()` - Check organism capabilities
- `checkPlottingCompatibility()` - Validate organism lists for plotting
- `checkDatabaseAvailability()` - Verify database installation
- `validateCoordinateFormat()` - Check coordinate format compatibility
- `validateWorkflowCompatibility()` - Validate complete workflows

## Best Practices

1. **Always validate organism support** before starting analysis
2. **Check database availability** for required organisms
3. **Use appropriate coordinate formats** for your analysis
4. **Follow the comprehensive user example** for proper workflow
5. **Use verbose = TRUE** for detailed error information
6. **Check organism support reference** for capability details

## Updates and Maintenance

This reference is updated regularly to reflect:
- New organism support additions
- Database package updates
- Genome assembly releases
- Capability changes

For the most current information, always check the latest version of this document and use the validation functions provided in SyntenyViz.

