#' Manipulate keys
#'
#' Functions to manipulate [keys][keys-set].
#'
#' @param .tbl Reference data.frame .
#' @param ... Variables to be used for operations defined in similar fashion as
#'   in [dplyr::select()].
#' @param .unkey Whether to [unkey()] `.tbl` in case there are no keys left.
#' @param .remove Whether to remove keys after restoring.
#'
#' @details `remove_keys()` removes keys defined with `...`.
#'
#' `restore_keys()` transfers keys defined with `...` into `.tbl` and removes
#' them from `keys` if `.remove == TRUE`. If `.tbl` is grouped the following
#' happens:
#' - If restored keys don't contain grouping variables then groups don't change;
#' - If restored keys contain grouping variables then result will be regrouped
#' based on restored values. In other words restoring keys beats 'not-modifying'
#' grouping variables rule. It is made according to the ideology of keys: they
#' contain information about rows and by restoring you want it to be
#' available.
#'
#' `rename_keys()` renames columns in keys using [dplyr::rename()].
#'
#' @examples df <- mtcars %>% key_by(vs, am, .exclude = TRUE)
#' df %>% remove_keys(vs)
#' df %>% remove_keys(dplyr::everything())
#' df %>% remove_keys(dplyr::everything(), .unkey = TRUE)
#'
#' df %>% restore_keys(vs)
#' df %>% restore_keys(vs, .remove = TRUE)
#'
#' df %>% restore_keys(dplyr::everything(), .remove = TRUE)
#' df %>% restore_keys(dplyr::everything(), .remove = TRUE, .unkey = TRUE)
#'
#' # Restoring on grouped data frame
#' df_grouped <- df %>% dplyr::mutate(vs = 1) %>% dplyr::group_by(vs)
#' df_grouped %>% restore_keys(dplyr::everything())
#'
#' # Renaming
#' df %>% rename_keys(Vs = vs)
#'
#' @seealso [Get keys][keys-get], [Set keys][keys-set]
#'
#' @name keys-manipulate

#' @rdname keys-manipulate
#' @export
remove_keys <- function(.tbl, ..., .unkey = FALSE) {
  UseMethod("remove_keys")
}

#' @export
remove_keys.default <- function(.tbl, ..., .unkey = FALSE) {
  tbl_keys <- keys(.tbl)
  left_keys <- diff_tbl(tbl_keys, select(tbl_keys, ...))

  set_key_cond(.tbl, left_keys, .unkey)
}

#' @rdname keys-manipulate
#' @export
restore_keys <- function(.tbl, ..., .remove = FALSE, .unkey = FALSE) {
  UseMethod("restore_keys")
}

#' @export
restore_keys.default <- function(.tbl, ..., .remove = FALSE, .unkey = FALSE) {
  tbl_keys <- keys(.tbl)
  tbl_class <- class(.tbl)

  if (ncol(tbl_keys) == 0) {
    return(.tbl)
  }

  restored_keys <- select(tbl_keys, ...)
  if (.remove) {
    left_keys <- diff_tbl(tbl_keys, restored_keys)
  } else {
    left_keys <- tbl_keys
  }

  # Restoring keys beats 'not-modifying' grouping variables.
  tbl_groups <- groups(.tbl)

  .tbl %>%
    ungroup() %>%
    assign_tbl(restored_keys) %>%
    group_by(rlang::UQS(tbl_groups)) %>%
    `class<-`(tbl_class) %>%
    set_key_cond(left_keys, .unkey)
}

#' @rdname keys-manipulate
#' @export
rename_keys <- function(.tbl, ...) {
  UseMethod("rename_keys")
}

#' @export
rename_keys.default <- function(.tbl, ...) {
  if (has_keys(.tbl)) {
    keys(.tbl) <- rename(keys(.tbl), ...)
  }

  .tbl
}

set_key_cond <- function(.tbl, .key, .unkey) {
  if (.unkey && (ncol(.key) == 0)) {
    .tbl <- unkey(.tbl)
  } else {
    keys(.tbl) <- .key
  }

  .tbl
}