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

test_that("dbpath url-decodes and encodes usernname and password", {
  url_user_pass <- "drv://%24%40lly:p%40ssw%2Ard@host"

  # decoded internally
  expect_equal(
    dbpath(url_user_pass)$password,
    "p@ssw*rd"
  )
  expect_equal(
    dbpath(url_user_pass)$username,
    "$@lly"
  )

  # re-encoded when forming a URL
  expect_equal(
    format(dbpath(url_user_pass)),
    url_user_pass
  )

  # encoded in the print method
  expect_snapshot(
    print(dbpath(url_user_pass), hide_password = FALSE)
  )
})

test_that("dbpath url-decodes and encodes query parameters", {
  url_q <- "drv://user@host/db?foo=bar%20and%20baz"

  # decoded internally
  expect_equal(
    dbpath(url_q)$params$foo,
    "bar and baz"
  )

  # re-encoded when forming a URL
  expect_equal(
    format(dbpath(url_q)),
    url_q
  )

  # encoded in the print method
  expect_snapshot(
    print(dbpath(url_q))
  )
})
