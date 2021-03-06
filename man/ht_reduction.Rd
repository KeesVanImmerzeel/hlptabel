% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ht_utilities.r
\name{ht_reduction}
\alias{ht_reduction}
\title{Calculate reduction in crop production caused by waterlogging and drought.}
\usage{
ht_reduction(GHG, GLG, HELP, landuse)
}
\arguments{
\item{GHG}{Average highest groundwater level, relative to soil surface level, (m) (numeric)}

\item{GLG}{Average lowest groundwater level, relative to soil surface level, (m) (numeric)}

\item{HELP}{HELP (soil) number 1-70 (integer).}

\item{landuse}{1=grassland; 2=arable land (integer)}
}
\value{
Calculated reduction in crop production (list) with three elements:
red_wl: caused by waterlogging (\%); (numeric)
red_dr: caused by drought (\%); (numeric)
red_tot: (\%) (numeric)
}
\description{
Calculate reduction in crop production caused by waterlogging and drought.
}
\examples{
GHG <- 0.25
GLG <- 1.4
HELP <- 15
landuse <- 1
ht_reduction( GHG, GLG, HELP, landuse )
}
