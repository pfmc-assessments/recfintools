# Alert user of whether catches records for weight are missing but catches in number exist. Currently only used for recent catch data.

Alert user of whether catches records for weight are missing but catches
in number exist. Currently only used for recent catch data.

## Usage

``` r
check_catch(
  data,
  source = c("RETAINED", "RELEASED_ALIVE", "RELEASED_DEAD"),
  verbose = TRUE
)
```

## Arguments

- data:

  A loaded Rdata object from pull_catch_recfin\_ or pull_bds_recfin\_.

- source:

  Column keywords where the information is located. Can depend on era
  (recent, mrfss, or historical) however currently this is only used for
  recent catch data. Default value is for recent catch data (i.e.
  RETAINED\_, RELEASED_ALIVE\_, RELEASED_DEAD\_). The function searches
  for the columns that contain these words.

- verbose:

  Whether to output detailed information about the cleaning process.
  Default is TRUE.

## Details

This function is used for recent catch data. It lets the user know when
records have catch in numbers (for retained and released dead) but not
corresponding weight, and therefore when the total catch in weight may
be off. It is up to the user to decide how to use this information. This
function also confirms that the total mortality is the sum of retained
and released dead.

## See also

[`clean_catch()`](https://pfmc-assessments.github.io/recfintools/reference/clean_catch.md)
calls 'check_catch'
