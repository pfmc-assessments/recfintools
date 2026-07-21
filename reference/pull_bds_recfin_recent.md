# Functions to pull bio data from recfin, which includes lengths and ages

Read bio data from the various biological reports in recfin: 'SD001' or
'SD501' for lengths, 'SD506' for ages MRFSS bio data: 'SD508' or 'SD509'
for Type 2 and Type 3 data, respectively

## Usage

``` r
pull_bds_recfin_recent(
  recfin_species_name,
  username = pacfintools::getUserName("PacFIN"),
  password = pacfintools:::ask_password(),
  savedir = getwd(),
  verbose = TRUE,
  apex = FALSE
)
```

## Arguments

- recfin_species_name:

  A vector of strings specifying the RecFIN species name desired. Must
  be a valid name though case is automatically corrected. For list of
  species codes see sql_species.

- username:

  Most often, this is a string containing your username for the database
  of interest. You can use `getUserName()` if you prefer to not enter
  this argument and assume the default search and/or rules for finding
  your username will work. This is the default behavior if you leave
  `username` as a missing argument, i.e.,
  `username <- getUserName(database = database)`. Sometimes this search
  will fail because of legacy rules, which are unknown to the
  development team, that were used to create your username. Please email
  the maintainer of this package if you need more functionality here.

- password:

  Most often, this is a string containing your password for the database
  of interest. You can use the function `ask_password()` if you would
  prefer to be prompted for your password. Please do not share this
  password with anyone or push code to a repository that has your
  password saved in it.

- savedir:

  A file path to the directory where the results will be saved. The
  default is the current working directory. If don't want to save use
  NULL.

- verbose:

  Currently a holdover from pacfin nominal species. Can delete.

- apex:

  The specific recfin apex report that you want to reproduce. Available
  options include "SD001" and "SD501" (which are for lengths) and
  "SD506" (which is for ages) when type equals "recent", and "SD508" and
  "SD509" when type equals "mrfss". There is no default so the user must
  specify a valid option. Currently, there is no option to keep just the
  raw sql data.

## Value

An `.RData` file is saved with the object. This same data frame is also
returned invisibly.

## See also

`pacfintools::getUserName()`, pacfintools::ask_password which are inputs
to this function

## Author

Brian J Langseth

## Examples

``` r
if (FALSE) { # \dontrun{
bio.recfin.001 <- pull_bds_recfin_recent("QUILLBACK ROCKFISH", apex = "SD001")
bio.recfin.501 <- pull_bds_recfin_recent("QUILLBACK ROCKFISH", apex = "SD501")
bio.mrfss.508 <- pull_bds_recfin_mrfss("QUILLBACK ROCKFISH", apex = "SD508")
bio.mrfss.509 <- pull_bds_recfin_mrfss("QUILLBACK ROCKFISH", apex = "SD509")
} # }
```
