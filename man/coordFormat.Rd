% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/coordFormat.R
\name{coordFormat}
\alias{coordFormat}
\title{Format input strings into GRange object}
\usage{
coordFormat(mycoords.list)
}
\arguments{
\item{mycoords.list}{A string list with the format of "2:16e7:16.5e7"}
}
\value{
A target search range as a GRanges object
}
\description{
Split input string with deliminator ":" then transform into GRange object
}
\examples{

if (requireNamespace("dplyr", quietly = TRUE)) {
  mycoords.list <- "2:16e7:16.5e7"
  coordFormat (mycoords.list)
}
}
