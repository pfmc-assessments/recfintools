# Calculate and add weight data to historical catches so that catch in weight can be produced.

Calculate and add weight data to historical catches so that catch in
weight can be produced.

## Usage

``` r
getWeightHist(
  catch_data,
  bds_data,
  figure = TRUE,
  state = NULL,
  verbose = TRUE
)
```

## Arguments

- catch_data:

  Dataset that contains the state specific historical catch data as
  returned by `pull_catch_recfin`.

- bds_data:

  Dataset that contains the weight data as returned by
  `pull_bds_recfin`. The current script is coded for type 3 MRFSS data
  (SD509).

- figure:

  Whether to output a figure showing the average weights by mode and
  sample sizes in each year that catch is available. Default is TRUE.
  Currently, this function does not save the figure.

- state:

  The state for which average weights are calculated. Can be "WA" or
  "OR" for Washington or Oregon historical data, respectively.
  Currently, only "OR" is available.

- verbose:

  Whether to output detailed information about material added by this
  function. Default is TRUE.

## Value

The data frame `catch_data` with a new column of calculated weight by
year `calc_wgt_kg` and samples sizes `calc_wgt_n` used in the
calculation.

## Details

This script contains a function that takes historical catches for Oregon
(and in the future for Washington) which are in number, and adds a
weight column so that catches can be in weight. This function requires
inputs from both catch and composition data. Weight data is calculated
from the composition data and a `calc_wgt_kg` and `calc_wgt_n` are added
to the catch dataset.

Calculated weight is the average weight by mode and year when mode data
exists, and year when mode data does not exist. For years without weight
data, the overall average (over all modes and years) is used.
`calc_wgt_n` is the sample size used to calculate `calc_wgt_kg`.

This function has the option to return a figure showing the calculated
average weight and sample size. Users should look at this figure to
confirm values and assumptions are appropriate for their species. Should
the user wish to apply a different approach to interpolate missing
years, they can with the information returned from this function. Should
a user wish to apply different ways to calculate weight, feel free to
post a github issue, email the maintainer, or submit a pull request.

## Oregon Historical weights

Weight data is obtained from type 3 MRFSS data (SD509). Only measured
weights are used (based on the assumption that measured weights contain
two or fewer decimal places and are not zero), from PR/PC modes (MODE_FX
= 6 or 7), and ocean areas (AREA_X = 1 - 4).

MRFSS samples are missing for some years where catch in numbers exist
(e.g. 1979, 1990-1992). Weights are applied for these years based on an
overall average from all years and modes. Sample sizes for these
interpolated years are NA.

## Washington Historical weights

\#to do: Add later

## See also

[`clean_catch()`](https://pfmc-assessments.github.io/recfintools/reference/clean_catch.md)
calls 'getWeightHist'

## Author

Brian Langseth and Ali Whitman
