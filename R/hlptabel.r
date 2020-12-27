#' hlptabel: Calculate reduction in crop production caused by waterlogging and drought.
#'
#' Based on the publication "De invloed van de waterhuishouding op de landbouwkundige produktie".
#' Rapport van de werkgroep HELP-tabel, Mededelingen Landinrichtingsdienst 176 (1987).
#' \href{https://edepot.wur.nl/188152}{Rapport van de werkgroep HELP-tabel}
#'
#' Approximate analytical formulas are used to calculate the reduction in crop productions.
#'
#' https://r-pkgs.org/data.html
#'
#' This package exports the following functions:
#'
#' * \code{\link{ht_reduction}}: Calculate reduction in crop production caused by waterlogging and drought.
#'
#' * \code{\link{ht_reduction_brk}}: Calculate reduction in crop production caused by waterlogging and drought using a RasterBrick object as input.
#'
#' * \code{\link{ht_soilnr_to_HELPnr}}: Get HELP number by specifying a soil number (1010, ..., 22020).
#'
#' * \code{\link{ht_bofek_to_HELPnr}}: Get HELP number by specifying a bofek number.
#'
#' * \code{\link{ht_soil_unit_to_HELPnr}}: Get HELP number by specifying a soil unit ("soil_unit").
#'
#' * \code{\link{ht_soil_units}}: Valid soil units.
#'
#' * \code{\link{ht_bofek_numbers}}: Valid bofek numbers.
#'
#' * \code{\link{ht_HELPnr_to_HELPcode}}: Get HELP (soil) code by specifying HELP number.
#'
#' * \code{\link{ht_tab_calc_values}}: Tabulated and calculated reductions in crop production.
#'
#' * \code{\link{ht_plot_tab_calc_values}}: Plot of tabulated and calculated reductions in crop production.
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
#'
#' @importFrom raster brick
#' @importFrom raster calc
#' @importFrom raster beginCluster
#' @importFrom raster clusterR
#' @importFrom raster endCluster
NULL
