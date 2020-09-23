test_that("ht_reduction(GHG=0.25, GLG=1.4, HELP=15, landuse=1) results in previously created object.", {
  expect_equal(ht_reduction(GHG=0.25, GLG=1.4, HELP=15, landuse=1), chk_red_gras)
})

test_that("ht_reduction(GHG=0.25, GLG=1.4, HELP=15, landuse=2) results in previously created object.", {
  expect_equal(ht_reduction(GHG=0.25, GLG=1.4, HELP=15, landuse=2), chk_red_bouw)
})
