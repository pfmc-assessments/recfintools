#' Create a year column based on input column specified in `source` and flag
#' records for removal
#'
#' @details
#' This function is used for both catch and composition data
#'
#' @section Year extraction rules:
#' `source` can be a vector of candidate column names. The first matching
#' column in `data` is used.
#'
#' The selected source column is copied directly into a standardized `year`
#' column. No recoding is applied.
#'
#' If `verbose = TRUE`, the function reports how many records have `NA` in
#' `year` after extraction. Records are flagged in `remove`, not removed by
#' this function. [clean_catch()] and [clean_bds()] remove flagged records when
#' `clean = TRUE`.
#'
#' @section Oregon MRFSS bds data:
#' Oregon MRFSS bds data extend through 2003 in SD517. ORBS sampling also
#' occurred in 2001-2003 and duplication occurred. There is no current way to
#' determine which samples were duplicates. Therefore MRFSS bds data in 2001-2003
#' are flagged for removal using this function.
#' @section Oregon ORBS bds data:
#' Oregon ORBS bds data extend back to 1999 in SD501, overlapping for years
#' 1999-2000 with MRFSS samples. During 1999-2000, ORBS operated under a different
#' sampling protocol than it did for years 2001-current, raising doubts on its
#' representativeness for those years. Therefore, ORBS bds data in 1999-2000 are
#' flagged for removal using this function.
#'
#' @export
#' @seealso [clean_catch()] calls 'getYear'
#'
#' @inheritParams clean_catch
#'
#' @param source Column name where year information is located. Depends on the
#' type of data (catch or bds) and era (recent, mrfss, or historical). Default
#' value is for recent catch data (RECFIN_YEAR).
#' Coded to accept a vector of names where the same type or era of data has
#' multiple different names. When multiple names within the vector are in the
#' dataset, picks the first.
#'

getYear <- function(
  data,
  source = c("RECFIN_YEAR"),
  verbose = TRUE
) {
  if (!any(source %in% colnames(data))) { #
    cli::cli_inform("The column {source} was not found in the data.
                    Year information has not been standardized")
  }
  if (!"remove" %in% colnames(data)) {
    data$remove <- "no"
  }

  # To avoid having to pick a unique field name for every data type and era,
  # if source is a vector, pick the first field among those in the vector
  # that exist in the data.
  source <- source[which(source %in% colnames(data))[1]]

  data$year <- data[, source]

  noyear <- sum(is.na(data$year))
  data[is.na(data$year), "remove"] <- "year"

  if (verbose) {
    cli::cli_bullets(c(
      " " = "{.fn getYear} summary information -",
      "i" = "There were {noyear} records missing a year in {.field {source}}, flagged for removal.",
      ""
    ))
  }

  # Flag records in 1999-2000 for Oregon recent bds data because these years
  # overlap in time with MRFSS bds data, and occurred under a different sampling
  # protocol than later years (2001-current).
  if (source == "RECFIN_YEAR" &
    "RECFIN_LENGTH_MM" %in% colnames(data)) {
    removed <- which(data$RECFIN_YEAR %in% c(1999, 2000) & data$STATE_NAME == "OREGON")
    data[removed, "remove"] <- "year"

    nrem <- length(removed)

    if (verbose) {
      cli::cli_bullets(c(
        "i" = "There were {nrem} Oregon ORBS records from 1999-2000 flagged for removal
        because they were sampled under different protocols than later years,
        and overlap with early (MRFSS) sampling efforts.",
        ""
      ))
    }
  }

  # Flag records in 2001-2003 for Oregon MRFSS bds data because these years
  # overlap in time with recent bds data sampling efforts, and cannot distinguish
  # whether the same or different fish were sampled.
  if (source == "YEAR" &
    "ID_CODE" %in% colnames(data)) {
    removed <- which(data$YEAR > 2000 & data$ST == 41)
    data[removed, "remove"] <- "year"

    nrem <- length(removed)

    if (verbose) {
      cli::cli_bullets(c(
        "i" = "There were {nrem} Oregon MRFSS records from 2001-2003 flagged for removal
        because they overlap with recent (ORBS) sampling efforts.",
        ""
      ))
    }
  }

  return(data)
}
