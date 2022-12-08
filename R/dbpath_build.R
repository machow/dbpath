#' Build a dbpath object
#'
#' Builds a [dbpath()] object from its parts. All parts are optional other than
#' `dialect`. To create a database URL, use `format()` on the resulting `dbpath`
#' object.
#'
#' @examples
#' dbpath_build("postgres", host = "localhost", port = 5432, database = "money")
#'
#' @param dialect,driver The SQL database `dialect` and optional R `driver`
#'   package to use with this dialect.
#' @param username,password Optional username and password
#' @param host,port Optional host and port
#' @param database The name of the database
#' @param params A named list of query parameters or a query string. For
#'   example, either `list(foo = "bar", name = "value")` or
#'   `foo=bar&name=value`.
#'
#' @return A [dbpath()] object.
#'
#' @export
dbpath_build <- function(
  dialect,
  driver = NULL,
  username = NULL,
  password = NULL,
  host = NULL,
  port = NULL,
  database = NULL,
  params = NULL
) {
  assert_is_string(dialect)
  url <- dialect

  if (!is.null(driver)) {
    assert_is_string(driver)
    url <- paste0(url, "+", driver)
  }

  url <- paste0(url, "://")

  if (!is.null(username)) {
    assert_is_string(username)
    url <- paste0(url, username)
  }

  if (!is.null(password)) {
    assert_is_string(password)
    url <- paste0(url, ":", password)
  }

  url <- paste0(url, "@")

  if (!is.null(host)) {
    assert_is_string(host)
    url <- paste0(url, host)
  }

  if (!is.null(port)) {
    if (length(port) != 1) {
      stop("`port` must be length-1 string or integer.")
    }
    url <- paste0(url, ":", port)
  }

  if (!is.null(database)) {
    assert_is_string(database)
    url <- paste0(url, "/", database)
  }

  if (!is.null(params)) {
    params <- tryCatch(
      {
        assert_is_string(params)
        # if it is a string, then try to parse query
        query <- sub("^[?]", "", params)
        format_params(.rfc_1738_parse_query(query))
      },
      error = function(err) {
        # if not or if that fails, then it should be a list
        format_params(params)
      }
    )

    url <- paste0(url, params)
  }

  dbpath(url)
}
