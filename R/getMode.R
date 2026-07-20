#' Create a mode column based on input column specified in `source`
#' 
#' @details
#' This function is used for both catch and composition data
#' 
#' @export
#' @seealso [clean_] calls 'getMode'
#' 
#' @inheritParams clean_
#' 
#' @param data Either catch or bds data from pull_bds_recfin or pull_catch_recfin
#' @param source Column name where mode information is located. Depends on the 
#' type of data (catch or bds) and era (recent, mrfss, or historical). Default
#' value is for recent catch data (RECFIN_MODE_NAME).
#' Coded to accept a vector of names where the same type or era of data has 
#' multiple different names. When multiple names within the vector are in the 
#' dataset, picks the first.
#' @param verbose Whether to output detailed information about variable. 
#' Default is TRUE.
#' 

getMode <- function(
    data,
    source = c("RECFIN_MODE_NAME"),
    verbose = TRUE
) {
  
  if (!any(source %in% colnames(data))) { #
    cli::cli_inform("The column {source} was not found in the data.
                    Mode information has not been standardized")
  }
  
  source <- source[which(source %in% colnames(data))[1]]
  
  data <- data |>
    dplyr::mutate(mode = dplyr::case_when(
      .data[[source]] == "Private/Rental Boats" ~ "PR", #RECFIN_MODE_NAME
      .data[[source]] == "Party/Charter Boats" ~ "PC", #RECFIN_MODE_NAME
      .data[[source]] == "Man-Made/Jetty" ~ "Other", #RECFIN_MODE_NAME
      TRUE ~ "UNK"
    ))
  
  nomode <- sum(data[, "mode"] == "UNK")
  
  if (verbose) {
    cli::cli_bullets(c(
      " " = "{.fn getMode} summary information -",
      "i" = "There are {nomode} records for which the mode (i.e., PR, PC, Other) 
      could not be assigned and were labeled as UNK."
    ))
  }
  
  return(data)
}