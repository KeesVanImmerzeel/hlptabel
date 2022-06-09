library(magrittr)
library(terra)
library(raster)
# Create a landuse map of the Netherlands (units gras=1, akker=2) based on the TOP25raster_GEOTIFF dataset 2021, resolution 25x25m.
# Source files from:
# https://geodata.nationaalgeoregister.nl/top25raster/extract/kaartbladtotaal/top25raster-geotiff-landsdekkend.zip?formaat=geotiff&datum=2021-11-23
# should be available in folder in folder "c:/tmp/TOP25raster_GEOTIFF.

# Function to write aggregated version of raster in file "fname", folder "dirstr". fact=20 --> resolution of resulting raster is 25x25m.
f <- function(fname, dirstr) {
  fname_new <- dirstr %>% file.path(basename(fname))
  print(fname_new)
  fname %>% terra::rast() %>% terra::aggregate(
    fact = 20,
    fun = "modal",
    cores = 4,
    filename = fname_new,
    overwrite = TRUE
  )
}

# Create aggregated versions of all tiff-files specified in folder "c:/tmp/TOP25raster_GEOTIFF".
# Results are written in folder "c:/tmp/tmp".
pattern <- utils::glob2rx("*.tif")
dirstr <- "c:/tmp/tmp"
suppressWarnings(dir.create(dirstr))
"c:/tmp/TOP25raster_GEOTIFF" %>%
  list.files(pattern = pattern, full.names = TRUE) %>%
  lapply(FUN = f, dirstr = dirstr)

# Merge aggregated files to one file "TOP25raster_2021.tif" in folder "data-raw\Landuse_2021".
# To avoid (slow) memory swapping to disk, do this in a few steps.
fls <-
  dirstr %>%
  file.path() %>%
  list.files(pattern = pattern, full.names = TRUE)
m1 <-
  fls[1:50]    %>% lapply(terra::rast) %>% terra::sprc() %>% terra::merge()
m2 <-
  fls[51:100]  %>% lapply(terra::rast) %>% terra::sprc() %>% terra::merge()
m3 <-
  fls[101:150] %>% lapply(terra::rast) %>% terra::sprc() %>% terra::merge()
m4 <-
  fls[151:200] %>% lapply(terra::rast) %>% terra::sprc() %>% terra::merge()
m5 <-
  fls[201:250] %>% lapply(terra::rast) %>% terra::sprc() %>% terra::merge()
m6 <-
  fls[251:300] %>% lapply(terra::rast) %>% terra::sprc() %>% terra::merge()
m7 <-
  fls[301:350] %>% lapply(terra::rast) %>% terra::sprc() %>% terra::merge()
m8 <-
  fls[351:390] %>% lapply(terra::rast) %>% terra::sprc() %>% terra::merge()
x <- terra::merge(m1, m2, m3, m4, m5, m6, m7, m8)
fname <- file.path("data-raw","Landuse_2021","TOP25raster_2021.tif")
x %>%
  terra::writeRaster(fname, overwrite=TRUE)

# Reclassify to create landuse_map_NL2021.
# gras: 72, 73; bouwland 135
x <- terra::rast(fname)
m <- c(72, 1,
       73, 1,
       135, 2)
rcl <- matrix(m, ncol=2, byrow=TRUE)
landuse_map_NL2021 <- x %>% terra::classify(rcl, others=NA )

# use result.
# SpatRaster breaks when saved as an R object, so convert to "raster" format before writing to rda-file.
landuse_map_NL2021 %<>% raster::raster()
usethis::use_data(landuse_map_NL2021, overwrite = TRUE)


