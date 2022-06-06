library(magrittr)
library(terra)

# Write aggregated version of raster in file "fname", folder "dirstr". fact=20 --> resolution of resulting raster is 25x25m.
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

#rcl <- "BOFEK2020_HELP.csv" %>% file.path("data-raw","Bofek2020",.) %>% read.table(header=TRUE, sep=",")

# Create aggregated versions of all tiff-files specified in folder "c:/tmp/TOP25raster_GEOTIFF".
# Results are written in folder "c:/tmp/tmp".
pattern <- utils::glob2rx("*.tif")
dirstr <- "c:/tmp/tmp"
suppressWarnings(dir.create(dirstr))
"c:/tmp/TOP25raster_GEOTIFF" %>%
  list.files(pattern = pattern, full.names = TRUE) %>%
  lapply(FUN = f, dirstr = dirstr)

# Merge aggregated files to one file "TOP25raster_2022.tif" in folder "data-raw\Landuse_2022".
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
m <- terra::merge(m1, m2, m3, m4, m5, m6, m7, m8)
m %>%
  terra::writeRaster(file.path("data-raw","Landuse_2022","TOP25raster_2022.tif"), overwrite=TRUE)

