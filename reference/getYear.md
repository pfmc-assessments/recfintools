# Create a year column based on input column specified in `source` and filters out some unused records

Create a year column based on input column specified in `source` and
filters out some unused records

## Usage

``` r
getYear(data, source = c("RECFIN_YEAR"), verbose = TRUE)
```

## Arguments

- data:

  A loaded Rdata object from pull_catch_recfin\_ or pull_bds_recfin\_.

- source:

  Column name where year information is located. Depends on the type of
  data (catch or bds) and era (recent, mrfss, or historical). Default
  value is for recent catch data (RECFIN_YEAR). Coded to accept a vector
  of names where the same type or era of data has multiple different
  names. When multiple names within the vector are in the dataset, picks
  the first.

- verbose:

  Whether to output detailed information about the cleaning process.
  Default is TRUE.

## Details

This function is used for both catch and composition data

## Year extraction rules

`source` can be a vector of candidate column names. The first matching
column in `data` is used.

The selected source column is copied directly into a standardized `year`
column. No recoding is applied.

If `verbose = TRUE`, the function reports how many records have `NA` in
`year` after extraction.

## Oregon MRFSS bds data

Oregon MRFSS bds data extend through 2003 in SD509. ORBS sampling also
occurred in 2001-2003 and duplication occurred. There is no current way
to determine which samples were duplicates. Therefore MRFSS bds data in
2001-2003 is removed using this function.

## See also

[`clean_catch()`](https://pfmc-assessments.github.io/recfintools/reference/clean_catch.md)
calls 'getYear'
