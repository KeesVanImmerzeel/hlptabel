#' hlptabel: Calculate reduction in crop production caused by waterlogging and drought.
#'
#' Based on the publication "De invloed van de waterhuishouding op de landbouwkundige produktie".
#' Rapport van de werkgroep HELP-tabel, Mededelingen Landinrichtingsdienst 176 (1987).
#' \href{https://edepot.wur.nl/188152}{Rapport van de werkgroep HELP-tabel}
#'
#' Approximate analytical formulas are used to calculate the reduction in crop productions.
#'
#' This package exports no sample data sets/objects
#'
#' This package exports the following functions:
#'
#' * \code{\link{ht_reduction}}
#'
#' * \code{\link{ht_soilnr_to_HELPnr}}
#'
#' * \code{\link{ht_bofek_to_HELPnr}}
#'
#' * \code{\link{ht_soil_unit_to_HELPnr}}
#'
#' * \code{\link{ht_soil_units}}
#'
#' * \code{\link{ht_bofek_numbers}}
#'
#' * \code{\link{ht_HELPnr_to_HELPcode}}
#'
#' * \code{\link{ht_tab_calc_values}}
#'
#' * \code{\link{ht_plot_tab_calc_values}}
#'
#' @details
#' You might consider to reclassify the HELP numbers 71 and 72 to the most similar soil codes in the HELP-table (1987).
#' if `x` is the raster with HELP numbers (1-72), reclassify with:
#'
#' `x[x[]==71] <- 67`
#'
#' `x[x[]==72] <- 60`
#'
#' @docType package
#' @name hlptabel
#'
#' @importFrom magrittr %<>%
#' @importFrom magrittr %>%
#'
#' @importFrom dplyr filter
#' @importFrom dplyr arrange
#' @importFrom dplyr desc
#'
#' @importFrom stats na.omit
#'
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 geom_point
#' @importFrom ggplot2 geom_abline
#' @importFrom ggplot2 theme
#' @importFrom ggplot2 labs
#' @importFrom ggplot2 ggtitle
#' @importFrom ggplot2 theme
#' @importFrom ggplot2 element_blank
#' @importFrom ggplot2 element_text
NULL
