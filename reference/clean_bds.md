# Clean RecFIN biological data

Clean biological datasets from RecFIN and MRFSS so fields are
standardized and prepared for analysis.

## Usage

``` r
clean_bds(data)
```

## Arguments

- data:

  A loaded R data object from `pull_bds_recfin_`.

## Value

A data frame with standardized columns along with original and added
fields.

## See also

[`getAges()`](https://pfmc-assessments.github.io/recfintools/reference/getAges.md),
[`clean_catch()`](https://pfmc-assessments.github.io/recfintools/reference/clean_catch.md)

## Author

Brian Langseth and Kelli Faye Johnson
