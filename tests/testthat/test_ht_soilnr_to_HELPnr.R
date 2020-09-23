test_that("ht_soil_unit_to_HELPnr( ) results in correct HELP number.", {
  expect_equal(ht_soil_unit_to_HELPnr( "faVzt" ), 2)
})

test_that("Invalid value of argument in ht_soil_unit_to_HELPnr( ) results in NA.", {
  expect_equal(ht_bofek_to_HELPnr( "invalid argument"), NA)
})
