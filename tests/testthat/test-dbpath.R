test_that("dbpath works when passwords contain @", {
  expect_equal(
    dbpath("a+b://c:at@@d")[["password"]],
    "at@"
  )
})

test_that("dbpath print hides passwords", {
  expect_equal(
    print(dbpath("a+b://c:my_password@d")),
    "a+b://c:****@d"
  )
})
