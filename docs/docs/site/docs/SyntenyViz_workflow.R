## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  error = TRUE
)

## ----setup, include=FALSE-----------------------------------------------------
library(SyntenyViz)

## preload libs for better vignettes performance
library(grid)
library(dplyr)
pkgs <- c("org.Hs.eg.db", "org.Mm.eg.db", "org.Rn.eg.db", "TxDb.Hsapiens.UCSC.hg38.knownGene",
  "TxDb.Mmusculus.UCSC.mm10.knownGene", "TxDb.Rnorvegicus.UCSC.rn6.refGene")
for (pkg in pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
        BiocManager::install(pkg)}
  library (pkg, character.only = TRUE)
}

## -----------------------------------------------------------------------------
# orgm is a handle for organism
orgmName <- "Mmusculus"
# mycoords.list is the investigation range handler
mycoords <- "2:6.0e7:6.5e7"

## -----------------------------------------------------------------------------
mycoords.gr <- SyntenyViz::coordFormat (mycoords.list = mycoords)

## -----------------------------------------------------------------------------
mycoords.gr

## ----fig.cap='Synteny of Mouse DPP4', fig.pos='h', include=TRUE, out.width='90%', fig.show='hold', message=FALSE, warning=FALSE, dev='png', cache=TRUE, fig.retina=4----
synvizPlot(mycoords.gr, orgmName)

## ---- warning=FALSE-----------------------------------------------------------
orgm.1 <- "Hsapiens"
mycoords.list.1 <- "2:15.95e7:16.45e7"
orgm.2 <- "Mmusculus"
mycoords.list.2 <- "2:6.0e7:6.5e7"
orgm.3 <- "Rnorvegicus"
mycoords.list.3 <- "3:4.6e7:5.1e7"

## -----------------------------------------------------------------------------
orgmsList <- orgmsCollection.init (orgmsList)
orgmsList <- orgmsAdd (orgm.1, orgmTxDB, mycoords.list.1, orgmsList)
orgmsList <- orgmsAdd (orgm.2, orgmTxDB, mycoords.list.2, orgmsList)
orgmsList <- orgmsAdd (orgm.3, orgmTxDB, mycoords.list.3, orgmsList)

## ---- out.width='95%', fig.height=7, fig.cap = 'Multi Synteny Plot of DPP4', fig.pos = 'h', cache=TRUE, dev.args=list(pointsize=2), fig.retina=4----
multiplot <- multisynvizPlots(orgmsList)

## ---- out.width='90%', fig.align='center', fig.cap = 'DPP4 protein in dimmer form', fig.pos = 'h'----
knitr::include_graphics('images/DPP4.png')

## -----------------------------------------------------------------------------
# orgm is a handle for organism
orgm <- "Hsapiens"
# mycoords.list is the investigation range handler
mycoords.list <- "2:15.95e7:16.45e7"

## -----------------------------------------------------------------------------
# Return mycoords.gr as a GRange object
mycoords.gr <- coordFormat (mycoords.list = mycoords.list)

## ---- echo=FALSE--------------------------------------------------------------
knitr::kable(orgmTxDB, caption = "Available transcriptomics dataset for analysis as in SyntenyViz v0.0.0.9000")

## ---- echo=FALSE--------------------------------------------------------------
knitr::kable(orgmOrgDB, caption = "Available organisms for analysis as in SyntenyViz v0.0.0.9000")

## ---- echo=FALSE--------------------------------------------------------------
knitr::kable(SynVizOrgms, results='asis', caption = "Reference Card for organisms Names")

## -----------------------------------------------------------------------------
orgm_OrgDB <- getPkgs(orgm, orgmOrgDB)
orgm_TxDB <- getPkgs(orgm, orgmTxDB)

## -----------------------------------------------------------------------------
plotData <- synvizPlotData(mycoords.gr =  mycoords.gr, orgm = orgm)

## -----------------------------------------------------------------------------
plotData

## ---- out.width='90%', fig.height=4, fig.cap = 'Synteny of Mouse DPP4', fig.pos = 'h', include=TRUE, fig.retina=4----
synvizPlot (mycoords.gr = mycoords.gr, orgm = orgm)

## ---- warning=FALSE-----------------------------------------------------------
orgm.1 <- "Hsapiens"
mycoords.list.1 <- "2:15.95e7:16.45e7"
orgm.2 <- "Mmusculus"
mycoords.list.2 <- "2:6.0e7:6.5e7"
orgm.3 <- "Rnorvegicus"
mycoords.list.3 <- "3:4.6e7:5.1e7"

orgmsList <- orgmsCollection.init (orgmsList)
orgmsList <- orgmsAdd (orgm.1, orgmTxDB, mycoords.list.1, orgmsList)
orgmsList <- orgmsAdd (orgm.2, orgmTxDB, mycoords.list.2, orgmsList)
orgmsList <- orgmsAdd (orgm.3, orgmTxDB, mycoords.list.3, orgmsList)

## ---- out.width='95%', fig.height=7, fig.cap = 'Multi Synteny Plot of DPP4', fig.pos = 'h', include=TRUE, dev.args=list(pointsize=2), fig.retina=4----
multiplot <- multisynvizPlots(orgmsList)

