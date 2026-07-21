# A data frame of sex codes

A data frame of sex codes by state provided by RecFIN.

## Usage

``` r
recfin_sexdefs
```

## Format

A data frame with seven columns

- AGENCY_CODE: An integer specifying which agency the row pertains to

- STSATE_NAME: The full character version of the state name in title
  case

- AGENCY_SEX_CODE: Integer or single character codes used by the agency

- SEX_CODE: Upper-case character codes used by RecFIN

- SEX_NAME: A description of what the SEX_CODE means

- state: The two-letter abbreviation for the state name

- code: An upper-case letter for the sex code provided by
  @kellijohnson-NOAA with the following options: F, H, M, U, T
