# coordFormat
#' Format input strings into GRange object
#'
#' Split input string with deliminator ":" then transform into GRange object
#'
#' @param mycoords.list A string list with the format of "2:16e7:16.5e7"
#'
#' @export
#' @return A target search range as a GRanges object
#' @examples
#'
#' if (requireNamespace("dplyr", quietly = TRUE)) {
#'   mycoords.list <- "2:16e7:16.5e7"
#'   coordFormat (mycoords.list)
#' }

coordFormat <- function (mycoords.list) {
  GRangeObj <- lapply(mycoords.list, function (x) {res=strsplit(x, ':')}) %>% unlist  %>%
                    as.numeric %>%
                    matrix(ncol=3, byrow=T) %>%
                    as.data.frame %>%
                    dplyr::select(chrom=V1, start=V2, end=V3) %>%
                    dplyr::mutate(chrom=paste0('chr', chrom)) %>%
                    GenomicRanges::makeGRangesFromDataFrame()
  return (GRangeObj)
}
