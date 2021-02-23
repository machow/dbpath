# maps driver names to their class ----

#' configure hooks for instantiating drivers
#' @export
driver_registry <- simple_config()
driver_registry$set(
  RPostgres = import_from("RPostgres", "Postgres"),
  RMariaDB = import_from("RMariaDB", "MariaDB"),
  psycopg2 = import_from("RPostgres", "Postgres"),
  odbc = import_from("odbc", "odbc")
)

# maps dialects to drivers ----

#' configure default drivers for different dialects
#' @export
dialect_defaults <- simple_config()
dialect_defaults$set(
  postgresql = "RPostgres",
  mysql = "RMariaDB",
  mariadb = "RMariaDB",
  snowflake = "odbc"
)

