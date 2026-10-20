# Clean RecFIN biological data

\#' Clean RecFIN data to provide data in a similar format with
consistent column names and values, and data prepared and ready for
analysis. For example, states are standardized to be state abbreviations
rather than single letters or full names and are available in the column
called `state`, or Canada, Mexico, and Puget Sound records are removed.

## Usage

``` r
clean_bds(data, clean = TRUE, verbose = TRUE)
```

## Arguments

- data:

  A loaded R data object from `pull_bds_recfin_`. Can be either length
  data or age data. \#' @param clean A logical value used when you want
  to remove data from the input data set. The default is `TRUE`, where
  the opposite returns the data with additional columns and reports on
  what would have been removed.

- verbose:

  Whether to output detailed information about the cleaning process.
  Default is TRUE.

## Value

A data frame with standardized columns along with original and added
fields.

## Details

This function removes unsuitable data provided `clean = TRUE` (default).
If `clean = FALSE` all data are retained along with an additional column
"remove" that is populated with the functions where data would be
removed. Using `clean = FALSE` is for exploration purposes only and is
NOT RECOMMENDED for final use within US West Coast assessments.

## Oregon MRFSS bds data

Oregon MRFSS bds data extend through 2003 in SD517. ORBS sampling also
occurred in 2001-2003 and duplication occurred. There is no current way
to determine which samples were duplicates. Therefore MRFSS bds data in
2001-2003 are removed using this function.

## Oregon ORBS bds data

Oregon ORBS bds data extend back to 1999 in SD501, overlapping for years
1999-2000 with MRFSS samples. During 1999-2000, ORBS operated under a
different sampling protocol than it did for years 2001-current, raising
doubts on its representativeness for those years. Therefore, ORBS bds
data in 1999-2000 are removed using this function.

## See also

[`clean_catch()`](https://pfmc-assessments.github.io/recfintools/reference/clean_catch.md)

## Author

Brian Langseth
