#
fname <- file.path("data-raw", "example_spatraster.tif")
x <- file.path("data-raw", "example_spatraster.tif") |> terra::rast("example_spatraster.tif")

# Save result to inst/extdata folder
fname <- file.path("inst", "extdata", "example_spatraster.tif")
x |> terra::writeRaster(fname, overwrite=TRUE)
