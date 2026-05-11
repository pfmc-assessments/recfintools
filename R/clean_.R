#' Clean RecFIN data
#'
#' Clean RecFIN data to provide data in a similar format with consistent
#' column names and values. For example, states are standardized to be
#' state abbreviations rather than single letters or full names and are
#' available in the column called `state`.
#'
#' @section Missing years:
#' MRFSS data is incomplete and will not contain information for the years
#' 1990 to 1992. Most often, linear interpolation is performed to estimate
#' catches during these years because it can be assumed that they were not
#' zero if the surrounding years were also non-zero.
#'
#' todo: create a function to estimate catches for 1990-1922
#'
#' @section AGENCY_CODE:
#' * 6: California
#' * 41: Oregon
#' * 53: Washington
#'
#' @section RECFIN_SUB_REGION_NAME:
#' * Washington: Canada-US border to Washington-Oregon border
#' * Oregon: Washington-Oregon border to Oregon-California border
#' * Northern California: North of Point Conception and south of Oregon-California border
#' * Southern California: South of Point Conception
#'
#' @template data
#' @import dplyr
#' @importFrom magrittr %>%
#'
#' @export
#' @author Kelli Faye Johnson
#' @return A data frame with standardized columns.
#' @seealso See the data object `recfin_coldefs` for more complete descriptions of
#' column names and their contents.
#'
clean_cte501 <- function(data) {
  colnames(data) <- gsub("RECFIN_", "", colnames(data))
  colnames(data)[grep("YEAR", colnames(data))] <- "Year"

  #### STATE_NAME
  data <- data %>%
    mutate(state = case_when(
      STATE_NAME == "CALIFORNIA" ~ "CA",
      STATE_NAME == "OREGON" ~ "OR",
      STATE_NAME == "WASHINGTON" ~ "WA",
      TRUE ~ NA_character_
    ))
  return(data)
}

#' @export
#' @rdname clean_cte501
clean_mrfss <- function(data) {
  #### YEAR
  colnames(data)[grep("^year", colnames(data), ignore.case = TRUE)] <- "Year"

  #### AGENCY_CODE
  # https://www.fisheries.noaa.gov/inport/item/55989
  data <- data %>%
    mutate(state = case_when(
      AGENCY_CODE == 6 ~ "CA",
      AGENCY_CODE == 41 ~ "OR",
      AGENCY_CODE == 53 ~ "WA",
      TRUE ~ NA_character_
    ))

  return(data)
}
