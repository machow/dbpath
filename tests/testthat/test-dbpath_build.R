test_that("dbpath_build() works", {
  db_path_full <-
    dbpath_build(
      dialect = "dialect",
      driver = "driver",
      username = "username",
      password = "password",
      host = "host",
      port = 1234,
      database = "database"
    )

  expect_equal(
    db_path_full,
    dbpath("dialect+driver://username:password@host:1234/database")
  )

  expect_equal(
    format(db_path_full),
    "dialect+driver://username:password@host:1234/database"
  )

  db_path_params <-
    dbpath_build(
      dialect = "dialect",
      username = "username",
      host = "host",
      port = 1234,
      database = "database",
      params = list(pwd = "open", token = "sesame")
    )

  expect_equal(
    db_path_params,
    dbpath("dialect://username@host:1234/database?pwd=open&token=sesame")
  )

  expect_equal(
    format(db_path_params),
    "dialect://username@host:1234/database?pwd=open&token=sesame"
  )

  expect_equal(
    dbpath_build("a", "b", "c", "at@", "d"),
    dbpath("a+b://c:at@@d")
  )

  expect_equal(
    dbpath_build("dialect", port = "1234"),
    dbpath_build("dialect", port = 1234)
  )

  expect_equal(
    dbpath_build("dialect", host = "localhost", port = 1234, params = list(foo = "bar")),
    dbpath_build("dialect", host = "localhost", port = 1234, params = "foo=bar")
  )

  expect_equal(
    dbpath_build("dialect", host = "localhost", port = 1234, params = "?foo=bar"),
    dbpath_build("dialect", host = "localhost", port = 1234, params = "foo=bar")
  )
})

test_that("dbpath_build() round-trips through parsing", {
  path_full <- "dialect+driver://username:password@host:1234/database"
  expect_equal(
    .parse_rfc1738_args(
      format(
        dbpath_build("dialect", "driver", "username", "password", "host", 1234, "database")
      )
    ),
    .parse_rfc1738_args(path_full)
  )

  path_partial <- "dialect://:pwd@:1234/db"
  expect_equal(
    .parse_rfc1738_args(
      format(
        dbpath_build("dialect", password = "pwd", port = 1234, database = "db")
      )
    ),
    .parse_rfc1738_args(path_partial)
  )
})

test_that("dbpath_build() throws errors on bad input", {
  expect_error(
    dbpath_build(c("postgres", "RPostgres"))
  )

  expect_error(
    dbpath_build("driver", username = 123456)
  )

  expect_error(
    dbpath_build("driver", username = NA_character_)
  )

  expect_error(
    dbpath_build("driver", params = c("foo", "bar"))
  )
})

test_that("dbpath_build() url-encodes passwords and query params", {
  url_exp <- "drv://user:p%40ssw%2Ard@host/db?foo=bar%20and%20baz"
  expect_equal(
    format(
      dbpath_build(
        "drv",
        username = "user",
        password = "p@ssw*rd",
        host = "host",
        database = "db",
        params = list(foo = "bar and baz")
      )
    ),
    url_exp
  )

  # it also doesn't re-encode previously encoded values
  expect_equal(
    format(
      dbpath_build(
        "drv",
        username = "user",
        password = url_encode("p@ssw*rd"),
        host = "host",
        database = "db",
        params = list(foo = url_encode("bar and baz"))
      )
    ),
    url_exp
  )
})
