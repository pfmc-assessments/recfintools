# Clean RecFIN data

Clean RecFIN data to provide data in a similar format with consistent
column names and values. For example, states are standardized to be
state abbreviations rather than single letters or full names and are
available in the column called `state`.

## Usage

``` r
clean_catch(data)
```

## Arguments

- data:

  A loaded Rdata object from pull_catch_recfin\_ or pull_bds_recfin\_.

- verbose:

  Whether to output detailed information about the cleaning process.
  Default is TRUE.

## Value

A data frame with standardized columns along with original fields. See
the data object `recfin_coldefs` for more complete descriptions of
column names and their contents.

## Missing years

MRFSS data is incomplete and will not contain information for the years
1990 to 1992. Most often, linear interpolation is performed to estimate
catches during these years because it can be assumed that they were not
zero if the surrounding years were also non-zero.

MRFSS sampling for PC modes in 1993-1995 were limited. PC sampling
restarted in 1993 only in Southern districts; north of San Luis Obispo
it restarted in 1996. Some type of interpolation can be done to update
PC estimates during these years. These years will show up with some
catch, but only when broken down by mode will it be obvious that PC is
lower than in neighbor years.

\#' todo: create a function to estimate catches for 1990-1992, possibly
1993-1995?

## Washington data

Washington does not use MRFSS catch data. Rather, catches come from apex
report for recent data (CTE001 or CTE501), which extend back to 1990,
and from historical reconstructions (CTE503), which although extend
through 2002, have values for coastal areas 1-4 (i.e. non-puget sound
areas) only through 1989. When running this function, Washington catch
data are removed from the MRFSS dataset, and puget sounds areas (5+) are
removed from the historical dataset.

Washington does not differentiate by mode in its historical
reconstruction. Therefore, when running getMode() all records are
assigned as 'UNK'.

todo: create a function to estimate Washington weights for recent and
historical?

## Oregon data

Oregon does not use MRFSS catch data. Rather, catches come from apex
report for recent data (CTE001 or CTE501), which extend back to 2001,
and from historical reconstructions (CTE505), which extend through 2000.
When running this function, Oregon catch data are removed from the MRFSS
dataset.

## State mapping rules

`source` can be a vector of candidate column names. The first matching
column in `data` is used.

Values are standardized into `state` as:

- `WA`: `WASHINGTON`, `W`, or `53`

- `OR`: `OREGON`, `O`, or `41`

- `CA`: `CALIFORNIA`, `C`, or `6`

- `UNK`: all unmatched values

If `verbose = TRUE`, the function reports how many records were assigned
`UNK`.

## Mode mapping rules

`source` can be a vector of candidate column names. The first matching
column in `data` is used.

Values are standardized into `mode` as:

- `PR`: `Private/Rental Boats`

- `PC`: `Party/Charter Boats`

- `Other`: `Man-Made/Jetty`

- `UNK`: all unmatched values

If `verbose = TRUE`, the function reports how many records were assigned
`UNK`.

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

## Year extraction rules

`source` can be a vector of candidate column names. The first matching
column in `data` is used.

The selected source column is copied directly into a standardized `year`
column. No recoding is applied.

If `verbose = TRUE`, the function reports how many records have `NA` in
`year` after extraction.

## Author

Brian Langseth and Kelli Faye Johnson
