#' One-table verbs from dplyr for keyed_df
#'
#' Defined methods for [dplyr] generic single table functions. Most of them
#' preserve 'keyed_df' class and 'keys' attribute (excluding `summarise` with
#' scoped variants, `distinct` and `do` which remove them). Also these methods
#' modify rows in keys according to the rows modification in reference
#' data.frame (if any).
#'
#' @param .tbl,.data A keyed object.
#' @param ... Appropriate arguments for functions.
#' @param add Parameter for [dplyr::group_by].
#' @param .keep_all Parameter for [dplyr::distinct].
#' @param .by_group Parameter for [dplyr::arrange].
#'
#' @details [dplyr::transmute()] is supported implicitly with [dplyr::mutate()]
#' support.
#'
#' [dplyr::rowwise()] as for `dplyr` version 0.7.1 is not generic. Use
#' `rowwise.keyed_df` directly.
#'
#' All [scoped][dplyr::scoped] variants of present functions are also supported.
#'
#' @examples mtcars %>% key_by(vs, am) %>% dplyr::mutate(gear = 1)
#'
#' @name keyed-df-one-tbl
NULL

#' @rdname keyed-df-one-tbl
#' @export
select.keyed_df <- function(.tbl, ...) {
  next_method_keys(.tbl, select, ...)
}

#' @rdname keyed-df-one-tbl
#' @export
rename.keyed_df <- function(.tbl, ...) {
  next_method_keys(.tbl, rename, ...)
}

#' @rdname keyed-df-one-tbl
#' @export
mutate.keyed_df <- function(.tbl, ...) {
  next_method_keys(.tbl, mutate, ...)
}

#' @rdname keyed-df-one-tbl
#' @export
summarise.keyed_df <- function(.tbl, ...) {
  unkey(NextMethod())
}

#' @rdname keyed-df-one-tbl
#' @export
group_by.keyed_df <- function(.tbl, ..., add = FALSE) {
  next_method_keys(.tbl, group_by, ..., add = add)
}

#' @rdname keyed-df-one-tbl
#' @export
ungroup.keyed_df <- function(.tbl, ...) {
  next_method_keys(.tbl, ungroup, ...)
}

# rowwise is not generic in dplyr 0.7.1 so use this function directly.
#' @rdname keyed-df-one-tbl
#' @export
rowwise.keyed_df <- function(.tbl) {
  next_method_keys(.tbl, rowwise)
}

#' @rdname keyed-df-one-tbl
#' @export
distinct.keyed_df <- function(.tbl, ..., .keep_all = FALSE) {
  unkey(NextMethod())
}

#' @rdname keyed-df-one-tbl
#' @export
do.keyed_df <- function(.tbl, ...) {
  unkey(NextMethod())
}

#' @rdname keyed-df-one-tbl
#' @export
arrange.keyed_df <- function(.tbl, ..., .by_group = FALSE) {
  if (is_grouped_df(.tbl)) {
    next_method_keys_track(.tbl, arrange, ..., .by_group = .by_group)
  } else {
    next_method_keys_track(.tbl, arrange, ...)
  }
}

# To ensure `filter` from `dplyr` (and not from `stats`)
#' @export
dplyr::filter

#' @rdname keyed-df-one-tbl
#' @export
filter.keyed_df <- function(.data, ...) {
  next_method_keys_track(.data, filter, ...)
}

#' @rdname keyed-df-one-tbl
#' @export
slice.keyed_df <- function(.tbl, ...) {
  next_method_keys_track(.tbl, slice, ...)
}

next_method_keys <- function(.tbl, .f, ...) {
  # If attr(.tbl, "keys") is NULL it is replaced with 0-column tibble
  .f(unkey(.tbl), ...) %>% assign_keys(keys(.tbl))
}

next_method_keys_track <- function(.tbl, .f, ...) {
  dots_names <- names(quos(...))
  id_name <- compute_id_name(c(names(.tbl), dots_names))

  y <- unkey(.tbl)
  y[[id_name]] <- 1:nrow(y)
  res <- .f(y, ...)

  keys(res) <- keys(.tbl)[res[[id_name]], ]
  res[[id_name]] <- NULL

  res
}