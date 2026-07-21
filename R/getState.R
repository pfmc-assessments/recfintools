#' Create a state column based on input column specified in `source`
#' 
#' @details
#' Copied from pacfintools, and modified for recreational data
#' This function is used for both catch and composition data
#'
#' @section State mapping rules:
#' `source` can be a vector of candidate column names. The first matching
#' column in `data` is used.
#'
#' Values are standardized into `state` as:
#' * `WA`: `WASHINGTON`, `W`, or `53`
#' * `OR`: `OREGON`, `O`, or `41`
#' * `CA`: `CALIFORNIA`, `C`, or `6`
#' * `UNK`: all unmatched values
#'
#' If `verbose = TRUE`, the function reports how many records were assigned
#' `UNK`.
#' 
#' @export
#' @seealso [clean_catch()] calls 'getState'
#' 
#' @inheritParams clean_catch
#' 
#' @param source Column name where state information is located. Depends on the 
#' type of data (catch or bds) and era (recent, mrfss, or historical). Default
#' value is for recent catch data (i.e. AGENCY for CTE001 or STATE_NAME for CTE501).
#' Coded to accept a vector of names where the same type or era of data has 
#' multiple different names. When multiple names within the vector are in the 
#' dataset, picks the first.
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
      .data[[source]] == "53" ~ "WA", #ST
      .data[[source]] == "41" ~ "OR", #ST
      .data[[source]] == "6" ~ "CA", #ST
      
      TRUE ~ "UNK"
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