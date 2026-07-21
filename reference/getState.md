# Create a state column based on input column specified in `source`

Create a state column based on input column specified in `source`

## Usage

``` r
getState(data, source = c("AGENCY", "STATE_NAME"), verbose = TRUE)
```

## Arguments

- data:

  A loaded Rdata object from pull_catch_recfin\_ or pull_bds_recfin\_.

- source:

  Column name where state information is located. Depends on the type of
  data (catch or bds) and era (recent, mrfss, or historical). Default
  value is for recent catch data (i.e. AGENCY for CTE001 or STATE_NAME
  for CTE501). Coded to accept a vector of names where the same type or
  era of data has multiple different names. When multiple names within
  the vector are in the dataset, picks the first.

- verbose:

  Whether to output detailed information about the cleaning process.
  Default is TRUE.

## Details

Copied from pacfintools, and modified for recreational data This
function is used for both catch and composition data

## State mapping rules

`source` can be a vector of candidate column names. The first matching
column in `data` is used.

Values are standardized into `state` as:

- `WA`: `WASHINGTON`, `W`, or `53`

- `OR`: `OREGON`, `O`, or `41`

- `CA`: `CALIFORNIA`, `C`, or `6`

- `UNK`: all unmatched values

If `verbose = TRUE`, the function reports how many records were assigned
`UNK`.

## See also

[`clean_catch()`](https://pfmc-assessments.github.io/recfintools/reference/clean_catch.md)
calls 'getState'
