# Identify columns of a dataframe that are empty or are mostly empty.

Identify columns of a dataframe that are empty or are mostly empty.

## Usage

``` r
find_na_columns(data, prop)
```

## Arguments

- data:

  A data frame with named columns

- prop:

  The proportion of NA values within a column after which it is
  considered to be mostly empty. Should be between 0 and 1. Column names
  where NA values occur at a higher proportion than this value are
  considered mostly empty. Default is 0.9

## Value

A vector of column names from a dataframe that are empty (i.e. only
contain NA values), along with a separate vector of column names with a
proportion of NA values greater than `prop` (i.e. are mostly empty).
