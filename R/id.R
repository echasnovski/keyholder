#' Add id column and key
#'
#' Functions for creating id column and key.
#'
#' @param .tbl Reference data frame.
#' @param x Character vector of names.
#' @param .add,.exclude Parameters for [key_by()].
#'
#' @details `use_id()` [assigns][keys-set] as keys a tibble with column '.id'
#'   and row numbers of `.tbl` as values.
#'
#' `compute_id_name()` computes the name which is different from every
#' element in `x` by the following algorithm: if '.id' is not present in `x` it
#' is returned; if taken - '.id1' is checked; if taken - '.id11' is checked and
#' so on.
#'
#' `add_id()` creates a column with unique name (computed with
#' `compute_id_name()`) and row numbers as values (grouping is ignored). After
#' that puts it as first column.
#'
#' `key_by_id()` is similar to `add_id()`: it creates a column with unique name
#' and row numbers as values (grouping is ignored) and calls [key_by()] function
#' to use this column as key. If `.add` is `FALSE` unique name is computed based
#' on `.tbl` column names; if `TRUE` then based on `.tbl` and its keys column
#' names.
#'
#' @examples
#' mtcars %>% use_id()
#'
#' mtcars %>% add_id()
#'
#' mtcars %>% key_by_id(.exclude = TRUE)
#'
#' @name keyholder-id
NULL

#' @rdname keyholder-id
#' @export
use_id <- function(.tbl) {
  assign_keys(.tbl, tibble(.id = seq_len(nrow(.tbl))))
}

#' @rdname keyholder-id
#' @export
compute_id_name <- function(x) {
  is_id <- grepl(pattern = "^\\.id[1]*$", x = as.character(x))

  if (sum(is_id) == 0) {
    return(".id")
  } else {
    n_ones <- nchar(x[is_id]) - 3
    marker <- c(rep(TRUE, (max(n_ones) + 1)), TRUE)
    marker[n_ones + 1] <- FALSE
    id_extra <- paste0(rep("1", which(marker)[1] - 1), collapse = "")

    return(paste0(".id", id_extra))
  }
}

#' @rdname keyholder-id
#' @export
add_id <- function(.tbl) {
  id_name <- compute_id_name(names(.tbl))

  .tbl[[id_name]] <- seq_len(nrow(.tbl))
  .tbl <- select(.tbl, rlang::UQ(rlang::sym(id_name)), everything())

  .tbl
}

#' @rdname keyholder-id
#' @export
key_by_id <- function(.tbl, .add = FALSE, .exclude = FALSE) {
  if (.add) {
    id_name <- compute_id_name(c(colnames(.tbl), colnames(keys(.tbl))))
  } else {
    id_name <- compute_id_name(colnames(.tbl))
  }

  .tbl[[id_name]] <- seq_len(nrow(.tbl))
  .tbl <- select(.tbl, rlang::UQ(rlang::sym(id_name)), everything())

  .tbl %>%
    key_by(rlang::UQ(rlang::sym(id_name)), .add = .add, .exclude = .exclude)
}
