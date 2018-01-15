# Scoped ------------------------------------------------------------------
#' Operate on a selection of keys
#'
#' [keyholder][keyholder-package] offers [scoped][dplyr::scoped] variants of the
#' following functions:
#' - [key_by()]. See [key_by_all()][key-by-scoped].
#' - [remove_keys()]. See [remove_keys_all()][remove-keys-scoped].
#' - [restore_keys()]. See [restore_keys_all()][restore-keys-scoped].
#' - [rename_keys()]. See [rename_keys_all()][rename-keys-scoped].
#'
#' @param .funs Parameter for [scoped][dplyr::scoped] functions.
#' @param .vars Parameter for [scoped][dplyr::scoped] functions.
#' @param .predicate Parameter for [scoped][dplyr::scoped] functions.
#' @param ... Parameter for [scoped][dplyr::scoped] functions.
#'
#' @seealso [Not scoped manipulation functions][keys-manipulate]
#'
#' [Not scoped key_by()][keys-set]
#'
#' @name keyholder-scoped
NULL


# Scoped key_by -----------------------------------------------------------
#' Key by selection of variables
#'
#' These functions perform keying by selection of variables using corresponding
#' [scoped variant][dplyr::select_all] of [select][dplyr::select]. Appropriate
#' data frame is selected with scoped function first, and then it is assigned
#' as keys.
#'
#' @inheritParams keyholder-scoped
#' @inheritParams keys-set
#'
#' @examples
#' mtcars %>% key_by_all(.funs = toupper)
#'
#' mtcars %>% key_by_if(rlang::is_integerish, toupper)
#'
#' mtcars %>% key_by_at(c("vs", "am"), toupper)
#'
#' @seealso [Not scoped key_by()][keys-set]
#'
#' @name key-by-scoped
NULL

#' @rdname key-by-scoped
#' @export
key_by_all <- function(.tbl, .funs = list(), ...,
                       .add = FALSE, .exclude = FALSE) {
  key_by_impl(.tbl = .tbl, .select_f = select_all,
              .funs = .funs, ...,
              .add = .add, .exclude = .exclude)
}

#' @rdname key-by-scoped
#' @export
key_by_if <- function(.tbl, .predicate, .funs = list(), ...,
                      .add = FALSE, .exclude = FALSE) {
  key_by_impl(.tbl = .tbl, .select_f = select_if,
              .predicate = .predicate, .funs = .funs, ...,
              .add = .add, .exclude = .exclude)
}

#' @rdname key-by-scoped
#' @export
key_by_at <- function(.tbl, .vars, .funs = list(), ...,
                      .add = FALSE, .exclude = FALSE) {
  key_by_impl(.tbl = .tbl, .select_f = select_at,
              .vars = .vars, .funs = .funs, ...,
              .add = .add, .exclude = .exclude)
}


# Scoped rename_keys ------------------------------------------------------
#' Remove selection of keys
#'
#' These functions remove selection of keys using corresponding
#' [scoped variant][dplyr::select_all] of [select][dplyr::select]. `.funs`
#' argument is removed because of its redundancy.
#'
#' @inheritParams keyholder-scoped
#' @inheritParams keys-manipulate
#'
#' @examples
#' df <- mtcars %>% dplyr::as_tibble() %>% key_by(vs, am, disp)
#' df %>% remove_keys_all()
#'
#' df %>% remove_keys_all(.unkey = TRUE)
#'
#' df %>% remove_keys_if(rlang::is_integerish)
#'
#' df %>% remove_keys_at(c("vs", "am"))
#'
#' @name remove-keys-scoped
NULL

#' @rdname remove-keys-scoped
#' @export
remove_keys_all <- function(.tbl, ..., .unkey = FALSE) {
  dots <- dots_remove_elements(..., ".funs")
  remove_keys_impl(.tbl = .tbl, .select_f = select_all,
                   .funs = list(), !!! dots, .unkey = .unkey)
}

#' @rdname remove-keys-scoped
#' @export
remove_keys_if <- function(.tbl, .predicate, ...,
                           .unkey = FALSE) {
  dots <- dots_remove_elements(..., ".funs")
  remove_keys_impl(.tbl = .tbl, .select_f = select_if,
                   .predicate = .predicate, .funs = list(),
                   !!! dots,
                   .unkey = .unkey)
}

#' @rdname remove-keys-scoped
#' @export
remove_keys_at <- function(.tbl, .vars, ...,
                           .unkey = FALSE) {
  dots <- dots_remove_elements(..., ".funs")
  remove_keys_impl(.tbl = .tbl, .select_f = select_at,
                   .vars = .vars, .funs = list(),
                   !!! dots,
                   .unkey = .unkey)
}


# Scoped restore_keys -----------------------------------------------------
#' Restore selection of keys
#'
#' These functions restore selection of keys using corresponding
#' [scoped variant][dplyr::select_all] of [select][dplyr::select]. `.funs`
#' argument can be used to rename some keys (without touching actual keys)
#' before restoring.
#'
#' @inheritParams keyholder-scoped
#' @inheritParams keys-manipulate
#'
#' @examples
#' df <- mtcars %>% dplyr::as_tibble() %>% key_by(vs, am, disp)
#' # Just restore all keys
#' df %>% restore_keys_all()
#'
#' # Restore all keys with renaming and without touching actual keys
#' df %>% restore_keys_all(.funs = toupper)
#'
#' # Restore with renaming and removing
#' df %>%
#'   restore_keys_all(.funs = toupper, .remove = TRUE)
#'
#' # Restore with renaming, removing and unkeying
#' df %>%
#'   restore_keys_all(.funs = toupper, .remove = TRUE, .unkey = TRUE)
#'
#' # Restore with renaming keys satisfying the predicate
#' df %>%
#'   restore_keys_if(rlang::is_integerish, .funs = toupper)
#'
#' # Restore with renaming specified keys
#' df %>%
#'   restore_keys_at(c("vs", "disp"), .funs = toupper)
#'
#' @name restore-keys-scoped
NULL

#' @rdname restore-keys-scoped
#' @export
restore_keys_all <- function(.tbl, .funs = list(), ...,
                             .remove = FALSE, .unkey = FALSE) {
  res <- restore_keys_impl(.tbl = .tbl, .select_f = select_all,
                           .funs = .funs, ...,
                           .remove = FALSE, .unkey = .unkey)
  if (.remove) {
    res <- res %>% remove_keys_all(..., .unkey = .unkey)
  }

  res
}

#' @rdname restore-keys-scoped
#' @export
restore_keys_if <- function(.tbl, .predicate, .funs = list(), ...,
                             .remove = FALSE, .unkey = FALSE) {
  res <- restore_keys_impl(.tbl = .tbl, .select_f = select_if,
                           .predicate = .predicate, .funs = .funs, ...,
                           .remove = FALSE, .unkey = .unkey)
  if (.remove) {
    res <- res %>% remove_keys_if(.predicate = .predicate, ...,
                                  .unkey = .unkey)
  }

  res
}

#' @rdname restore-keys-scoped
#' @export
restore_keys_at <- function(.tbl, .vars, .funs = list(), ...,
                             .remove = FALSE, .unkey = FALSE) {
  res <- restore_keys_impl(.tbl = .tbl, .select_f = select_at,
                           .vars = .vars, .funs = .funs, ...,
                           .remove = FALSE, .unkey = .unkey)
  if (.remove) {
    res <- res %>% remove_keys_at(.vars = .vars, ...,
                                  .unkey = .unkey)
  }

  res
}

# Scoped rename_keys ------------------------------------------------------
#' Rename selection of keys
#'
#' These functions rename selection of keys using corresponding
#' [scoped variant][dplyr::rename_all] of [rename][dplyr::rename].
#'
#' @inheritParams keyholder-scoped
#' @inheritParams keys-manipulate
#'
#' @name rename-keys-scoped
NULL

#' @rdname rename-keys-scoped
#' @export
rename_keys_all <- function(.tbl, .funs = list(), ...) {
  rename_keys_impl(.tbl = .tbl, .rename_f = rename_all,
                    .funs = .funs, ...)
}

#' @rdname rename-keys-scoped
#' @export
rename_keys_if <- function(.tbl, .predicate, .funs = list(), ...) {
  rename_keys_impl(.tbl = .tbl, .rename_f = rename_if,
                    .predicate = .predicate, .funs = .funs, ...)
}

#' @rdname rename-keys-scoped
#' @export
rename_keys_at <- function(.tbl, .vars, .funs = list(), ...) {
  rename_keys_impl(.tbl = .tbl, .rename_f = rename_at,
                    .vars = .vars, .funs = .funs, ...)
}
