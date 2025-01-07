library(magrittr)
library(terra)

# Reclassify Bofek2020 raster map to create HELP map.
rcl <- "BOFEK2020_HELP.csv" %>% file.path("data-raw","HELP_map_NL2020",.) %>% read.table(header=TRUE, sep=",")
x <- "BOFEK2020.tif" %>% file.path("data-raw","HELP_map_NL2020",.) %>% terra::rast()
HELP_map_NL2020 <- x %>% terra::classify(rcl, others=NA )

# In the HELP-table (1987) the HELP numbers 71 and 72 where not included.
# Renumber these HELP numbers to the most similar soil codes in the HELP-table (1987).
# HELP-2005. stowa rapport 2005/16, page 16.
# 'Uitbreiding en actualisering van de HELP-tabellen ten behoeve van het Waternood-instrumentarium'.
# https://library.wur.nl/WebQuery/wurpubs/fulltext/27040
m <- c(71, 67,
       72, 60)
rcl <- matrix(m, ncol=2, byrow=TRUE)
HELP_map_NL2020 <-  terra::classify(HELP_map_NL2020, rcl )

# Save result to inst/extdata folder
fname <- file.path("inst", "extdata", "HELP_map_NL2020.tif")
HELP_map_NL2020 |> terra::writeRaster(fname, overwrite=TRUE)
