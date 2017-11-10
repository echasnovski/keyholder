#' Keyed object
#'
#' Utility functions for keyed objects which are implemented with class
#' `keyed_df`. Keyed object should be a data frame which inherits from
#' `keyed_df` and contains a data frame of [keys][keys-set] in attribute 'keys'.
#'
#' @param .tbl Object to check.
#' @param x Object to print or extract elements.
#' @param ... Further arguments passed to or from other methods.
#' @param i,j Arguments for \code{\link{[}}.
#'
#' @examples is_keyed_df(mtcars)
#'
#' mtcars %>% key_by(vs) %>% is_keyed_df
#'
#' # Not valid keyed_df
#' df <- mtcars
#' class(df) <- c("keyed_df", "data.frame")
#' is_keyed_df(df)
#'
#' @name keyed-df
NULL

#' @rdname keyed-df
#' @export
is_keyed_df <- function(.tbl) {
  keys_attr <- attr(.tbl, "keys")

  inherits(.tbl, "keyed_df") &&
    inherits(.tbl, "data.frame") &&
    inherits(keys_attr, "data.frame") &&
    isTRUE(nrow(keys_attr) == nrow(.tbl))
}

#' @rdname keyed-df
#' @export
is.keyed_df <- is_keyed_df

#' @rdname keyed-df
#' @export
print.keyed_df <- function(x, ...) {
  cat("# A keyed object. Keys: ")
  x_keys <- keys(x)

  if (ncol(x_keys) == 0) {
    cat("there are no keys.\n")
  } else {
    cat(paste0(names(x_keys), collapse = ", "), "\n")
  }

  NextMethod()
}

#' @rdname keyed-df
#' @export
`[.keyed_df` <- function(x, i, j, ...) {
  y <- NextMethod()

  if (!missing(i)) {
    keys(y) <- keys(x)[i, , drop = FALSE]
  } else {
    keys(y) <- keys(x)
  }

  class(y) <- class(x)

  y
}
