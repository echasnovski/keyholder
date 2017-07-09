
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/echasnovski/keyholder.svg?branch=master)](https://travis-ci.org/echasnovski/keyholder) [![Coverage Status](https://img.shields.io/codecov/c/github/echasnovski/keyholder/master.svg)](https://codecov.io/github/echasnovski/keyholder?branch=master) [![packageversion](https://img.shields.io/badge/Package%20version-0.0.0.9000-green.svg?style=flat-square)](commits/master)

keyholder
=========

`keyholder` is a package for storing information (*keys*) about rows in data frame like objects. The common use cases are to track rows of data without modifying it and to backup and restore information about rows. This is done with creating a class **keyed\_df** which has special attribute "keys". Keys are updated according to changes in rows of reference data frame.

`keyholder` is designed to work tightly with [dplyr](https://github.com/tidyverse/dplyr) package. There are methods implemented for all one- and two-table generics from this package that update keys properly.

Installation
------------

You can install `keyholder` from github with:

``` r
# install.packages("devtools")
devtools::install_github("echasnovski/keyholder")
```

Usage
-----

``` r
library(dplyr)
library(keyholder)
mtcars_tbl <- mtcars %>% as_tibble()
```

### Set keys

The general agreement is that keys are always converted to [tibble](https://github.com/tidyverse/tibble). In this way one can use multiple variables as keys by binding them.

There are two ways of creating keys:

-   With assigning. The assigned object will be converted to tibble with `as_tibble()`. To make sense it should have the same number of rows as reference data frame. There are two functions for assigning: `keys<-` and `assign_keys` which are basically the same. The former use more suitable for interactive use and the latter - for piping with [magrittr](https://github.com/tidyverse/magrittr)'s pipe operator `%>%`.

``` r
mtcars_tbl_keyed <- mtcars_tbl
keys(mtcars_tbl_keyed) <- tibble(id = 1:nrow(mtcars_tbl_keyed))

mtcars_tbl %>% assign_keys(tibble(id = 1:nrow(.)))
#> # A keyed object. Keys: id 
#> # A tibble: 32 x 11
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#> * <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21.0     6   160   110  3.90 2.620 16.46     0     1     4     4
#> 2  21.0     6   160   110  3.90 2.875 17.02     0     1     4     4
#> 3  22.8     4   108    93  3.85 2.320 18.61     1     1     4     1
#> # ... with 29 more rows
```

-   With `key_by()`. This is similar in its design to `group_by` from `dplyr`: it takes some columns from reference data frame and makes them keys. It has two important options: `.add` (whether to add specified columns to existing keys) and `.exclude` (whether to exclude specified columns from reference data frame). Grouping is ignored.

``` r
mtcars_tbl %>% key_by(vs, am)
#> # A keyed object. Keys: vs, am 
#> # A tibble: 32 x 11
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#> * <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21.0     6   160   110  3.90 2.620 16.46     0     1     4     4
#> 2  21.0     6   160   110  3.90 2.875 17.02     0     1     4     4
#> 3  22.8     4   108    93  3.85 2.320 18.61     1     1     4     1
#> # ... with 29 more rows

mtcars_tbl %>% key_by(starts_with("c"))
#> # A keyed object. Keys: cyl, carb 
#> # A tibble: 32 x 11
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#> * <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21.0     6   160   110  3.90 2.620 16.46     0     1     4     4
#> 2  21.0     6   160   110  3.90 2.875 17.02     0     1     4     4
#> 3  22.8     4   108    93  3.85 2.320 18.61     1     1     4     1
#> # ... with 29 more rows
```

To properly unkey object use `unkey()`.

``` r
mtcars_tbl_keyed <- mtcars_tbl %>% key_by(vs, am)

# Good
mtcars_tbl_keyed %>% unkey()
#> # A tibble: 32 x 11
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#> * <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21.0     6   160   110  3.90 2.620 16.46     0     1     4     4
#> 2  21.0     6   160   110  3.90 2.875 17.02     0     1     4     4
#> 3  22.8     4   108    93  3.85 2.320 18.61     1     1     4     1
#> # ... with 29 more rows

# Bad
attr(mtcars_tbl_keyed, "keys") <- NULL
mtcars_tbl_keyed
#> # A keyed object. Keys: there are no keys.
#> # A tibble: 32 x 11
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#> * <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21.0     6   160   110  3.90 2.620 16.46     0     1     4     4
#> 2  21.0     6   160   110  3.90 2.875 17.02     0     1     4     4
#> 3  22.8     4   108    93  3.85 2.320 18.61     1     1     4     1
#> # ... with 29 more rows
```

### Get keys

There are also two ways of extracting keys:

-   With `keys()`. This function always returns a tibble. In case of no keys it returns a tibble with number of rows as in reference data frame and zero columns.

``` r
mtcars_tbl %>% keys()
#> # A tibble: 32 x 0

mtcars_tbl %>% key_by(vs, am) %>% keys()
#> # A tibble: 32 x 2
#>      vs    am
#> * <dbl> <dbl>
#> 1     0     1
#> 2     0     1
#> 3     1     1
#> # ... with 29 more rows
```

-   With `raw_keys()` which is just a wrapper for `attr(.tbl, "keys")`.

``` r
mtcars_tbl %>% raw_keys()
#> NULL

mtcars_tbl %>% key_by(vs, am) %>% raw_keys()
#> # A tibble: 32 x 2
#>      vs    am
#> * <dbl> <dbl>
#> 1     0     1
#> 2     0     1
#> 3     1     1
#> # ... with 29 more rows
```

### Manipulate keys

-   Remove keys with `remove_keys()`. If all keys are removed one can automatically unkey object by setting option `.unkey` to `TRUE`.

``` r
mtcars_tbl %>% key_by(vs, am) %>% remove_keys(vs)
#> # A keyed object. Keys: am 
#> # A tibble: 32 x 11
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#> * <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21.0     6   160   110  3.90 2.620 16.46     0     1     4     4
#> 2  21.0     6   160   110  3.90 2.875 17.02     0     1     4     4
#> 3  22.8     4   108    93  3.85 2.320 18.61     1     1     4     1
#> # ... with 29 more rows

mtcars_tbl %>% key_by(vs, am) %>% remove_keys(everything(), .unkey = TRUE)
#> # A tibble: 32 x 11
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#> * <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21.0     6   160   110  3.90 2.620 16.46     0     1     4     4
#> 2  21.0     6   160   110  3.90 2.875 17.02     0     1     4     4
#> 3  22.8     4   108    93  3.85 2.320 18.61     1     1     4     1
#> # ... with 29 more rows
```

-   Restore keys with `restore_keys()`. Restoring means creating or modifying a column in reference data frame with values taken from keys. After restoring certain key one can remove it from keys by setting `.remove` to `TRUE`. There is also an option `.unkey` identical to one in `remove_keys()` (which is meaningful only in case `.remove` is `TRUE`).

``` r
mtcars_tbl_keyed <- mtcars_tbl %>%
  key_by(vs, am) %>%
  mutate(vs = 1, am = 0)
mtcars_tbl_keyed
#> # A keyed object. Keys: vs, am 
#> # A tibble: 32 x 11
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21.0     6   160   110  3.90 2.620 16.46     1     0     4     4
#> 2  21.0     6   160   110  3.90 2.875 17.02     1     0     4     4
#> 3  22.8     4   108    93  3.85 2.320 18.61     1     0     4     1
#> # ... with 29 more rows

mtcars_tbl_keyed %>% restore_keys(vs)
#> # A keyed object. Keys: vs, am 
#> # A tibble: 32 x 11
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21.0     6   160   110  3.90 2.620 16.46     0     0     4     4
#> 2  21.0     6   160   110  3.90 2.875 17.02     0     0     4     4
#> 3  22.8     4   108    93  3.85 2.320 18.61     1     0     4     1
#> # ... with 29 more rows

mtcars_tbl_keyed %>% restore_keys(vs, .remove = TRUE)
#> # A keyed object. Keys: am 
#> # A tibble: 32 x 11
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21.0     6   160   110  3.90 2.620 16.46     0     0     4     4
#> 2  21.0     6   160   110  3.90 2.875 17.02     0     0     4     4
#> 3  22.8     4   108    93  3.85 2.320 18.61     1     0     4     1
#> # ... with 29 more rows

mtcars_tbl_keyed %>% restore_keys(vs, am, .unkey = TRUE)
#> # A keyed object. Keys: vs, am 
#> # A tibble: 32 x 11
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21.0     6   160   110  3.90 2.620 16.46     0     1     4     4
#> 2  21.0     6   160   110  3.90 2.875 17.02     0     1     4     4
#> 3  22.8     4   108    93  3.85 2.320 18.61     1     1     4     1
#> # ... with 29 more rows

mtcars_tbl_keyed %>% restore_keys(vs, am, .remove = TRUE, .unkey = TRUE)
#> # A tibble: 32 x 11
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21.0     6   160   110  3.90 2.620 16.46     0     1     4     4
#> 2  21.0     6   160   110  3.90 2.875 17.02     0     1     4     4
#> 3  22.8     4   108    93  3.85 2.320 18.61     1     1     4     1
#> # ... with 29 more rows
```

One important feature of `restore_keys()` is that restoring keys beats 'not-modifying' grouping variables rule. It is made according to the ideology of keys: they contain information about rows and by restoring you want it to be available.

``` r
mtcars_tbl_keyed %>% group_by(vs, am)
#> # A keyed object. Keys: vs, am 
#> # A tibble: 32 x 11
#> # Groups:   vs, am [1]
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21.0     6   160   110  3.90 2.620 16.46     1     0     4     4
#> 2  21.0     6   160   110  3.90 2.875 17.02     1     0     4     4
#> 3  22.8     4   108    93  3.85 2.320 18.61     1     0     4     1
#> # ... with 29 more rows

mtcars_tbl_keyed %>% group_by(vs, am) %>% restore_keys(vs, am)
#> # A keyed object. Keys: vs, am 
#> # A tibble: 32 x 11
#> # Groups:   vs, am [4]
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21.0     6   160   110  3.90 2.620 16.46     0     1     4     4
#> 2  21.0     6   160   110  3.90 2.875 17.02     0     1     4     4
#> 3  22.8     4   108    93  3.85 2.320 18.61     1     1     4     1
#> # ... with 29 more rows
```

-   Rename keys with `rename_keys()`. Renaming is done with `rename()` from `dplyr` and so renaming format comes from it.

``` r
mtcars_tbl %>% key_by(vs, am) %>% rename_keys(Vs = vs)
#> # A keyed object. Keys: Vs, am 
#> # A tibble: 32 x 11
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#> * <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21.0     6   160   110  3.90 2.620 16.46     0     1     4     4
#> 2  21.0     6   160   110  3.90 2.875 17.02     0     1     4     4
#> 3  22.8     4   108    93  3.85 2.320 18.61     1     1     4     1
#> # ... with 29 more rows
```

### Verbs from dplyr

All one- and two-table verbs from `dplyr` (with present scoped variants) support `keyed_df`. If rows in reference data frame rearranged or removed the same operation is doen to keys. Some functions (`summarise`, `distinct` and `do`) unkey object.

``` r
mtcars_tbl_keyed <- mtcars_tbl %>% key_by(vs, am)

mtcars_tbl_keyed %>% select(gear, mpg)
#> # A keyed object. Keys: vs, am 
#> # A tibble: 32 x 2
#>    gear   mpg
#> * <dbl> <dbl>
#> 1     4  21.0
#> 2     4  21.0
#> 3     4  22.8
#> # ... with 29 more rows

mtcars_tbl_keyed %>% summarise(meanMPG = mean(mpg))
#> # A tibble: 1 x 1
#>    meanMPG
#>      <dbl>
#> 1 20.09062

mtcars_tbl_keyed %>% filter(vs == 1) %>% keys()
#> # A tibble: 14 x 2
#>      vs    am
#>   <dbl> <dbl>
#> 1     1     1
#> 2     1     0
#> 3     1     0
#> # ... with 11 more rows

mtcars_tbl_keyed %>% arrange_at("mpg") %>% keys()
#> # A tibble: 32 x 2
#>      vs    am
#>   <dbl> <dbl>
#> 1     0     0
#> 2     0     0
#> 3     0     0
#> # ... with 29 more rows
```
