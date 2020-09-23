test_that("ht_soilnr_to_HELPnr( ) results in correct HELP number.", {
  expect_equal(ht_soilnr_to_HELPnr( 1030 ), 3)
})

test_that("Invalid value of argument in ht_soilnr_to_HELPnr( ) results in NA.", {
  expect_equal(ht_soilnr_to_HELPnr( "invalid argument"), NA)
})
