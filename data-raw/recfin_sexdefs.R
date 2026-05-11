#' Data frame of sex code definitions

#### Read in csv file
# Marine Recreational Fisheries Statistics Survey
# File mrfss_files_column_definitions_20190326.xlsx
# Provided by Chantel R. Wetzel from Jason Edwards
recfin_sexdefs <- utils::read.csv(
  file = dir(
    pattern = "recfin_sex_code_translation_20200806",
    full.names = TRUE, recursive = TRUE
  )
)
recfin_sexdefs[, "state"] <- toupper(substr(recfin_sexdefs[["STATE_NAME"]], 1, 2))
recfin_sexdefs[, "code"] <- ifelse(
  test = recfin_sexdefs[["SEX_CODE"]] %in% c("", "I", "N", "U"),
  yes = "U",
  no = recfin_sexdefs[["SEX_CODE"]]
)

#### Clean up
# Write .rda files
usethis::use_data(recfin_sexdefs, overwrite = TRUE)

# Clean up objects
rm(list = ls(pattern = "_.*defs"))
