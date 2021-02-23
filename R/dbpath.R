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

  parsed_url <- as.list(substring(url, starts, starts + lens - 1))
  names(parsed_url) <-colnames(starts)

  if (parsed_url[["ipv4host"]] != "") {
    host <- parsed_url[["ipv4host"]]
  } else {
    host <- parsed_url[["ipv6host"]]
  }

  # drop the ip specific columns, to just have single host entry
  parsed_url <- parsed_url[!names(parsed_url) %in% c("ipv6host", "ipv4host")]
  parsed_url$host <- host

  if (parsed_url[["database"]] != "") {
    tokens <- strsplit(parsed_url[["database"]], "?", fixed = TRUE)[[1]]
    parsed_url[["database"]] <- tokens[1]

    if (length(tokens) > 1) {
      parsed_url[["params"]] <- .rfc_1738_parse_query(tokens[2])
    }
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
setMethod("dbConnect", "dbpath", function(drv) {
  params <- dbpath_params(drv)

  do.call(DBI::dbConnect, params)
})

#' print a dbpath object
#' @method print dbpath
#' @param x an item to print
#' @param hide_password replace password with '****'
#' @param ... extra arguments
#' @export
print.dbpath <- function(x, hide_password = TRUE, ...) {
  # name, username, password, ipv4host, port, database
  print(
    paste0(
      x[["name"]], "://",
      x[["username"]], ":", if (hide_password) "****" else x["password"], "@",
      x[["host"]],
      if (x[["port"]] != "") ":" else "", x["port"],
      if (x[["database"]] != "") "/" else "", x["database"]
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
  utils::URLencode(text, reserved = TRUE)
}


.rfc_1738_unquote <- function(text) {
  utils::URLdecode(text)
}

# this code was copied from httr's parse_query function
# https://github.com/r-lib/httr/blob/master/R/url-query.r
.rfc_1738_parse_query <- function(query) {
  query_args <- strsplit(query, "&")[[1]]

  # split each argument on first occurence of =
  # see https://stackoverflow.com/a/26247455/1144523
  params <- regmatches(query_args, regexpr("=", query_args), invert = TRUE)

  values <- vapply(
    params,
    function(par) .rfc_1738_unquote(par[2]),
    FUN.VALUE = character(1)
  )

  names(values) <- vapply(
    params,
    function(par) .rfc_1738_unquote(par[1]),
    FUN.VALUE = character(1)
  )

  as.list(values)
}
