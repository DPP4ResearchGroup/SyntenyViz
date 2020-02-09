context("Gene Coordination Format")
library("GenomicRanges")

targetGRange <- GRanges(seqnames = Rle("chr2", 1),
                        ranges = IRanges(start=c(16e7), width=5000001),
                        strand = rep(("*"), 1))

test_that("coordFormat format is correct", {
  expect_equal(coordFormat("2:16e7:16.5e7"), targetGRange)
})
