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

test_that("dbpath url-decodes and encodes passwords", {
  url_pwd <- "drv://user:p%40ssw%2Ard@host"

  # decoded on ingest
  expect_equal(
    dbpath(url_pwd)$password,
    "p@ssw*rd"
  )

  # re-encoded when forming a URL
  expect_equal(
    format(dbpath(url_pwd)),
    url_pwd
  )

  # encoded in the print method or not if requested
  expect_snapshot(
    print(dbpath(url_pwd), hide_password = FALSE)
  )
  expect_snapshot(
    print(dbpath(url_pwd), hide_password = FALSE, url_encode = FALSE)
  )
})

test_that("dbpath url-decodes and encodes query parameters", {
  url_q <- "drv://user@host/db?foo=bar%20and%20baz"

  # decoded on ingest
  expect_equal(
    dbpath(url_q)$params$foo,
    "bar and baz"
  )

  # re-encoded when forming a URL
  expect_equal(
    format(dbpath(url_q)),
    url_q
  )

  # encoded in the print method or not if requested
  expect_snapshot(
    print(dbpath(url_q))
  )
  expect_snapshot(
    print(dbpath(url_q), url_encode = FALSE)
  )
})
