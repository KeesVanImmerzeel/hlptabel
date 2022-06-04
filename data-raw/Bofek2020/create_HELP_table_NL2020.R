library(magrittr, terra)

rcl <- "BOFEK2020_HELP.csv" %>% file.path("data-raw","Bofek2020",.) %>% read.table(header=TRUE, sep=",")
x <- "BOFEK2020.tif" %>% file.path("data-raw","Bofek2020",.) %>% terra::rast()
HELP_table_NL2020 <- x %>% terra::classify(rcl, others=NA )
# SpatRaster breaks when saved as an R object, so convert to raster format before writing to rda-file.
HELP_table_NL2020%<>% raster::raster()
usethis::use_data(HELP_table_NL2020, internal = FALSE, overwrite=TRUE, version=3)
