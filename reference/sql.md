# Write SQL text

Write SQL text as a single character string that will result in getting
the relevant data from the RecFIN database.

## Usage

``` r
sql_catch(species_name, type, apex = FALSE)

sql_species()

sql_bds(species_name, type, apex)
```

## Arguments

- species_name:

  A vector of strings specifying the RecFIN species name desired. Must
  be a valid name though case is automatically corrected. For list of
  species codes see sql_species.

- type:

  A vector specifying the type of the data. Available options include
  "recent" for estimates from recent state sponsored surveys; and
  "mrfss" for estimates from the MRFSS survey. There is no default so
  the user must specify a valid option.

- apex:

  The specific recfin apex report that you want to reproduce. Available
  options include "SD001" and "SD501" (which are for lengths) and
  "SD506" (which is for ages) when type equals "recent", and "SD508" and
  "SD509" when type equals "mrfss". There is no default so the user must
  specify a valid option. Currently, there is no option to keep just the
  raw sql data.

## Value

A character string formatted as an sql call. For type = "hist", the
character string is returned as a list

## Details

Basing on the similar file in pacfintools

`sql_species()` A data frame of species names

`sql_bds`

## Author

Brian J Langseth
