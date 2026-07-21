#' Clean RecFIN data
#'
#' Clean RecFIN data to provide data in a similar format with consistent
#' column names and values. For example, states are standardized to be
#' state abbreviations rather than single letters or full names and are
#' available in the column called `state`.
#' 
#' @param data A loaded Rdata object from pull_catch_recfin_ or
#' pull_bds_recfin_.  
#' @param verbose Whether to output detailed information about the cleaning process. Default is TRUE.
#'
#' @section Missing years:
#' MRFSS data is incomplete and will not contain information for the years
#' 1990 to 1992. Most often, linear interpolation is performed to estimate
#' catches during these years because it can be assumed that they were not
#' zero if the surrounding years were also non-zero.
#' 
#' MRFSS sampling for PC modes in 1993-1995 was limited. PC sampling in CA 
#' restarted in 1993 only in Southern districts; north of San Luis Obispo it 
#' restarted in 1996. Some type of interpolation can be done to update PC 
#' estimates during these years. These years will show up with some catch, 
#' but only when broken down by mode will it be obvious that PC is lower than 
#' in neighbor years.
#' 
#' #' todo: create a function to estimate catches for 1990-1992, possibly 1993-1995?  
#' 
#' @section Washington data:
#' Washington does not use MRFSS catch data. Rather, catches come from apex 
#' report for recent data (CTE001 or CTE501), which extend back to 1990, and 
#' from historical reconstructions (CTE503), which although extend through 2002, 
#' have values for coastal areas 1-4 (i.e. non-puget sound areas) only through 
#' 1989. When running this function, Washington catch data are removed from the 
#' MRFSS dataset, and puget sounds areas (5+) are removed from the historical 
#' dataset. 
#'
#' Washington does not differentiate by mode in its historical reconstruction.
#' Therefore, when running getMode() all records are assigned as 'UNK'. 
#' 
#' todo: create a function to estimate Washington weights for recent and historical?
#' 
#' @section Oregon data:
#' Oregon does not use MRFSS catch data. Rather, catches come from apex report 
#' for recent data (CTE001 or CTE501), which extend back to 2001, and from 
#' historical reconstructions (CTE505), which extend through 2000. When running 
#' this function, Oregon catch data are removed from the MRFSS dataset. 
#'
#' @inheritSection getState State mapping rules
#' @inheritSection getMode Mode mapping rules
#' @inheritSection getArea Area filtering rules
#' @inheritSection getYear Year extraction rules
#'
#' @import dplyr
#'
#' @export
#' @author Brian Langseth and Kelli Faye Johnson
#' @return A data frame with standardized columns along with original fields. 
#' See the data object `recfin_coldefs` for more complete descriptions of
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
      
      ##
      #For just catches
      ##
      
      ##
      #For catches and biological data
      ##
      
      ## Standardize fields
      
      #Rename state
      data[[i]] <- getState(data = data[[i]],
                       source = c("AGENCY"),
                       verbose = TRUE)
      
      #Rename modes
      #Washington doesn't include any mode type in their historical reconstruction.
      #To avoid an error when calling this for OR and CA, which do, use any 
      #field name in the WA historical data and 'mode' will be assigned as UNK
      data[[i]] <- getMode(data = data[[i]],
                      source = c("RECFIN_MODE_NAME", "AGENCY"),
                      verbose = TRUE)
      
      
      #Set up year column
      data[[i]] <- getYear(data = data[[i]],
                      source = c("YEAR", "RECFIN_YEAR"), #YEAR is for OR and CA, RECFIN_YEAR is for WA
                      verbose = TRUE)
      
      
      ## Actually removing data
      
      #to do: Add function to clean up confusing columns
      
      #Remove records in non-federal areas
      data[[i]] <- getArea(data = data[[i]], 
                      source = c("AREA"),
                      verbose = TRUE)
      
      
      ## Calculating catches
      
    }

  }
  
  #MRFSS data
  if("SERVER_PATH" %in% colnames(data)) {
    type = "mrfss"
    
    ##
    #For just catches
    ##
    
    ##
    #For catches and biological data
    ##
    
    ## Standardize fields
    
    #Rename state
    data <- getState(data = data,
                     source = c("ST"),
                     verbose = TRUE)
    
    ## Actually removing data
    
    #Filter out Oregon and Washington records because they dont use MRFSS data
    data <- data |>
      dplyr::filter(!state %in% c("OR","WA"))
    
    
    
    
    
  }
  
  #Recent data
  if("RECFIN_YEAR" %in% colnames(data)) {
    type = "recfin"
    #colnames(data) <- gsub("RECFIN_", "", colnames(data)) #Probably dont keep this in
    
    ##
    #For just catches
    ##
    
    #Check whether catch in numbers have non-zero catches in weight
    data <- check_catch(data = data,
                        source = c("RETAINED", "RELEASED_ALIVE", "RELEASED_DEAD"),
                        verbose = TRUE)
    
    ##
    #For catches and biological data
    ##
    
    ## Standardize fields
    
    #Rename state
    data <- getState(data = data,
                     source = c("AGENCY", "STATE_NAME"), #AGENCY is in CTE001, STATE_NAME in CTE501
                     verbose = TRUE)
    
    #Rename modes
    data <- getMode(data = data,
                    source = c("RECFIN_MODE_NAME"),
                    verbose = TRUE)
    
    #Set up year column
    data <- getYear(data = data,
                    source = c("RECFIN_YEAR"),
                    verbose = TRUE)
    
    
    ## Actually removing data
    
    #Filter out non-federal records
    data <- getArea(data = data,
                    source = c("RECFIN_WATER_AREA_NAME"),
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
