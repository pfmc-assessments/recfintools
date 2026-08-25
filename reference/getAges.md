# Add age data to length data for recent bds data.

Add age data to length data for recent bds data.

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

## Details

This function is used for only for recent composition data, and combines
the length (SD501) and age (SD506) data, which are entered by the user.
The fields used to match the datasets are fixed as `BIO_DETAIL_ID` for
length data and `SAMPLE_ID` for age data. Other fields are matched as
well to avoid duplicate rows but these two are the primary identifiers.

Additionally, this function removes records from multiple reads, which
are reported as multiple rows in SD506, by keeping the first occurrence.
This does not occur often, and only for ODFW, but when it does the
length of the fish is duplicated for each read.

## See also

[`clean_bds()`](https://pfmc-assessments.github.io/recfintools/reference/clean_bds.md)
calls 'getAges'
