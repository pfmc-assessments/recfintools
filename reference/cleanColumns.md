# Remove columns that are not used and thus potentially confusing. Also removes columns without any information.

Remove columns that are not used and thus potentially confusing. Also
removes columns without any information.

## Usage

``` r
cleanColumns(data, prop, verbose = TRUE, show_cols = FALSE)
```

## Arguments

- data:

  A data frame with named columns

- prop:

  The proportion of NA values within a column after which it is
  considered to be mostly empty. Should be between 0 and 1. Column names
  where NA values occur at a higher proportion than this value are
  considered mostly empty. Default is 0.9

- verbose:

  Whether to output detailed information about the cleaning process.
  Default is TRUE

- show_cols:

  Whether to output the names of all the columns that were removed by
  this function. Default is FALSE. To show must also set `verbose` =
  TRUE

## Value

A data frame with fewer columns, along with a message alerting the user
of the number of columns removed, and the option to specifically list
out the name of the columns removed.

## Details

This function cleans columns of a data frame from RecFIN. It is used for
both catch and composition data. Currently, the columns that are removed
are a mix of columns with all NA values, the percentage of NA values
above some threshold, and other prespecified columns that are not used
regularly. Should you want anything different, please feel free to post
an issue on GitHub, email the package maintainer, or submit a pull
request.

## Author

Brian Langseth
