# Create a length_cm column based on input column specified in `source`.

Create a length_cm column based on input column specified in `source`.

Create a year column based on input column specified in `source`

## Usage

``` r
getYear(data, source = c("RECFIN_YEAR"), verbose = TRUE)

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

This function is used for only composition data. It creates a new column
in units of cm, and also flags lengths beyond max, as well as total
length measurements (as opposed to fork length). Removes lengths with NA
or 0

This function is used for both catch and composition data

## Length extraction rules

`source` can be a vector of candidate column names. The first matching
column in `data` is used.

The selected source column is copied directly into a standardized
`length_cm` column. The units are cm and adjusted based on whether the
input source column includes mm or cm. Extreme length values are flagged
but not removed, as are measurements in Total length. Lengths that are
NA or 0 are removed.

If `verbose = TRUE`, the function reports how many records with unknown
or 0 length were removed, alongwith a message conveying the number of
extreme lengths that were kept, and number of total length measurements.

## Year extraction rules

`source` can be a vector of candidate column names. The first matching
column in `data` is used.

The selected source column is copied directly into a standardized `year`
column. No recoding is applied.

If `verbose = TRUE`, the function reports how many records have `NA` in
`year` after extraction.

## See also

[`clean_catch()`](https://pfmc-assessments.github.io/recfintools/reference/clean_catch.md)
calls 'getLength'

[`clean_catch()`](https://pfmc-assessments.github.io/recfintools/reference/clean_catch.md)
calls 'getYear'
