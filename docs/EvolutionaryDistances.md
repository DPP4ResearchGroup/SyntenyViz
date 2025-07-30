# Evolutionary Distances in SyntenyViz

## Overview

SyntenyViz now uses a YAML file to store evolutionary distances between species pairs. This approach provides several benefits:

- **Maintainability**: Easy to update and add new species pairs
- **Flexibility**: Structured organization by taxonomic groups
- **Extensibility**: Simple to extend with new data sources
- **Version Control**: Changes to distances can be tracked in git

## File Structure

The evolutionary distances are stored in `data/evolutionary_distances.yml` with the following structure:

```yaml
mammals:
  primates:
    human-chimpanzee: 0.01
    human-gorilla: 0.02
    # ... more primate comparisons
  
  rodents:
    human-mouse: 0.3
    mouse-rat: 0.1
    # ... more rodent comparisons

birds:
  chicken-duck: 0.08
  chicken-turkey: 0.06
  # ... more bird comparisons

# ... other taxonomic groups
```

## Distance Scale

All evolutionary distances are normalized to a 0-1 scale where:
- **0**: Identical species (no divergence)
- **1**: Maximum divergence

## Adding New Species Pairs

To add new evolutionary distances:

1. **Edit the YAML file**: Add new species pairs to the appropriate taxonomic group
2. **Follow the naming convention**: Use lowercase with underscores (e.g., `zebra_finch`)
3. **Provide realistic values**: Base distances on molecular clock estimates or phylogenetic studies
4. **Test the changes**: Run the test suite to ensure everything works

### Example: Adding a new fish comparison

```yaml
fish:
  zebrafish-medaka: 0.15
  zebrafish-stickleback: 0.25
  zebrafish-tetra: 0.20  # New addition
```

## Using the Functions

### `getEvolutionaryDistances()`

Query available evolutionary distances:

```r
# Get all distances
all_distances <- getEvolutionaryDistances()

# Filter by species
human_distances <- getEvolutionaryDistances(species1 = "human")

# Filter by distance range
close_distances <- getEvolutionaryDistances(min_distance = 0.1, max_distance = 0.3)
```

### `calculateOrthologSimilarity()`

Calculate ortholog similarity with evolutionary distance:

```r
# Calculate evolutionary similarity
result <- calculateOrthologSimilarity(ortholog_data, "human", "mouse", 
                                    similarity_type = "evolutionary")
```

## Error Handling

The system includes robust error handling:

- **Missing YAML file**: Falls back to default distances
- **Invalid YAML**: Provides warning and uses fallback
- **Missing species pair**: Uses default distance (0.5)

## Metadata

The YAML file includes metadata for documentation:

```yaml
metadata:
  description: "Evolutionary distances based on molecular clock estimates"
  scale: "Normalized 0-1 scale where 0 = identical, 1 = maximum divergence"
  units: "Arbitrary units based on molecular clock estimates"
  last_updated: "2024-01-01"
  source: "Molecular clock estimates and phylogenetic studies"
```

## Taxonomic Groups

The current structure includes:

- **Mammals**: Primates, rodents, carnivores, ungulates
- **Birds**: Various bird species
- **Fish**: Model fish species
- **Amphibians**: Frogs, salamanders, newts
- **Reptiles**: Lizards, snakes, turtles, crocodiles
- **Insects**: Drosophila, mosquitoes, bees, silkworms
- **Nematodes**: C. elegans and related species
- **Yeasts**: S. cerevisiae, S. pombe, C. albicans
- **Plants**: Arabidopsis, rice, maize, wheat
- **Cross-phylum**: Comparisons across major taxonomic groups

## Future Enhancements

Potential improvements to consider:

1. **Dynamic loading**: Load distances from external databases
2. **Multiple sources**: Support for different distance calculation methods
3. **Confidence intervals**: Include uncertainty in distance estimates
4. **Time-based distances**: Include divergence time estimates
5. **Gene-specific distances**: Different distances for different gene families 