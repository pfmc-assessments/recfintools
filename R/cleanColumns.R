#' Remove columns that are not used and thus potentially confusing. Also removes
#' columns without any information.
#'
#' @details
#' This function cleans columns of a data frame from RecFIN. It is used for
#' both catch and composition data. Currently, the columns that are removed
#' are a mix of columns with all NA values, the percentage of NA values above
#' some threshold, and other prespecified columns that are not used regularly.
#' Should you want anything different, please feel free to post an
#' issue on GitHub, email the package maintainer, or submit a pull request.
#'
#' @param data A data frame with named columns
#' @param prop The proportion of NA values within a column after which
#' it is considered to be mostly empty. Should be between 0 and 1, inclusive.
#' Column names where NA values occur at a higher proportion than this value
#' are considered mostly empty. Default is 1, which means no columns are selected
#' as mostly empty.
#' @param verbose Whether to output detailed information about the cleaning
#' process. Default is TRUE. Also required for `show_cols`.
#' @param show_cols Whether to output the names of all the columns that were
#' removed by this function. Default is FALSE. To show must also set
#' `verbose` = TRUE
#'
#' @export
#' @author Brian Langseth
#' @return A data frame with fewer columns, along with a message alerting the
#' user of the number of columns removed, and the option to specifically list
#' out the name of the columns removed.
#'
cleanColumns <- function(data, prop = 1, verbose = TRUE, show_cols = FALSE) {
  # Names of columns that are either all NA or mostly NA
  empty_cols <- find_na_columns(data, prop)

  n_empty <- length(empty_cols$empty)
  n_mostly_empty <- length(empty_cols$mostly_empty)

  # Additional MRFSS catch columns to exclude
  mrfss_catch_cols <- c(
    "ST_SSQ", "SUB_SSQ", "LNGSSQ", "WGTSSQ", "WGTB1SSQ", "LENB2SSQ", "LENB1SSQ", "WGTB2SSQ", # Sum of squares things
    "SUB_WGT", "SUB_AVE", "SUBVAR", "SUB_EXAM", # Info of things by subregion
    "ST_WGT", "ST_AVE", "STVAR", "ST_EXAM", # Info of things by state
    "RECFIN_LOG_ID", "SAS_FILENAME", "SERVER_PATH", "DATE1", # Database things
    "GP_CODE", "SG_CODE"
  ) # Codes that are already implicit in another column

  # Additional OR historical catch columns to exclude. These are sub-elements of
  # the expansion process
  or_hist_cols <- c(
    "TOTAL", "TOTAL_01", "TOTAL_02", "TOTAL_03", "TOTAL_04",
    "TOTAL_05", "TOTAL_06", "START_EXP", "END_EXP", "BTYP_PROP",
    "TEMP_EXP", "NO_DIFF", "MO_PROP_V1", "MULTI_MO_PROP",
    "TOTAL_TEMP", "BTYP_PROP_V2", "NO_DIFF_TOTAL", "MO_PROP_V2",
    "TTYP_PROP_V1", "MULTI_PROP", "MINOR_PROP",
    "ANNUAL_MINOR_TOTAL", "MINOR_MO_PROP", "TTYP_PROP_V2",
    "BTYP_PROP_V3"
  )

  # No other columns for WA and CA historical catch, nor for recent bds lengths
  # and ages or mrfss bds

  other_catch_cols <- c(mrfss_catch_cols, or_hist_cols)

  small_data <- data |>
    dplyr::select(-dplyr::any_of(
      c(
        empty_cols$empty,
        empty_cols$mostly_empty,
        other_catch_cols
      )
    ))

  n_other <- ncol(data) - ncol(small_data) - n_empty - n_mostly_empty

  if (verbose & !show_cols) {
    cli::cli_bullets(c(
      " " = "{.fn cleanColumns} summary information -",
      "i" = "There were {n_empty} columns removed from the dataset where values
      were all NA.",
      "i" = "There were {n_mostly_empty} columns removed from the dataset where
      the proprotion of NA values exceeded {prop}.",
      "i" = "Additionally, {n_other} columns that are not regularly used for
      data processing were removed from the dataset.",
      "i" = "NOTE: For a full list of columns that were removed, set this
      function's 'show_cols' option to TRUE."
    ))
  }

  if (verbose & show_cols) {
    removed_columns <- paste(
      colnames(data)[!colnames(data) %in% colnames(small_data)],
      collapse = ", "
    )

    cli::cli_bullets(c(
      " " = "{.fn cleanColumns} summary information -",
      "i" = "There were {n_empty} columns removed from the dataset where values
    were all NA.",
      "i" = "There were {n_mostly_empty} columns removed from the dataset where
    the proprotion of NA values exceeded {prop}.",
      "i" = "Additionally, {n_other} columns that are not regularly used for
    data processing were removed from the dataset.",
      "i" = "The columns that were removed from this dataset include:
      {removed_columns}."
    ))
  }

  return(small_data)
}


#' Identify columns of a dataframe that are empty or are mostly empty.
#'
#' @inheritParams cleanColumns
#'
#' @return A vector of column names from a dataframe that are empty (i.e.
#' only contain NA values), along with a separate vector of column names with
#' a proportion of NA values greater than `prop` (i.e. are mostly empty).
#'
find_na_columns <- function(data, prop) {
  # Identify all columns where every value is NA
  temp_empty <- sapply(data, function(x) all(is.na(x)))
  empty_columns <- names(temp_empty)[temp_empty]

  # Identify columns where more than perc_thresh of the records are NA
  df <- data |>
    dplyr::select(-dplyr::all_of(empty_columns))
  temp_mostly <- colMeans(is.na(df)) > prop
  mostly_columns <- names(temp_mostly)[temp_mostly]

  out <- list("empty" = empty_columns, "mostly_empty" = mostly_columns)

  return(out)
}
