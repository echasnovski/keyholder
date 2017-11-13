
[![Travis-CI Build Status](https://travis-ci.org/echasnovski/keyholder.svg?branch=master)](https://travis-ci.org/echasnovski/keyholder) [![Coverage Status](https://codecov.io/gh/echasnovski/keyholder/graph/badge.svg)](https://codecov.io/github/echasnovski/keyholder?branch=master)

keyholder
=========

`keyholder` is a package for storing information (*keys*) about rows of data frame like objects. The common use cases are to track rows of data without modifying it and to backup and restore information about rows. This is done with creating a class **keyed\_df** which has special attribute "keys". Keys are updated according to changes in rows of reference data frame.

`keyholder` is designed to work tightly with [dplyr](http://dplyr.tidyverse.org/) package. All its one- and two-table verbs update keys properly.

Installation
------------

You can install current stable version from CRAN with:

``` r
install.packages("keyholder")
```

Also you can install development version from github with:

``` r
# install.packages("devtools")
devtools::install_github("echasnovski/keyholder")
```

Usage
-----

`keyholder` provides a set of functions to work with keys:

-   Set keys with `assign_keys()` and `key_by()`.
-   Get all keys with `keys()`. Get one specific key with `pull_key()`.
-   Restore information stored in certain keys with `restore_keys()` and its scoped variants (`*_all()`, `*_if()` and `*_at()`).
-   Rename certain keys with `rename_keys()` and its scoped variants.
-   Remove certain keys with `remove_keys()` and its scoped variants. Completely unkey object with `unkey()`.
-   Track rows with `use_id()` and special `.id` key.

For more detailed explanations and examples see package vignettes and documentation.

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
#> # A tibble: 10 x 11
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  22.8     4 108.0    93  3.85  2.32 18.61     1     1     4     1
#> 2  24.4     4 146.7    62  3.69  3.19 20.00     1     0     4     2
#> 3  22.8     4 140.8    95  3.92  3.15 22.90     1     0     4     2
#> # ... with 7 more rows

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
mtcars_tbl_keyed %>%
  restore_keys_all() %>%
  all.equal(mtcars_tbl)
#> [1] TRUE

# Restore with renaming
mtcars_tbl_keyed %>%
  restore_keys_at("vs", .funs = funs(paste0(., "_old")))
#> # A keyed object. Keys: vs, am, gear 
#> # A tibble: 32 x 12
#> # Groups:   vs [2]
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb vs_old
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>
#> 1  21.0     6   160   110  3.90 2.620 16.46     1     1     5     4      0
#> 2  21.0     6   160   110  3.90 2.875 17.02     1     1     5     4      0
#> 3  22.8     4   108    93  3.85 2.320 18.61     1     1     5     1      1
#> # ... with 29 more rows
```

-   As a special case of previous usage one can also hide columns for convenient use of `dplyr`'s \*\_if scoped variants of verbs:

``` r
# Restored key goes to the end of the tibble
mtcars_tbl %>%
  key_by(mpg, .exclude = TRUE) %>%
  mutate_if(is.numeric, round, digits = 0) %>%
  restore_keys_all()
#> # A keyed object. Keys: mpg 
#> # A tibble: 32 x 11
#>     cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb   mpg
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1     6   160   110     4     3    16     0     1     4     4  21.0
#> 2     6   160   110     4     3    17     0     1     4     4  21.0
#> 3     4   108    93     4     2    19     1     1     4     1  22.8
#> # ... with 29 more rows
```
