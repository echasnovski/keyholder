#' Get keys
#'
#' Functions for getting information about keys.
#'
#' @param .tbl Reference data frame.
#'
#' @return `keys()` always returns a [tibble][tibble::lst] of keys. In case of
#'   no keys it returns a tibble with number of rows as in `.tbl` and zero
#'   columns. `raw_keys()` is just a wrapper for `attr(.tbl, "keys")`.
#'   To know whether `.tbl` has keys use `has_keys()`.
#'
#' @examples keys(mtcars)
#'
#' raw_keys(mtcars)
#'
#' has_keys(mtcars)
#'
#' df <- key_by(mtcars, vs, am)
#' keys(df)
#'
#' has_keys(df)
#'
#' @seealso [Set keys][keys-set], [Manipulate keys][keys-manipulate]
#'
#' @name keys-get
NULL

#' @rdname keys-get
#' @export
keys <- function(.tbl) {
  keys_attr <- attr(.tbl, "keys")

  if (is.null(keys_attr)) {
    tibble(logical(nrow(.tbl)))[-1]
  } else {
    as_tibble(keys_attr)
  }
}

#' @rdname keys-get
#' @export
raw_keys <- function(.tbl) {
  attr(.tbl, "keys")
}

#' @rdname keys-get
#' @export
has_keys <- function(.tbl) {
  !is.null(attr(.tbl, "keys"))
}
