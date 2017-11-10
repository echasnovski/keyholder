#' Set keys
#'
#' Key is a vector which goal is to provide information about rows in reference
#' data frame. Its length should always be equal to number of rows in
#' data frame. Keys are stored as [tibble][tibble::lst] in attribute `"keys"`
#' and so one data frame can have multiple keys. Data frame with keys is
#' implemented as class [keyed_df][keyed-df].
#'
#' @param .tbl Reference data frame .
#' @param value Values of keys (converted to [tibble][tibble::as_tibble]).
#' @param ... Variables to be used as keys defined in similar fashion as in
#'   [dplyr::select()].
#' @param .add Whether to add keys to (possibly) existing ones. If `FALSE` keys
#'   will be overridden.
#' @param .exclude Whether to exclude key variables from `.tbl`.
#'
#' @details `key_by` ignores grouping when creating keys. Also if `.add == TRUE`
#' and names of some added keys match the names of existing keys the new ones
#' will override the old ones.
#'
#' Value for `keys<-` should not be `NULL` because it is converted to tibble
#' with zero rows. To remove keys use `unkey()`, [remove_keys()] or
#' [restore_keys()]. `assign_keys` is a more suitable for piping wrapper for
#' `keys<-`.
#'
#' @examples df <- dplyr::as_tibble(mtcars)
#'
#' # Value is converted to tibble
#' keys(df) <- 1:nrow(df)
#'
#' # This will throw an error
#' \dontrun{
#' keys(df) <- 1:10
#' }
#'
#' # Use 'vs' and 'am' as keys
#' df %>% key_by(vs, am)
#'
#' df %>% key_by(vs, am, .exclude = TRUE)
#'
#' df %>% key_by(vs) %>% key_by(am, .add = TRUE, .exclude = TRUE)
#'
#' # Override keys
#' df %>% key_by(vs, am) %>% dplyr::mutate(vs = 1) %>%
#'   key_by(gear, vs, .add = TRUE)
#'
#' # Use select helpers
#' df %>% key_by(dplyr::one_of(c("vs", "am")))
#'
#' df %>% key_by(dplyr::everything())
#'
#' @seealso [Get keys][keys-get], [Manipulate keys][keys-manipulate]
#'
#' [Scoped key_by()][key-by-scoped]
#'
#' @name keys-set
NULL

#' @rdname keys-set
#' @export
`keys<-` <- function(.tbl, value) {
  value <- as_tibble(value)

  if (!isTRUE(nrow(value) == nrow(.tbl))) {
    stop("Keys object should have the same number of rows as data.")
  }

  attr(.tbl, "keys") <- value

  add_class_cond(.tbl, "keyed_df")
}

#' @rdname keys-set
#' @export
assign_keys <- function(.tbl, value) {
  keys(.tbl) <- value

  .tbl
}

#' @rdname keys-set
#' @export
key_by <- function(.tbl, ..., .add = FALSE, .exclude = FALSE) {
  UseMethod("key_by")
}

#' @export
key_by.default <- function(.tbl, ..., .add = FALSE, .exclude = FALSE) {
  key_by_impl(.tbl = .tbl, .select_f = select, ...,
              .add = .add, .exclude = .exclude)
}

key_by_impl <- function(.tbl, .select_f, ..., .add = FALSE, .exclude = FALSE) {
  if (rlang::dots_n(...) == 0) {
    return(.tbl)
  }

  tbl_keys <- keys(.tbl)
  cur_keys <- .tbl %>%
    # Keys should not have keys
    unkey() %>%
    # Keys should not be grouped
    ungroup() %>%
    .select_f(...) %>%
    as_tibble()

  if (.add) {
    keys(.tbl) <- assign_tbl(tbl_keys, cur_keys)
  } else {
    keys(.tbl) <- cur_keys
  }

  if (.exclude) {
    .tbl <- diff_tbl(.tbl, cur_keys)
  }

  .tbl
}

#' @rdname keys-set
#' @export
unkey <- function(.tbl) {
  UseMethod("unkey")
}

#' @export
unkey.default <- function(.tbl) {
  attr(.tbl, "keys") <- NULL

  .tbl
}

#' @export
unkey.keyed_df <- function(.tbl) {
  .tbl <- remove_class(.tbl)

  NextMethod()
}
