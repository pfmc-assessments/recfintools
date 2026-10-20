# Pull all RecFIN data files from the server

Pulls the primary recreational data within one function and saves each
file as an `.Rdata` file. This script is not intended for everyone to
run, rather it is for the data provider.

## Usage

``` r
pullData(
  path = getwd(),
  species = NULL,
  username = pacfintools::getUserName("PacFIN"),
  password = pacfintools:::ask_password(),
  verbose = TRUE
)
```

## Arguments

- path:

  A file path to the directory where the files are to be saved. The
  default is the current working directory.

- species:

  The species name that the files represent. Can be a single name, or a
  vector of multiple names. The user must enter a value for this. Is
  case insensitive.

- username:

  Username to access the recfin database of interest. Default is to
  automatically set using `pacfintools::getUserName()`

- password:

  Password to access the recfin database. Default is to prompt user to
  enter using `pacfintools::ask_password()`

- verbose:

  Whether to print a message about the files that were saved. Default is
  TRUE.

## Value

A message alerting the user of the names and number of files that were
saved to `path`.

## Details

This function currently focuses on the eight primary RecFIN reports as
available on the RecFIN Dashboard: CTE501: Recent catch data CTE008:
MRFSS catch data CTE503: Washington historical catch reconstruction
CTE507: Oregon historical catch reconstruction CTE508: California
historical catch reconstruction SD501: Recent length bds data SD506:
Recent age bds data SD517: MRFSS type 3 bds data Historical catch files
are pulled for each of the three states separately but are saved as a
single list object. All other files are pulled and saved individually

## See also

[`readData()`](https://pfmc-assessments.github.io/recfintools/reference/readData.md)
Reads the data pulled by this function

`pacfintools::getUserName()`, pacfintools::ask_password which are inputs
to this function

## Author

Brian Langseth
