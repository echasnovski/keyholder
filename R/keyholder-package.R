#' keyholder: store data about rows
#'
#' `keyholder` offers a set of tools for storing information about rows of data
#' frame like objects. The common use cases are:
#' - track rows of data frame without changing it.
#' - store columns for future restoring in data frame.
#' - hide columns for convenient use of [dplyr][dplyr::scoped]'s *_if scoped
#'   variants of verbs.
#'
#' To learn more about `keyholder`, start with the vignette:
#' browseVignettes(package = "keyholder")
#'
#' @import dplyr
"_PACKAGE"
