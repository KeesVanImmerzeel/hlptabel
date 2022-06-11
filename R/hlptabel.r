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
#' * \code{\link{ht_tab_calc_values}}: Tabulated and calculated reductions in crop production.
#'
#' * \code{\link{ht_plot_tab_calc_values}}: Plot of tabulated and calculated reductions in crop production.
#'
#' @details
#' You might consider to reclassify the HELP numbers 71 and 72 to the most similar soil codes in the HELP-table (1987).
#' HELP number 71 --> 67; HELP number 72 --> 60. Dataset HELP_map_NL2020 is already converted in this way.
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
