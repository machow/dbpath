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

get_backend_name <- function(path) {
  strsplit(path["name"], "+", fixed = TRUE)[[1]][1]
}

get_driver_name <- function(path) {
  name <- path["name"]
  driver <- strsplit(name, "+", fixed = TRUE)[[1]][2]

  if (is.na(driver)) {
    dialect <- get_backend_name(name)
    driver <- driver_defaults[dialect]
  }

  driver
}

get_driver <- function(driver_name) {
  # TODO: handle missing entries
  getter <- driver_registry$get(driver_name)
  getter()
}
