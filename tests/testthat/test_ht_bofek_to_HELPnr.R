test_that("ht_bofek_to_HELPnr(101) results in correct HELP number.", {
  expect_equal(ht_bofek_to_HELPnr(101), 3)
})

test_that("ht_bofek_to_HELPnr(0) results in NA.", {
  expect_equal(ht_bofek_to_HELPnr(0), NA)
})
