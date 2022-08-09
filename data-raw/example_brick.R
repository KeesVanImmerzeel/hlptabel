library(devtools)
devtools::load_all()

library(raster)

example_brick <- raster::brick("data-raw/example_brick")

## Save external objects"
usethis::use_data(
  example_brick,
  overwrite = TRUE,
  internal = FALSE
)

