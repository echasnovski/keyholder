#' One-table verbs from dplyr for keyed_df
#'
#' Defined methods for [dplyr] generic single table functions. Most of them
#' preserve 'keyed_df' class and 'keys' attribute (excluding `summarise` with
#' scoped variants, `distinct` and `do` which remove them). Also these methods
#' modify rows in keys according to the rows modification in reference
#' data frame (if any).
#'
#' @param .data,data,x A keyed object.
#' @param ... Appropriate arguments for functions.
#' @param .keep_all Parameter for [dplyr::distinct].
#' @param .by_group Parameter for [dplyr::arrange].
#'
#' @details [dplyr::transmute()] is supported implicitly with [dplyr::mutate()]
#' support.
#'
#' [dplyr::rowwise()] is not supposed to be generic in `dplyr`. Use
#' `rowwise.keyed_df` directly.
#'
#' All [scoped][dplyr::scoped] variants of present functions are also supported.
#'
#' @examples mtcars %>% key_by(vs, am) %>% dplyr::mutate(gear = 1)
#'
#' @seealso [Two-table verbs][keyed-df-two-tbl]
#'
#' @name keyed-df-one-tbl
NULL

#' @rdname keyed-df-one-tbl
#' @export
select.keyed_df <- function(.data, ...) {
  next_method_keys(.data, select, ...)
}

#' @rdname keyed-df-one-tbl
#' @export
rename.keyed_df <- function(.data, ...) {
  next_method_keys(.data, rename, ...)
}

#' @rdname keyed-df-one-tbl
#' @export
mutate.keyed_df <- function(.data, ...) {
  next_method_keys(.data, mutate, ...)
}

#' @rdname keyed-df-one-tbl
#' @export
transmute.keyed_df <- function(.data, ...) {
  next_method_keys(.data, transmute, ...)
}

#' @rdname keyed-df-one-tbl
#' @export
summarise.keyed_df <- function(.data, ...) {
  summarise(unkey(.data), ...)
}

#' @rdname keyed-df-one-tbl
#' @export
group_by.keyed_df <- function(.data, ...) {
  next_method_keys(.data, group_by, ...)
}

#' @rdname keyed-df-one-tbl
#' @export
ungroup.keyed_df <- function(x, ...) {
  next_method_keys(x, ungroup, ...)
}

# rowwise is not supposed to be generic in dplyr so use this function directly
#' @rdname keyed-df-one-tbl
#' @export
rowwise.keyed_df <- function(data, ...) {
  next_method_keys(data, rowwise)
}

#' @rdname keyed-df-one-tbl
#' @export
distinct.keyed_df <- function(.data, ..., .keep_all = FALSE) {
  distinct(unkey(.data), ..., .keep_all = .keep_all)
}

#' @rdname keyed-df-one-tbl
#' @export
do.keyed_df <- function(.data, ...) {
  do(unkey(.data), ...)
}

#' @rdname keyed-df-one-tbl
#' @export
arrange.keyed_df <- function(.data, ..., .by_group = FALSE) {
  if (is_grouped_df(.data)) {
    next_method_keys_track(.data, arrange, ..., .by_group = .by_group)
  } else {
    next_method_keys_track(.data, arrange, ...)
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
slice.keyed_df <- function(.data, ...) {
  next_method_keys_track(.data, slice, ...)
}

next_method_keys <- function(.data, .f, ...) {
  # If attr(.data, "keys") is NULL it is replaced with 0-column tibble
  .f(unkey(.data), ...) %>% assign_keys(keys(.data))
}

next_method_keys_track <- function(.data, .f, ...) {
  dots_names <- names(quos(...))
  id_name <- compute_id_name(c(names(.data), dots_names))

  y <- unkey(.data)
  y[[id_name]] <- 1:nrow(y)
  res <- .f(y, ...)

  # Removing column with name in `id_name` before assigning keys is important
  # because `[[` operation on `res` might remove `keyed_df` class that should be
  # added during `keys<-()` execution.
  id_vals <- res[[id_name]]
  res[[id_name]] <- NULL
  keys(res) <- keys(.data)[id_vals, ]

  res
}
