# Read RecFIN data files

Read the primary `.RData` files produced by this package and assign each
loaded object to a standardized object name.

## Usage

``` r
readData(path = getwd(), envir = parent.frame(), verbose = TRUE)
```

## Arguments

- path:

  A file path to the directory containing the `.RData` files. The
  default is the current working directory.

- envir:

  The environment to which the loaded objects should be assigned. The
  default is the calling environment.

- verbose:

  Whether to print a message about the files that were loaded. Default
  is TRUE.

## Value

An invisible named list of loaded objects.

## Details

This function currently focuses on the six primary RecFIN data files:
`BDS.Recent_SD501`, `BDS.Recent_SD506`, `BDS.MRFSS_SD509`,
`Catch.Recent_CTE501`, `Catch.MRFSS`, and `Catch.Hist`. If multiple
files with the same keyword are present, the most recently modified file
is used. The loaded objects are assigned into `envir` using standardized
object names: `bds_recent_len`, `bds_recent_age`, `bds_mrfss`,
`catch_recent`, `catch_mrfss`, and `catch_hist`.

## Author

Brian Langseth
