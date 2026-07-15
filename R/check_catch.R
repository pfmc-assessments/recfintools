#' Alert user of whether catches records for weight are missing but catches in
#' number exist. 
#' 
#' 
#' @details
#' This function is used for catch data. It lets the user know when records have
#' catch in numbers (for retained, released alive, and released dead) but not
#' corresponding weight, andn therefore when the total catch in weight may be off.
#' It is up to the user to decide how to use this information. 
#' This function also confirms that the total mortality is the sum of retained 
#' and released dead.
#' 
#' 
#' @export
#' @seealso [clean_] calls 'check_catch'
#' 
#' @inheritParams clean_
#' 
#' @param data Catch data from pull_bds_recfin or pull_catch_recfin
#' @param source Column name where the information is located. Depends on the 
#' type of data (catch or bds) and era (recent, mrfss, or historical). Default
#' value is for recent catch data (i.e. SUM_RETAINED_, SUM_RELEASED_ALIVE_,
#' SUM_RELEASED_DEAD_)
#' @param verbose Whether to output detailed information about variable.
#' Default is TRUE.
#' 

check_catch <- function(
    data,
    source = c("RETAINED", "RELEASED_ALIVE", "RELEASED_DEAD"),
    verbose = TRUE
) {
  
  if (!any(source %in% colnames(data))) { #
    cli::cli_inform("The column {source} was not found in the data.
                    Enter different column names")
  }
  
  fullSource <- paste0("SUM_", source, rep(c("_MT", "_NUM"), length(source)))
  
  cols <- data[, colnames(data) %in% fullSource]
  
  cols$dead_mt <- rowSums(data[, c("SUM_RETAINED_MT", "SUM_RELEASED_DEAD_MT")], na.rm = TRUE)
  
  if (!all.equal(cols$dead_mt, data$SUM_TOTAL_MORTALITY_MT, tolerance = 1e-5)) {
    cli::cli_inform("The sum of total mortality does not equal the sum of retained 
                    and released dead mortality.")
  }
      
  retainOff <- length(which(cols$SUM_RETAINED_MT == 0 & cols$SUM_RETAINED_NUM > 0))
  releaseOff <- length(which(cols$SUM_RELEASED_ALIVE_MT == 0 & cols$SUM_RELEASED_ALIVE_NUM > 0))
  deadOff <- length(which(cols$SUM_RELEASED_DEAD_MT == 0 & cols$SUM_RELEASED_DEAD_NUM > 0))
  
  
  if (verbose) {
    cli::cli_bullets(c(
      " " = "{.fn check_catch} summary information -",
      "i" = "There are {retainOff} records where retained catches are reported
      in numbers but have no weight",
      "i" = "These include {releaseOff} records where released alive catches are 
      reported in numbers but have no weight",
      "i" = "These include {deadOff} records where released dead catches are 
      reported in numbers but have no weight",
      "These should be looked at by the user to determine how to handle"
    ))
  }
  
  return(data)
}
