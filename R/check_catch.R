#' Alert user of whether catches records for weight are missing but catches in
#' number exist. 
#' 
#' 
#' @details
#' This function is used for catch data. It lets the user know when records have
#' catch in numbers (for retained, released alive, and released dead) but not
#' corresponding weight, and therefore when the total catch in weight may be off.
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
#' @param source Column keywords where the information is located. Depends on the 
#' type of data (catch or bds) and era (recent, mrfss, or historical). Default
#' value is for recent catch data (i.e. RETAINED_, RELEASED_ALIVE_,
#' RELEASED_DEAD_). The functions searches for teh columns that contain these words. 
#' @param verbose Whether to output detailed information about variable.
#' Default is TRUE.
#' 
#' #Not really useing source as fully user defined. Consider removing

check_catch <- function(
    data,
    source = c("RETAINED", "RELEASED_ALIVE", "RELEASED_DEAD"),
    verbose = TRUE
) {
  
  cols <- colnames(data)[
    intersect(
      grep(paste(source, collapse = "|"), colnames(data)),
      grep("MT|NUM", colnames(data)))
  ]

  if (length(cols) == 0) { #
    cli::cli_inform("The column {source} was not found in the data.
                    Enter different column names")
  }
  
  fullcols <- data[, colnames(data) %in% cols]
  
  
  #Determine whether retained + released dead = total (only for MT)
  
  deadcols <- grep(c("RETAINED_MT|RELEASED_DEAD_MT"), colnames(fullcols))
  
  fullcols$dead_mt <- rowSums(fullcols[, deadcols], na.rm = TRUE)
  
  if (!all.equal(fullcols$dead_mt, data[,grep("TOTAL_MORTALITY_MT", colnames(data))], tolerance = 1e-5)) {
    cli::cli_inform("The sum of total mortality does not equal the sum of retained 
                    and released dead mortality.")
  }
  
  #Deteremine the number of records were numbers exist but weigts are zero
  
  retainOff <- length(
    which(fullcols[, grep("RETAINED_MT", colnames(fullcols))] == 0 & 
            fullcols[, grep("RETAINED_NUM", colnames(fullcols))] > 0))
  releaseOff <- length(
    which(fullcols[, grep("RELEASED_ALIVE_MT", colnames(fullcols))] == 0 & 
            fullcols[, grep("RELEASED_ALIVE_NUM", colnames(fullcols))] > 0))
  deadOff <- length(
    which(fullcols[, grep("RELEASED_DEAD_MT", colnames(fullcols))] == 0 & 
            fullcols[, grep("RELEASED_DEAD_NUM", colnames(fullcols))] > 0))
  
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
