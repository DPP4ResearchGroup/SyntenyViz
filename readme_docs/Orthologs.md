# Ortholog Analysis in SyntenyViz

`SyntenyViz` provides comprehensive ortholog analysis capabilities, including ortholog identification, coordinate retrieval, and synteny block visualization. The package has a dependency on R package `orthogene` of version `1.12.0` or above for orthologs matching mechanism.

## Ortholog Functions

### 1. Ortholog Identification
- `getOrthHomolog()`: Search for orthologous genes across species
- Uses the `orthogene` package for high-confidence ortholog identification

### 2. Ortholog Coordinate Retrieval
- `getOrthologCoordinates()`: Retrieve genomic coordinates for orthologous genes
- Maps orthologs to their genomic positions in both source and target species
- Returns structured data for synteny analysis

### 3. Synteny Block Visualization
- `createSyntenyBlockData()`: Create synteny block data structures
- `plotSyntenyBlocks()`: Visualize synteny blocks with ortholog connections
- `getOrthologSyntenySummary()`: Generate synteny conservation metrics

## Supported Species

As of version `1.12.0` stands, the following species are supported and can be searched against:


| Scientific Name              | Taxonomy ID | Source      | ID             | Scientific Name Formatted       |
|------------------------------|-------------|-------------|----------------|----------------------------------|
| Mus musculus                 | 10090       | homologene  | mmusculus      | mus musculus                    |
| Rattus norvegicus            | 10116       | homologene  | rnorvegicus    | rattus norvegicus               |
| Kluyveromyces lactis         | 28985       | homologene  | klactis        | kluyveromyces lactis            |
| Magnaporthe oryzae           | 318829      | homologene  | moryzae        | magnaporthe oryzae              |
| Eremothecium gossypii        | 33169       | homologene  | egossypii      | eremothecium gossypii           |
| Arabidopsis thaliana         | 3702        | homologene  | athaliana      | arabidopsis thaliana            |
| Oryza sativa                 | 4530        | homologene  | osativa        | oryza sativa                    |
| Schizosaccharomyces pombe    | 4896        | homologene  | spombe         | schizosaccharomyces pombe       |
| Saccharomyces cerevisiae     | 4932        | homologene  | scerevisiae    | saccharomyces cerevisiae        |
| Neurospora crassa            | 5141        | homologene  | ncrassa        | neurospora crassa               |
| Caenorhabditis elegans       | 6239        | homologene  | celegans       | caenorhabditis elegans          |
| Anopheles gambiae            | 7165        | homologene  | agambiae       | anopheles gambiae               |
| Drosophila melanogaster      | 7227        | homologene  | dmelanogaster  | drosophila melanogaster         |
| Danio rerio                  | 7955        | homologene  | drerio         | danio rerio                     |
| Xenopus (Silurana) tropicalis| 8364        | homologene  | xtropicalis    | xenopus tropicalis              |
| Gallus gallus                | 9031        | homologene  | ggallus        | gallus gallus                   |
| Macaca mulatta               | 9544        | homologene  | mmulatta       | macaca mulatta                  |
| Pan troglodytes              | 9598        | homologene  | ptroglodytes   | pan troglodytes                 |
| Homo sapiens                 | 9606        | homologene  | hsapiens       | homo sapiens                    |
| Canis lupus familiaris       | 9615        | homologene  | clfamiliaris   | canis lupus familiaris          |
| Bos taurus                   | 9913        | homologene  | btaurus        | bos taurus                      |