simple_config <- function() {
  config <- character()
  list(
    get = function(name = NULL) if (is.null(name)) config else config[[name]],
    set = function(...) {
      args <- list(...)
      stopifnot(sapply(args, length) == 1)

      config[names(args)] <<- unlist(args)
    }
  )
}

import_from <- function(pkg, func_name) {
  # standard eval for pkg::func_name
  requireNamespace(pkg)
  function() get(func_name, loadNamespace(pkg))
}

get_dialect_name <- function(path) {
  strsplit(path[["name"]], "+", fixed = TRUE)[[1]][1]
}

get_driver_name <- function(path) {
  name <- path[["name"]]

  # e.g. "mysql:RMariaDB" to "RMariaDB"
  driver <- strsplit(name, "+", fixed = TRUE)[[1]][2]

  # name can take form like "mysql:"
  # in which case we fetch the default driver for that dialect
  if (is.na(driver)) {
    dialect <- get_dialect_name(path)
    driver <- dialect_defaults$get(dialect)
  }

  driver
}

get_driver <- function(driver_name) {
  # TODO: handle missing entries
  getter <- driver_registry$get(driver_name)
  getter()
}

#' configure default drivers for different dialects
#' @export
dbpath_params <- function (driver, ...) {
  UseMethod("dbpath_params", driver)
}


#' @export
dbpath_params.OdbcDriver <- function(driver, dbpath) {
  #name, username, password, ipv6hosts, ipv4hosts, port, database
  dialect <- get_dialect_name(dbpath)

  params <- list(
    drv = driver,
    driver = dialect,
    uid = dbpath[["username"]],
    pwd = dbpath[["password"]],
    server = dbpath[["host"]],
    database = dbpath[["database"]]
  )

  query_params <- dbpath[["params"]]
  safe_to_add <- !names(query_params) %in% names(params)

  c(params, query_params[safe_to_add])
}

#' @export
dbpath_params.dbpath <- function(path) {
  driver <- get_driver(get_driver_name(path))

  dbpath_params(driver(), path)
}

#' @export
dbpath_params.default <- function(driver, dbpath) {
  # works both with Postgres::PqDriver, RMariaDB::MariaDB
  # could make explicit implementations for them, and set default
  # to raise an error?
  list(
    drv = driver,
    user = dbpath[["username"]],
    password = dbpath[["password"]],
    host = dbpath[["host"]],
    port = dbpath[["port"]],
    dbname = dbpath[["database"]]
  )
}
