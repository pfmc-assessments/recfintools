# Clean RecFIN data

Clean RecFIN data to provide data in a similar format with consistent
column names and values, and data prepared and ready for analysis. For
example, states are standardized to be state abbreviations rather than
single letters or full names and are available in the column called
`state`, or Canada, Mexico, and Puget Sound records are removed

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

A data frame with standardized columns along with original and added
fields. See the data object `recfin_coldefs` for more complete
descriptions of column names and their contents.

## Missing years

MRFSS data is incomplete and will not contain information for the years
1990 to 1992. Most often, linear interpolation is performed to estimate
catches during these years because it can be assumed that they were not
zero if the surrounding years were also non-zero.

MRFSS sampling for PC modes in 1993-1995 was limited. PC sampling in CA
restarted in 1993 only in Southern districts; north of San Luis Obispo
it restarted in 1996. Some type of interpolation can be done to update
PC estimates during these years. These years will show up with some
catch, but only when broken down by mode will it be obvious that PC is
lower than in neighbor years.

Currently, these years are not filled in and it is up to the user to
decide how best to fill.

\#' todo: create a function to estimate catches for 1990-1992, possibly
1993-1995?

## Washington data

Washington does not use MRFSS catch data. Rather, catches come from apex
reports for recent data (CTE001 or CTE501), which extend back to 1990,
and from historical reconstructions (CTE503), which although extend
through 2002, have values for coastal areas 1-4 (i.e. non-puget sound
areas) only through 1989. When running this function, Washington catch
data are removed from the MRFSS dataset, and Puget Sound areas (5+) are
removed from the historical dataset.

Washington does not differentiate by mode in its historical
reconstruction. Therefore, when running getMode() all records are
assigned as 'UNK'.

todo: create a function to estimate Washington weights for recent and
historical?

## Oregon data

Oregon does not use MRFSS catch data. Rather, catches come from apex
reports for recent data (CTE001 or CTE501), which extend back to 2001,
and from historical reconstructions (CTE505), which extend through 2000.
When running this function, Oregon catch data are removed from the MRFSS
dataset.

Oregon historical catches are provided in numbers. When running this
function, average weights are calcualted that can be used to determine
catch in weight.

## California data

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

Values in `source` are evaluated using case-insensitive matching. Values
are standardized into `mode` as:

- `PR`: anything with `Private` (associated with code 7)

- `PC`: anything with `Party` or `Charter` (associated with code 6)

- `Other`: `Man-Made/Jetty`, `Man-Made`, `Beach/Bank`, `Shore` (all
  other codes)

- `UNK`: all unmatched values

If `verbose = TRUE`, the function reports how many records were assigned
`UNK`.

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

## Year extraction rules

`source` can be a vector of candidate column names. The first matching
column in `data` is used.

The selected source column is copied directly into a standardized `year`
column. No recoding is applied.

If `verbose = TRUE`, the function reports how many records have `NA` in
`year` after extraction.

## Oregon Historical weights

Weight data is obtained from type 3 MRFSS data (SD509). Only measured
weights are used (based on the assumption that measured weights contain
two or fewer decimal places and are not zero), from PR/PC modes (MODE_FX
= 6 or 7), and ocean areas (AREA_X = 1 - 4).

MRFSS samples are missing for some years where catch in numbers exist
(e.g. 1979, 1990-1992). Weights are applied for these years based on an
overall average from all years and modes. Sample sizes for these
interpolated years are NA.

## Author

Brian Langseth and Kelli Faye Johnson
