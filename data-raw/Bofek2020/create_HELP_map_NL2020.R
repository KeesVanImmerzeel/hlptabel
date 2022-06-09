library(magrittr)
library(terra)
library(raster)

# Reclassify Bofek2020 raster map to create HELP map.
rcl <- "BOFEK2020_HELP.csv" %>% file.path("data-raw","Bofek2020",.) %>% read.table(header=TRUE, sep=",")
x <- "BOFEK2020.tif" %>% file.path("data-raw","Bofek2020",.) %>% terra::rast()
HELP_map_NL2020 <- x %>% terra::classify(rcl, others=NA )

# SpatRaster breaks when saved as an R object, so convert to raster format before writing to rda-file.
HELP_map_NL2020%<>% raster::raster()
usethis::use_data(HELP_map_NL2020, internal = FALSE, overwrite=TRUE, version=2)
