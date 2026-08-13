#' Create a year column based on input column specified in `source` and filters
#' out some unused records
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
#' `year` after extraction.
#' 
#' @section Oregon MRFSS bds data: 
#' Oregon MRFSS bds data extend through 2003 in SD509. ORBS sampling also
#' occurred in 2001-2003 and duplication occurred. There is no current way to 
#' determine which samples were duplicates. Therefore MRFSS bds data in 2001-2003
#' is removed using this function.
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

  # To avoid having to pick a unique field name for every data type and era,
  # if source is a vector, pick the first field among those in the vector
  # that exist in the data.
  source <- source[which(source %in% colnames(data))[1]]

  data$year <- data[, source]

  noyear <- sum(is.na(data$year))

  if (verbose) {
    cli::cli_bullets(c(
      " " = "{.fn getState} summary information -",
      "i" = "There are {noyear} records for which the year is NA"
    ))
  }
  
  #Remove records in 2001-2003 for Oregon MRFSS bds data because these years 
  #overlap in time with recent bds data sampling efforts, and cannot distinguish
  #whether the same or different fish were sampled. 
  if(source == "YEAR" & 
     "ID_CODE" %in% colnames(data)) {
    
    removed <- which(data$YEAR > 2000 & data$ST == 41)
    data <- data[-removed,]
    
    nrem <- length(removed)
    
    if (verbose) {
      cli::cli_bullets(c(
        "i" = "There were {nrem} Oregon MRFSS records removed from 2001-2003 
        because they overlap with recent (ORBS) sampling efforts."
      ))
    }
    
    
  }

  return(data)
}
