#' Data frame of column definitions
#' @return Data frame with four columns: Source, Type, Column, Description

#### MRFSS column definitions
# Marine Recreational Fisheries Statistics Survey
# File mrfss_files_column_definitions_20190326.xlsx
# Provided by Chantel R. Wetzel
# Read in multiple tabs saved under type and rbind them into data frame
mrfss_coldefs <- bind_rows(
  .id = "Type",
  mapply(
    FUN = xlsx::read.xlsx,
    SIMPLIFY = FALSE,
    sheetIndex = c(
      estimate = 2,
      type1 = 3,
      type2 = 4,
      type3 = 5,
      type4 = 6,
      type6 = 7
    ),
    MoreArgs = list(
      file = dir(
        pattern = "^mrfss_files_column_definitions_20190326.xlsx",
        full.names = TRUE, recursive = TRUE
      )
    )
  )
)
mrfss_coldefs[, "Source"] <- "MRFSS"

#### cte501 column definitions
# File comprehensive_rec_catch_est_table_column definitions_20201120.xlsx
# Sourced from https://reports.psmfc.org/recfin/f?p=601:1000::::::
cte501_coldefs <- xlsx::read.xlsx(
  sheetIndex = 2,
  file = dir(
    pattern = "comprehensive_rec_catch_est_table_column",
    full.names = TRUE,
    recursive = TRUE
  )
)
cte501_coldefs[, "Source"] <- "cte501"
cte501_coldefs[, "Type"] <- "estimate"

#### Make global object
recfin_coldefs <- rbind(
  mrfss_coldefs, cte501_coldefs
)

#### Clean up
# Write .rda files
usethis::use_data(recfin_coldefs, overwrite = TRUE)

# Clean up objects
rm(list = ls(pattern = "_coldefs"))
