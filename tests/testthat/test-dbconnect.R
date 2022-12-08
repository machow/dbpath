# NOTE: by default mysql and mariadb assume you are using a local socket w/ localhost
# and only allow remote connections to the root user by default.
# see https://github.com/docker-library/mariadb/issues/269

DB_STRINGS <- c(
  postgres = "postgresql+RPostgres://postgres:some_password@localhost:5441/postgres",
  mysql = "mysql+RMariaDB://root:some_password@127.0.0.1:5442/some_db",
  mysql_no_driver = "mysql://root:some_password@127.0.0.1:5442/some_db"
)

for (ii in 1:length(DB_STRINGS)) {
  name <- names(DB_STRINGS)[ii]
  conn_str <- DB_STRINGS[ii]

  test_that(paste0("database connection works: ", name), {
    if (name == "postgres") {
      skip_if_not_installed("RPostgres")
    } else {
      skip_if_not_installed("RMariaDB")
    }

    con <- DBI::dbConnect(dbpath(conn_str))
    DBI::dbDisconnect(con)
    expect_s4_class(con, "DBIConnection")
  })
}

test_that("dbpath_params works with odbc", {
  skip_if_not_installed("odbc")

  url <- dbpath("snowflake+odbc://some_user:some_password@localhost/dbname?warehouse=mywarehouse")
  params <- dbpath_params(odbc::odbc(), url)

  expect_equal(params$driver, "snowflake")
  expect_equal(params$warehouse, "mywarehouse")

  expect_s4_class(params$drv, "OdbcDriver")

  params2 <- dbpath_params(url)
  expect_equal(params, params2)
})
