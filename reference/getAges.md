# Add age information for recent bds data to the length data. Also flags records in age data that should be removed.

Add age information for recent bds data to the length data. Also flags
records in age data that should be removed.

## Usage

``` r
getAges(len_data, age_data, verbose = TRUE)
```

## Arguments

- len_data:

  A loaded Rdata object from pull_bds_recfin_recent for apex report
  SD501.

- age_data:

  A loaded Rdata object from pull_bds_recfin_recent for apex report
  SD506

## Value

Returns two data frames. The first `len_data` is the entered length data
with age information added. The second `age_data` is the entered age
data with a column "remove" added for later filtering because records
are either multiple reads of the same fish (`remove = "multRead"`) or
are NA (`remove = "naAge"`).

## Details

This function is used for only for recent composition data, and combines
the length (SD501) and age (SD506) data, which are entered by the user.
The fields used to match the datasets are fixed as `BIO_DETAIL_ID` for
length data and `SAMPLE_ID` for age data. Other fields are matched as
well to avoid duplicate rows but these two are the primary identifiers.

Additionally, this function removes records from multiple reads, which
are reported as multiple rows in SD506, by keeping the first occurrence.
This does not occur often, and only for ODFW, but when it does the
length of the fish is duplicated for each read. These records are
flagged in the age data as are records where age is not entered.

## See also

[`clean_bds()`](https://pfmc-assessments.github.io/recfintools/reference/clean_bds.md)
calls 'getAges'
