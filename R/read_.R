#' Read catch estimate and total mortality reports, i.e., 'CTE501'
#'
#' Read in a MRFSS file containing catch estimates and total mortality reports.
#' Read in RecFIN data
#'
#' Read in an excel file that contains information from RecFIN.
#'
#' @section cte501:
#' Estimates of recent catches.
#'
#' @section mrfss:
#' Estimates of catches from thes
#' Marine Recreational Fisheries Statistics Survey (MRFSS).
#' Catches are for the years between 1980 and approximately 2003
#' for all three states.
#'
#' @template file
#'
#' @author Kelli Faye Johnson
#' @export
#' @return A data frame.
#'
read_cte501 <- function(file) {
  data <- utils::read.csv(file)

  datacleaned <- clean_cte501(data)

  return(datacleaned)
}

#' @export
#' @rdname read_cte501
#'
read_mrfss <- function(file) {
  data <- utils::read.csv(file)

  datacleaned <- clean_mrfss(data)
  return(datacleaned)
}
