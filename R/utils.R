
assert_is_string <- function(x) {
  name <- deparse(substitute(x))
  if (!is.character(x) || length(x) != 1 || identical(x, NA_character_)) {
    stop("`", name, "` must be a string of length 1.")
  }
}

is_not_empty <- function(x) {
  if (is.null(x)) return(FALSE)
  if (is.character(x) && !any(nzchar(x))) return(FALSE)
  TRUE
}

url_encode <- function(x) {
  utils::URLencode(x, reserved = TRUE)
}
