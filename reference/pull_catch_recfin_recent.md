# Functions to pull catch data from recfin

Read catch data from the various total mortality reports in recfin:
'CTE501' or 'CTE001' Historical times series for each state: 'CTE503' or
'CTE507' MRFSS catch data: Does not have a formal apex report (though
CTE510 was a temporary report)

## Usage

``` r
pull_catch_recfin_recent(
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
catch.recfin <- pull_catch_recfin_recent("QUILLBACK ROCKFISH")
catch.recfin001 <- pull_catch_recfin_recent("QUILLBACK ROCKFISH", apex = "CTE001")
catch.recfin501 <- pull_catch_recfin_recent("QUILLBACK ROCKFISH", apex = "CTE501")
catch.hist <- pull_catch_recfin_hist("QUILLBACK ROCKFISH")
catch.mrfss <- pull_catch_recfin_mrfss("QUILLBACK ROCKFISH")
} # }
```
