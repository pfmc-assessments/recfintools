#' Clean RecFIN data
#'
#' Clean RecFIN data to provide data in a similar format with consistent
#' column names and values. For example, states are standardized to be
#' state abbreviations rather than single letters or full names and are
#' available in the column called `state`.
#' 
#' @param data A loaded Rdata object from pull_catch_recfin_.  
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
#'
#' @export
#' @author Brian Langseth and Kelli Faye Johnson
#' @return A data frame with standardized columns.
#' @seealso See the data object `recfin_coldefs` for more complete descriptions of
#' column names and their contents.
#'
clean_catch <- function(data) {
  
  type = NULL
  
  #Historical data
  if(is.list(data)) {
    type = "hist"
    
    #Repeat for each state
    for(i in 1:length(data)){
      #colnames(data[[i]]) <- gsub("RECFIN_", "", colnames(data[[i]])) #Probably dont keep this in
    }

  }
  
  #MRFSS data
  if("SERVER_PATH" %in% colnames(data)) {
    type = "mrfss"
    
  }
  
  #Recent data
  if("RECFIN_YEAR" %in% colnames(data)) {
    type = "recfin"
    #colnames(data) <- gsub("RECFIN_", "", colnames(data)) #Probably dont keep this in
    
    #Rename state
    data <- getState(data = data,
                     source = c("AGENCY", "STATE_NAME"), #AGENCY is in CTE001, STATE_NAME in CTE501
                     verbose = TRUE)
    
    
    
  }
  
  # # Report removals
  # if (verbose) {
  #   narea <- sum(bad[, "badarea"])
  #   ntype <- sum(bad[, "badstype"])
  #   nmethod <- sum(bad[, "badsmeth"])
  #   nnumber <- sum(bad[, "badsno"])
  #   nstate <- sum(bad[, "badstate"])
  #   ngear <- sum(bad[, "badgear"])
  #   nlength <- sum(is.na(data$lengthmm))
  #   nage <- sum(is.na(data$Age))
  #   nlenage <- sum(is.na(data$lengthmm) & is.na(data$Age))
  #   nclean <- NROW(data) - sum(bad[, "remove"])
  #   nremoved <- sum(bad[, "remove"])
  #   
  #   cli::cli_bullets(c(
  #     " " = "Summary of data processing and cleaning checks:",
  #     " " = "The following records would be removed if clean = TRUE. Users should inspect these records to make sure that those record should be removed from the cleaned data or if the keep arguments should be revised.",
  #     " " = "The number of records potentially removed for the various reasons below if clean = TRUE are not mutually exclusive.",
  #     "!" = "Number of records not in federal waters: {narea}",
  #     "!" = "Number of records not in keep_sample_type (SAMPLE_TYPE): {ntype}",
  #     "!" = "Number of records not in keep_sample_method (SAMPLE_METHOD_CODE): {nmethod}",
  #     "!" = "Number of records without SAMPLE_NUMBER: {nnumber}",
  #     "!" = "Number of records not in keep_states: {nstate}",
  #     "!" = "Number of records not in keep_gears: {ngear}",
  #     "!" = "Number of records without length and Age: {nlenage}",
  #     "i" = "Number of records remaining if clean = TRUE: {nclean}",
  #     "i" = "Number of records removed if clean = TRUE: {nremoved}"
  #   ))
  #   
  #   if (check_pacfin_species_code_calcom(data$PACFIN_SPECIES_CODE)) {
  #     if (!check_calcom) {
  #       cli::cli_alert_danger(
  #         "Additional biological data are available from CALCOM for flatfish species pre-1990, please contact E.J. (edward.dick@noaa.gov) and Brenda (BErwin@psmfc.org)."
  #       )
  #     }
  #   }
  # }
  # 
  # clean_vector <- ifelse(
  #   bad[, "remove"] == TRUE,
  #   yes = FALSE,
  #   no = TRUE
  # )
  # data[, "clean"] <- clean_vector
  # if (clean) {
  #   data <- data[clean_vector, ]
  # }
  
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
