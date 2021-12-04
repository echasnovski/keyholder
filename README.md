
# keyholder

<!-- badges: start -->

[![Travis-CI Build
Status](https://travis-ci.org/echasnovski/keyholder.svg?branch=master)](https://travis-ci.org/echasnovski/keyholder)
[![R build
status](https://github.com/echasnovski/keyholder/workflows/R-CMD-check/badge.svg)](https://github.com/echasnovski/keyholder/actions)
[![Coverage
Status](https://codecov.io/gh/echasnovski/keyholder/graph/badge.svg)](https://codecov.io/github/echasnovski/keyholder?branch=master)
[![CRAN](https://www.r-pkg.org/badges/version/keyholder?color=blue)](https://cran.r-project.org/package=keyholder)
[![Dependencies](https://tinyverse.netlify.com/badge/keyholder)](https://CRAN.R-project.org/package=keyholder)
[![Downloads](http://cranlogs.r-pkg.org/badges/keyholder)](https://cran.r-project.org/package=keyholder)
<!-- badges: end -->

`keyholder` is a package for storing information (*keys*) about rows of
data frame like objects. The common use cases are to track rows of data
without modifying it and to backup and restore information about rows.
This is done with creating a class **keyed\_df** which has special
attribute “keys”. Keys are updated according to changes in rows of
reference data frame.

`keyholder` is designed to work tightly with
[dplyr](https://dplyr.tidyverse.org/) package. All its one- and
two-table verbs update keys properly.

## Installation

You can install current stable version from CRAN with:

``` r
install.packages("keyholder")
```

Also you can install development version from github with:

``` r
# install.packages("devtools")
devtools::install_github("echasnovski/keyholder")
```

## Usage

`keyholder` provides a set of functions to work with keys:

-   Set keys with `assign_keys()` and `key_by()`.
-   Get all keys with `keys()`. Get one specific key with `pull_key()`.
-   Restore information stored in certain keys with `restore_keys()` and
    its scoped variants (`*_all()`, `*_if()` and `*_at()`).
-   Rename certain keys with `rename_keys()` and its scoped variants.
-   Remove certain keys with `remove_keys()` and its scoped variants.
    Completely unkey object with `unkey()`.
-   Track rows with `use_id()` and special `.id` key.

For more detailed explanations and examples see package vignettes and
documentation.

### Common use cases

``` r
library(dplyr)
library(keyholder)
mtcars_tbl <- mtcars %>% as_tibble()
```

-   Track rows without modifying data:

``` r
mtcars_tbl_id <- mtcars_tbl %>%
  # Creates a key '.id' with row index
  use_id() %>%
  filter(vs == 1, gear == 4)

mtcars_tbl_id
#> # A keyed object. Keys: .id 
#> # A tibble: 10 × 11
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
#> 2  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
#> 3  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
#> # … with 7 more rows

mtcars_tbl_id %>% pull_key(.id)
#>  [1]  3  8  9 10 11 18 19 20 26 32
```

-   Backup and restore information:

``` r
mtcars_tbl_keyed <- mtcars_tbl %>%
  # Backup
  key_by(vs, am, gear) %>%
  # Modify
  mutate(vs = am) %>%
  group_by(vs) %>%
  mutate(gear = max(gear))

# Restore with recomputing groups
mtcars_tbl_restored <- mtcars_tbl_keyed %>% restore_keys_all()
mtcars_tbl_grouped <- mtcars_tbl %>% group_by(vs)
all.equal(
  as.data.frame(mtcars_tbl_restored),
  as.data.frame(mtcars_tbl_grouped),
  check.attributes = FALSE
)
#> [1] TRUE
all.equal(
  group_indices(mtcars_tbl_restored),
  group_indices(mtcars_tbl_grouped)
)
#> [1] TRUE

# Restore with renaming
mtcars_tbl_keyed %>%
  restore_keys_at("vs", .funs = list(~ paste0(., "_old")))
#> # A keyed object. Keys: vs, am, gear 
#> # A tibble: 32 × 12
#> # Groups:   vs [2]
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb vs_old
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>
#> 1  21       6   160   110  3.9   2.62  16.5     1     1     5     4      0
#> 2  21       6   160   110  3.9   2.88  17.0     1     1     5     4      0
#> 3  22.8     4   108    93  3.85  2.32  18.6     1     1     5     1      1
#> # … with 29 more rows
```

-   As a special case of previous usage one can also hide columns for
    convenient use of `dplyr`’s \*\_if scoped variants of verbs:

``` r
# Restored key goes to the end of the tibble
mtcars_tbl %>%
  key_by(mpg, .exclude = TRUE) %>%
  mutate_if(is.numeric, round, digits = 0) %>%
  restore_keys_all()
#> # A keyed object. Keys: mpg 
#> # A tibble: 32 × 11
#>     cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb   mpg
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1     6   160   110     4     3    16     0     1     4     4  21  
#> 2     6   160   110     4     3    17     0     1     4     4  21  
#> 3     4   108    93     4     2    19     1     1     4     1  22.8
#> # … with 29 more rows
```
