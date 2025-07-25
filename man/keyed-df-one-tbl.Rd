% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/keyed-df-one-tbl.R
\name{keyed-df-one-tbl}
\alias{keyed-df-one-tbl}
\alias{select.keyed_df}
\alias{rename.keyed_df}
\alias{mutate.keyed_df}
\alias{transmute.keyed_df}
\alias{summarise.keyed_df}
\alias{group_by.keyed_df}
\alias{ungroup.keyed_df}
\alias{rowwise.keyed_df}
\alias{distinct.keyed_df}
\alias{do.keyed_df}
\alias{arrange.keyed_df}
\alias{filter.keyed_df}
\alias{slice.keyed_df}
\title{One-table verbs from dplyr for keyed_df}
\usage{
\method{select}{keyed_df}(.data, ...)

\method{rename}{keyed_df}(.data, ...)

\method{mutate}{keyed_df}(.data, ...)

\method{transmute}{keyed_df}(.data, ...)

\method{summarise}{keyed_df}(.data, ...)

\method{group_by}{keyed_df}(.data, ...)

\method{ungroup}{keyed_df}(x, ...)

\method{rowwise}{keyed_df}(data, ...)

\method{distinct}{keyed_df}(.data, ..., .keep_all = FALSE)

\method{do}{keyed_df}(.data, ...)

\method{arrange}{keyed_df}(.data, ..., .by_group = FALSE)

\method{filter}{keyed_df}(.data, ...)

\method{slice}{keyed_df}(.data, ...)
}
\arguments{
\item{.data, data, x}{A keyed object.}

\item{...}{Appropriate arguments for functions.}

\item{.keep_all}{Parameter for \link[dplyr:distinct]{dplyr::distinct}.}

\item{.by_group}{Parameter for \link[dplyr:arrange]{dplyr::arrange}.}
}
\description{
Defined methods for \code{dplyr} generic single table functions. Most of them
preserve 'keyed_df' class and 'keys' attribute (excluding \code{summarise} with
scoped variants, \code{distinct} and \code{do} which remove them). Also these methods
modify rows in keys according to the rows modification in reference
data frame (if any).
}
\details{
\code{\link[dplyr:transmute]{dplyr::transmute()}} is supported implicitly with \code{\link[dplyr:mutate]{dplyr::mutate()}}
support.

\code{\link[dplyr:rowwise]{dplyr::rowwise()}} is not supposed to be generic in \code{dplyr}. Use
\code{rowwise.keyed_df} directly.

All \link[dplyr:scoped]{scoped} variants of present functions are also supported.
}
\examples{
mtcars \%>\% key_by(vs, am) \%>\% dplyr::mutate(gear = 1)

}
\seealso{
\link[=keyed-df-two-tbl]{Two-table verbs}
}
