# Create a mode column based on input column specified in `source`

Create a mode column based on input column specified in `source`

## Usage

``` r
getMode(data, source = c("RECFIN_MODE_NAME"), verbose = TRUE)
```

## Arguments

- data:

  A loaded Rdata object from pull_catch_recfin\_ or pull_bds_recfin\_.

- source:

  Column name where mode information is located. Depends on the type of
  data (catch or bds) and era (recent, mrfss, or historical). Default
  value is for recent catch data (RECFIN_MODE_NAME). Coded to accept a
  vector of names where the same type or era of data has multiple
  different names. When multiple names within the vector are in the
  dataset, picks the first.

- verbose:

  Whether to output detailed information about the cleaning process.
  Default is TRUE.

## Details

This function is used for both catch and composition data

## Mode mapping rules

`source` can be a vector of candidate column names. The first matching
column in `data` is used.

Values in `source` are evaluated using case-insensitive matching. Values
are standardized into `mode` as:

- `PR`: anything with `Private` (associated with code 7)

- `PC`: anything with `Party` or `Charter` (associated with code 6)

- `Other`: `Man-Made/Jetty`, `Man-Made`, `Beach/Bank`, `Shore` (all
  other codes)

- `UNK`: all unmatched values

If `verbose = TRUE`, the function reports how many records were assigned
`UNK`.

## See also

[`clean_catch()`](https://pfmc-assessments.github.io/recfintools/reference/clean_catch.md)
calls 'getMode'
