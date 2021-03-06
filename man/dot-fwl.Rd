% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ht_utilities.r
\name{.fwl}
\alias{.fwl}
\title{Function to calculate the reduction in crop production caused by waterlogging.}
\usage{
.fwl(x, GHG, GLG, min_red)
}
\arguments{
\item{x}{Parameters (A-E) in the analytic function to calculate the reduction in crop production caused by waterlogging.}

\item{GHG}{Average highest groundwater level, relative to soil surface level, (m) (numeric)}

\item{GLG}{Average lowest groundwater level, relative to soil surface level, (m) (numeric)}

\item{min_red}{Minimum value of the reduction in crop production caused by waterlogging (\%) (numeric)}
}
\value{
Reduction in crop production caused by waterlogging (\%); (numeric)
}
\description{
Function to calculate the reduction in crop production caused by waterlogging.
}
