#' Two-table verbs from dplyr for keyed_df
#'
#' Defined methods for [dplyr] generic [join][dplyr::join] functions. All of
#' them preserve 'keyed_df' class and 'keys' attribute __of the first
#' argument__. Also these methods modify rows in keys according to the rows
#' modification in first argument (if any).
#'
#' @param x,y,by,copy,suffix,... Parameters for [join][dplyr::join] functions.
#'
#' @examples
#'
#' dplyr::band_members %>% key_by(band) %>%
#'   dplyr::semi_join(dplyr::band_instruments, by = "name") %>%
#'   keys()
#'
#' @seealso [One-table verbs][keyed-df-one-tbl]
#'
#' @name keyed-df-two-tbl
NULL

#' @rdname keyed-df-two-tbl
#' @export
inner_join.keyed_df <- function(x, y, by = NULL, copy = FALSE,
                                suffix = c(".x", ".y"), ...) {
  next_method_keys_two_tbl(
    x, y, inner_join,
    by = by, copy = copy, suffix = suffix, ...
  )
}

#' @rdname keyed-df-two-tbl
#' @export
left_join.keyed_df <- function(x, y, by = NULL, copy = FALSE,
                               suffix = c(".x", ".y"), ...) {
  next_method_keys_two_tbl(
    x, y, left_join,
    by = by, copy = copy, suffix = suffix, ...
  )
}

#' @rdname keyed-df-two-tbl
#' @export
right_join.keyed_df <- function(x, y, by = NULL, copy = FALSE,
                                suffix = c(".x", ".y"), ...) {
  next_method_keys_two_tbl(
    x, y, right_join,
    by = by, copy = copy, suffix = suffix, ...
  )
}

#' @rdname keyed-df-two-tbl
#' @export
full_join.keyed_df <- function(x, y, by = NULL, copy = FALSE,
                               suffix = c(".x", ".y"), ...) {
  next_method_keys_two_tbl(
    x, y, full_join,
    by = by, copy = copy, suffix = suffix, ...
  )
}

#' @rdname keyed-df-two-tbl
#' @export
semi_join.keyed_df <- function(x, y, by = NULL, copy = FALSE, ...) {
  next_method_keys_two_tbl(
    x, y, semi_join,
    by = by, copy = copy, ...
  )
}

#' @rdname keyed-df-two-tbl
#' @export
anti_join.keyed_df <- function(x, y, by = NULL, copy = FALSE, ...) {
  next_method_keys_two_tbl(
    x, y, anti_join,
    by = by, copy = copy, ...
  )
}

next_method_keys_two_tbl <- function(.tbl_1, .tbl_2, .f, ...) {
  id_name <- compute_id_name(c(names(.tbl_1), names(.tbl_2)))

  y_1 <- unkey(.tbl_1)
  y_1[[id_name]] <- 1:nrow(y_1)
  res <- .f(y_1, unkey(.tbl_2), ...)

  # Removing column with name in `id_name` before assigning keys is important
  # because `[[` operation on `res` might remove `keyed_df` class that should be
  # added during `keys<-()` execution.
  id_vals <- res[[id_name]]
  res[[id_name]] <- NULL
  keys(res) <- keys(.tbl_1)[id_vals, ]

  res
}
