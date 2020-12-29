test_that("ht_reduction_brk() results in previously created object.", {
  x <- raster::brick(system.file("extdata","example_brick.grd",package="hlptabel"))
  expect_equal(ht_reduction_brk(x), chk_red_brk)
})
