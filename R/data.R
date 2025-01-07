#' Raster map of 1987 HELP codes for the Netherlands
#'
#' Raster map of 1987 HELP codes for the Netherlands, based on the Bofek2020 raster map.
#' Resolution 25x25m.
#'
#' The HELP numbers 71 and 72 are converted to the most similar soil codes in the HELP-table (1987).
#' [HELP-2005 Stowa rapport 2005/16 (page 16)](https://library.wur.nl/WebQuery/wurpubs/fulltext/27040)
#' HELP number 71 --> 67; HELP number 72 --> 60.
#'
#' To use this dataset, the following code can be used:
#' `HELP_map_NL2020 <- file.path( find.package("hlptabel"), "extdata", "HELP_map_NL2020.tif") |> terra::rast()`
#'
#' @source [Bofek2020](https://www.wur.nl/nl/show/bodemfysische-eenhedenkaart-bofek2020.htm)
#"HELP_map_NL2020"

#' landuse map (units gras=1, akker=2) for the Netherlands.
#'
#' Raster map (resolution 25x25m) of landuse (2021) based on the TOP25raster_GEOTIFF dataset 2021.
#'
#' To use this dataset, the following code can be used:
#' `landuse_map_NL2021 <- file.path( find.package("hlptabel"), "extdata", "landuse_map_NL2021.tif") |> terra::rast()`
#'
#' @source [TOP25raster](https://geodata.nationaalgeoregister.nl/top25raster/extract/kaartbladtotaal/top25raster-geotiff-landsdekkend.zip?formaat=geotiff&datum=2021-11-23)
#"landuse_map_NL2021"
