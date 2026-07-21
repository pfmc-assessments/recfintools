# Filter out records from Puget Sound, Canada, Mexico, or unknown areas based on input column specified in `source`.

Filter out records from Puget Sound, Canada, Mexico, or unknown areas
based on input column specified in `source`.

## Usage

``` r
getArea(data, source = c("RECFIN_WATER_AREA_NAME"), verbose = TRUE)
```

## Arguments

- data:

  A loaded Rdata object from pull_catch_recfin\_ or pull_bds_recfin\_.

- source:

  Column name where area information is located. Depends on the type of
  data (catch or bds) and era (recent, mrfss, or historical). For recent
  catch data, use `RECFIN_WATER_AREA_NAME`, which filters out values of
  Canada, Mexico, Puget Sound, and Not Known. For Washington historical
  catch data, use `AREA`, which filters out values of 5 and greater
  (i.e. Puget Sound) For Oregon historical catch data For California
  historical catch data

- verbose:

  Whether to output detailed information about the cleaning process.
  Default is TRUE.

## Details

This function is used for both catch and composition data. Because the
case for values are sometimes different across data sets, fields with
values as character strings are converted to lowercase when filtering.
Based on similar function from pacfintools, but modified for
recreational data

## Area filtering rules

Values in `source` are evaluated using case-insensitive matching.

For recent RecFIN data (`source = "RECFIN_WATER_AREA_NAME"`), records
are removed when area is:

- `CANADA`

- `MEXICO`

- `PUGET SOUND`

- `NOT KNOWN`

For Washington historical data (`source = "AREA"` and `AGENCY == "W"`),
records with `AREA >= 5` are removed.

If `verbose = TRUE`, the function reports the number of records removed
by category.

## See also

[`clean_catch()`](https://pfmc-assessments.github.io/recfintools/reference/clean_catch.md)
calls 'getArea'
