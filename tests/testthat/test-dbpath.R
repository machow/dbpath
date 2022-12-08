test_that("dbpath works when passwords contain @", {
  expect_equal(
    dbpath("a+b://c:at@@d")[["password"]],
    "at@"
  )
})

test_that("dbpath print hides passwords", {
  expect_snapshot(dbpath("a+b://c:my_password@d"))
  expect_equal(
    format(dbpath("a+b://c:my_password@d"), hide_password = TRUE),
    "a+b://c:****@d"
  )
})
