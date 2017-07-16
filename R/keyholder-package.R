#' keyholder: store data about rows
#'
#' `keyholder` offers a set of tools for storing information about rows of data
#' frame like objects. The common use cases are:
#' - track rows of data frame without changing it.
#' - store columns for future restoring in data frame.
#' - hide columns for convenient use of [dplyr][dplyr::scoped]'s *_if scoped
#'   variants of verbs.
#'
#' To learn more about `keyholder`:
#' - Browse vignettes with `browseVignettes(package = "keyholder")`.
#' - Look how to [set keys][keys-set].
#' - Look at the list of [supported functions][keyholder-supported-funs].
#'
#' @import dplyr
"_PACKAGE"


#' Supported functions
#'
#' `keyholder` supports the following functions:
#' - Base subsetting with \link{[}.
#' - `dplyr` [one table verbs][keyed-df-one-tbl].
#' - `dplyr` [two table verbs][keyed-df-two-tbl].
#'
#' @name keyholder-supported-funs
NULL
