#' Create a year column based on input column specified in `source`
#' 
#' @details
#' This function is used for both catch and composition data
#' 
#' @export
#' @seealso [clean_] calls 'getYear'
#' 
#' @inheritParams clean_
#' 
#' @param data Either catch or bds data from pull_bds_recfin or pull_catch_recfin
#' @param source Column name where year information is located. Depends on the 
#' type of data (catch or bds) and era (recent, mrfss, or historical). Default
#' value is for recent catch data (RECFIN_YEAR). 
#' Coded to accept a vector of names where the same type or era of data has 
#' multiple different names. When multiple names within the vector are in the 
#' dataset, picks the first. 
#' @param verbose Whether to output detailed information about variable. 
#' Default is TRUE.
#' 

getState <- function(
    data,
    source = c("RECFIN_YEAR"),
    verbose = TRUE
) {
  
  if (!any(source %in% colnames(data))) { #
    cli::cli_inform("The column {source} was not found in the data.
                    Year information has not been standardized")
  }
  
  #To avoid having to pick a unique field name for every data type and era, 
  #if source is a vector, pick the first field among those in the vector
  #that exist in the data.
  source <- source[which(source %in% colnames(data))[1]]
 
  data$year <- data[,source]
  
  noyear <- sum(is.na(data$year))
  
  if (verbose) {
    cli::cli_bullets(c(
      " " = "{.fn getState} summary information -",
      "i" = "There are {noyear} records for which the year in NA"
    ))
  }
  
  return(data)
}