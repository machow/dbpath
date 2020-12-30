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
    con <- DBI::dbConnect(dbpath(conn_str))
    DBI::dbDisconnect(con)
    testthat::expect_s4_class(con, "DBIConnection")
  })
}
