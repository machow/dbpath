# port of # https://github.com/sqlalchemy/sqlalchemy/blob/b21a03316ff35ea86405f07d70fa1a2de7a01378/lib/sqlalchemy/engine/url.py#L716

#' S4 compatible class for dbpath
#' @rdname unique
#' @importFrom methods setOldClass setMethod
setOldClass("dbpath")

#' Produce an ast or parse graph of an expression
#'
#' @param url a database url
#' @return A dbpath object
#' @examples
#' dbpath("postgresql+psycopg2://some_user:some_pass@localhost:5432/some_db")
#'
#' @export
dbpath <- function(url) {
  stopifnot(length(url) == 1)

  res <- .parse_rfc1738_args(url)

  starts <- attr(res, "capture.start")
  lens <- attr(res, "capture.length")

  parsed_url <- substring(url, starts, starts + lens - 1)
  names(parsed_url) <-colnames(starts)

  if (parsed_url["ipv6host"] != "") {
    stop("TODO: ip v6 format not currently supported.")
  }

  structure(parsed_url, class = "dbpath")
}

#' @method tbl dbpath
#' @export
#' @importFrom dplyr tbl
tbl.dbpath <- function(x, ...) {
  dplyr::tbl(DBI::dbConnect(x, ...))
}


#' dbConnect method for dbpath
#'
#' @docType methods
#' @name dbConnect-dbpath
#' @rdname dbConnect-dbpath
#' @aliases dbConnect-dbpath dbConnect,dbpath-method
#' @method dbConnect dbpath
#'
#' @param drv a driver instance
#' @param ... extra arguments
#' @export
#' @importFrom DBI dbConnect
setMethod("dbConnect", "dbpath", function(drv, ...) {
  driver <- get_driver(get_driver_name(drv["name"]))
  DBI::dbConnect(
    driver(),
    user = drv[["username"]],
    password = drv[["password"]],
    host = drv[["ipv4host"]],
    port = drv[["port"]],
    dbname = drv[["database"]],
    ...
  )
})

#' @method print dbpath
#' @param x an item to print
#' @param hide_password replace password with '****'
#' @param ... extra arguments
#' @export
print.dbpath <- function(x, hide_password = TRUE, ...) {
  # name, username, password, ipv4host, port, database
  print(
    paste0(
      x["name"], "://",
      x["username"], ":", if (hide_password) "****" else x["password"], "@",
      x["ipv4host"],
      if (x["port"] != "") ":" else "", x["port"],
      if (x["database"] != "") "/" else "", x["database"]
    )
  )
}

.parse_rfc1738_args <- function(name) {
  pattern <-
    regexpr("(?x)
            (?<name>[\\w\\+]+)://
            (?:
               (?<username>[^:/]*)
               (?::(?<password>.*))?
            @)?
            (?:
                (?:
                    \\[(?<ipv6host>[^/]+)\\] |
                    (?<ipv4host>[^/:]+)
                )?
                (?::(?<port>[^/]*))?
            )?
            (?:/(?<database>.*))?
            ",
            name,
            perl = TRUE,
    )
  pattern
}


.rfc_1738_quote <- function(text) {
  utils::URLencode(text)
}


.rfc_1738_unquote <- function(text) {
  utils::URLdecode(text)
}
