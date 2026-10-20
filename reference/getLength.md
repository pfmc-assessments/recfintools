# Create a length_cm column based on input column specified in `source`.

Create a length_cm column based on input column specified in `source`.

## Usage

``` r
getLength(data, source = c("RECFIN_LENGTH_MM"), verbose = TRUE)
```

## Arguments

- data:

  A loaded R data object from `pull_bds_recfin_`. Can be either length
  data or age data. \#' @param clean A logical value used when you want
  to remove data from the input data set. The default is `TRUE`, where
  the opposite returns the data with additional columns and reports on
  what would have been removed.

- source:

  Column name where length information is located. Depends on the era
  (recent, mrfss). Default value is for recent catch data
  (RECFIN_LENGTH_MM). Coded to accept a vector of names where the same
  era of data has multiple different names. When multiple names within
  the vector are in the dataset, picks the first.

- verbose:

  Whether to output detailed information about the cleaning process.
  Default is TRUE.

## Details

This function is used for only composition data. It creates a new column
in units of cm, and also flags lengths beyond max, as well as total
length measurements (as opposed to fork length) or of measurements not
directly measured. Removes lengths with NA or 0

## Length extraction rules

`source` can be a vector of candidate column names. The first matching
column in `data` is used.

The selected source column is copied directly into a standardized
`length_cm` column. The units are cm and adjusted based on whether the
input source column includes mm or cm. Extreme length values are flagged
but not removed, as are measurements in total length for recent data.
MRFSS data have separate columns for fork length (LNGTH) or total length
(T_LEN). Lengths that are NA or 0 are removed.

If `verbose = TRUE`, the function reports how many records with unknown
or 0 length were removed, along with a message conveying the number of
extreme lengths that were kept, and number of total length measurements.

## See also

[`clean_catch()`](https://pfmc-assessments.github.io/recfintools/reference/clean_catch.md)
calls 'getLength'
