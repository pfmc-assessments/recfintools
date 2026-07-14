#' Create a state column based on input column specified in `source`
#' 
#' @details
#' Copied from pacfintools, and modified for recreational data
#' This function is used for both catch and composition data
#' 
#' @export
#' @seealso [clean_] calls 'getState'
#' 
#' @inheritParams clean_
#' 
#' @param data Either catch or bds data from pull_bds_recfin or pull_catch_recfin
#' @param source Column name where state information is located. Depends on the 
#' type of data (catch or bds) and era (recent, mrfss, or historical). Default
#' value is for recent catch data (i.e. AGENCY for CTE001 or STATE_NAME for CTE501)
#' @param verbose Whether to output detailed information about variable
#' 

getState <- function(
    data,
    source = c("AGENCY", "STATE_NAME"),
    verbose = TRUE
) {
  
  if (!any(source %in% colnames(data))) { #
    cli::cli_inform("The column {source} was not found in the data.
                    State information has not been standardized")
  }
  
  source <- source[which(source %in% colnames(data))[1]]
 
  data <- data |>
    dplyr::mutate(state = dplyr::case_when(
      .data[[source]] == "C" ~ "CA", #AGENCY
      .data[[source]] == "O" ~ "OR", #AGENCY
      .data[[source]] == "W" ~ "WA", #AGENCY
      .data[[source]] == "CALIFORNIA" ~ "CA", #STATE_NAME
      .data[[source]] == "OREGON" ~ "OR",     #STATE_NAME
      .data[[source]] == "WASHINGTON" ~ "WA", #STATE_NAME
      TRUE ~ NA_character_
    ))
  
  states <- c("WA", "OR", "CA")
  nostate <- sum(!data[, "state"] %in% states)
  
  if (verbose) {
    cli::cli_bullets(c(
      " " = "{.fn getState} summary information -",
      "i" = "There are {nostate} records for which the state (i.e., CA, OR, WA) 
      could not be assigned and were labeled as UNK."
    ))
  }
  
  return(data)
}