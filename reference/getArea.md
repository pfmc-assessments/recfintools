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
  data (catch or bds) and era (recent, mrfss, or historical). Coded to
  accept a vector of names where the same type or era of data has
  multiple different names. When multiple names within the vector are in
  the dataset, picks the first. For recent catch data, use
  `RECFIN_WATER_AREA_NAME`, which filters out values of Canada, Mexico,
  and Puget Sound. Areas with `Not Known` are kept. For Washington
  historical catch data, uses `AREA`, which filters out values of 5 and
  greater (i.e. Puget Sound) For recent bds data, use
  `AGENCY_FISHED_AREA_NAME`, which filters out values of Canada, Mexico,
  and Puget Sound. Areas with "Not known" or "Unknown" are kept if they
  also have coastal port names. Because California data are empty for
  `AGENCY_FISH_AREA_NAME`, the code instead filters California data
  using "AGENCY_WATER_AREA_NAME" when `AGENCY_FISHED_AREA_NAME` is used.
  For all other data sets, use any valid column, since for these areas
  no specific records outside federal waters are identifiable.

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

For recent RecFIN catch data (`source = "RECFIN_WATER_AREA_NAME"`),
records are removed when area is:

- `CANADA`

- `MEXICO`

- `PUGET SOUND`

For recent RecFIN bds data (`source = "AGENCY_FISHED_AREA_NAME"`),
records are kept when area is

- For Washington: PUNCH CARD AREAs 1 through 4, and PUNCH CARD AREAs 0
  and 'Not Known' when RECFIN_PORT_NAME also equals coastal ports.

- For California: Because AGENCY_FISHED_AREA_NAME is empty for
  California, the script automatically uses "AGENCY_WATER_AREA_NAME" for
  california data.

For Washington historical data (`source = "AREA"` and `AGENCY == "W"`),
records with `AREA >= 5` are removed.

If `verbose = TRUE`, the function reports the number of records removed
by category.

## See also

[`clean_catch()`](https://pfmc-assessments.github.io/recfintools/reference/clean_catch.md)
calls 'getArea'
