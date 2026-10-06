#' Clean RecFIN data
#'
#' Clean RecFIN data to provide data in a similar format with consistent
#' column names and values, and data prepared and ready for analysis.
#' For example, states are standardized to be state abbreviations rather than
#' single letters or full names and are available in the column called `state`,
#' or Canada, Mexico, and Puget Sound records are removed.
#'
#' This function also removes unsuitable data provided `clean = TRUE` (default).
#' If `clean = FALSE` all data are retained along with an additional column
#' "remove" that is populated with the function where data would be removed.
#' Using `clean = FALSE` is for exploration purposes only and is NOT RECOMMENDED
#' for final use within US West Coast assessments.
#'
#' @param data A loaded Rdata object from pull_catch_recfin_ or
#' pull_bds_recfin_.
#' @param clean A logical value used when you want to remove data from the input
#' data set. The default is `TRUE`, where the opposite returns the data
#' with additional columns and reports on what would have been removed.
#' @param verbose Whether to output detailed information about the cleaning
#' process. Default is TRUE.
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
#' Currently, these years are not filled in and it is up to the user to
#' decide how best to fill.
#'
#' #' todo: create a function to estimate catches for 1990-1992, possibly 1993-1995?
#'
#' @section Washington data:
#' Washington does not use MRFSS catch data. Rather, catches come from apex
#' reports for recent data (CTE001 or CTE501), which extend back to 1990, and
#' from historical reconstructions (CTE503), which although extend through 2002,
#' have values for coastal areas 1-4 (i.e. non-puget sound areas) only through
#' 1989. When running this function, Washington catch data are removed from the
#' MRFSS dataset, and Puget Sound areas (5+) are removed from the historical
#' dataset.
#'
#' Washington does not differentiate by mode in its historical reconstruction.
#' Therefore, when running getMode() all records are assigned as 'UNK'.
#'
#' Washington also does not have dead discard estimates from 1990-2004. Mortality
#' in these years is only of retained fish. Consider applying estimates for
#' discard amounts based on conversations with Washington.
#'
#' todo: create a function to estimate Washington weights for recent and historical?
#'
#' @section Oregon data:
#' Oregon does not use MRFSS catch data. Rather, catches come from apex reports
#' for recent data (CTE001 or CTE501), which extend back to 2001, and from
#' historical reconstructions (CTE505), which extend through 2000. When running
#' this function, Oregon catch data are removed from the MRFSS dataset.
#'
#' Oregon historical catches are provided in numbers. When running this function,
#' average weights are calculated that can be used to determine catch in weight.
#'
#' @section California data:
#'
#' @seealso [clean_bds()]
#'
#' @inheritSection getState State mapping rules
#' @inheritSection getMode Mode mapping rules
#' @inheritSection getArea Area filtering rules
#' @inheritSection getYear Year extraction rules
#' @inheritSection getWeightHist Oregon Historical weights
#'
#' @import dplyr
#'
#' @export
#' @author Brian Langseth
#' @return A data frame with standardized columns along with original and
#' added fields.
#' See the data object `recfin_coldefs` for more complete descriptions of
#' column names and their contents.
#'
clean_catch <- function(data,
                        clean = TRUE,
                        verbose = TRUE) {
  type <- NULL

  # Historical data
  if (class(data) == "list") {
    type <- "hist"

    # Repeat for each state
    for (i in 1:length(data)) {
      ##
      # For just catches
      ##

      ## Standardize fields

      # Rename state
      data[[i]] <- getState(
        data = data[[i]],
        source = c("AGENCY"),
        verbose = verbose
      )

      # Rename modes
      # Washington doesn't include any mode type in their historical reconstruction.
      # To avoid an error when calling this for OR and CA, which do, use any
      # field name in the WA historical data and 'mode' will be assigned as UNK
      data[[i]] <- getMode(
        data = data[[i]],
        source = c("RECFIN_MODE_NAME", "AGENCY"),
        verbose = verbose
      )

      # Set up year column
      data[[i]] <- getYear(
        data = data[[i]],
        source = c("YEAR", "RECFIN_YEAR"), # YEAR is for OR and CA, RECFIN_YEAR is for WA
        verbose = verbose
      )


      ## Actually removing data

      # to do: Add function to clean up confusing columns

      # Remove records in non-federal areas. Only applicable for Washington
      # Note that for Oregon or California, there are no records outside federal waters.
      # Still call this (because need for WA) but this does nothing for OR or CA
      data[[i]] <- getArea(
        data = data[[i]],
        source = c("AREA", "RECFIN_DISTRICT_NAME", "SURVEY_PROGRAM_AREA_NAME"), # AREA for WA, Recfin_district_name for OR, SURVEY_PROGRAM_AREA_NAME for CA
        verbose = verbose
      )


      ## Adding columns

      # Add calculated weight column
      data[[i]] <- getWeightHist(
        catch_data = data[[i]],
        bds_data = sd509_data,
        state = unique(data[[i]]$state),
        figure = TRUE
      )


      cli::cli_inform("Done cleaning historical catches")
    }
  }

  # MRFSS data
  if ("SERVER_PATH" %in% colnames(data)) {
    type <- "mrfss"

    ##
    # For just catches
    ##

    ## Standardize fields

    # Rename state
    data <- getState(
      data = data,
      source = c("ST"),
      verbose = verbose
    )

    # Rename modes
    data <- getMode(
      data = data,
      source = c("MODE"),
      verbose = verbose
    )

    # Set up year column
    data <- getYear(
      data = data,
      source = c("YEAR"),
      verbose = verbose
    )


    ## Actually removing data

    # Filter out Oregon and Washington records because they don't use MRFSS data
    data <- data |>
      dplyr::filter(!state %in% c("OR", "WA"))


    # Filter out non-federal records
    data <- getArea(
      data = data,
      source = c("AREA_X"),
      verbose = verbose
    )


    cli::cli_inform("Done cleaning MRFSS catches")
  }

  # Recent data
  if ("RECFIN_YEAR" %in% colnames(data)) {
    type <- "recfin"

    ##
    # For just catches
    ##

    # Check whether catch in numbers have non-zero catches in weight
    data <- check_catch(
      data = data,
      source = c("RETAINED", "RELEASED_ALIVE", "RELEASED_DEAD"),
      verbose = verbose
    )

    ## Standardize fields

    # Rename state
    data <- getState(
      data = data,
      source = c("AGENCY", "STATE_NAME"), # AGENCY is in CTE001, STATE_NAME in CTE501
      verbose = verbose
    )

    # Rename modes
    data <- getMode(
      data = data,
      source = c("RECFIN_MODE_NAME"),
      verbose = verbose
    )

    # Set up year column
    data <- getYear(
      data = data,
      source = c("RECFIN_YEAR"),
      verbose = verbose
    )


    ## Actually removing data

    # Filter out non-federal records
    data <- getArea(
      data = data,
      source = c("RECFIN_WATER_AREA_NAME"),
      verbose = verbose
    )

    cli::cli_inform("Done cleaning recent catches")
  }

  # Report removals and remove cleaned records provided clean == "TRUE"
  if (type == "hist") {
    narea <- nyear <- nstate <- nclean <- nlength <- nremoved <- clean_vector <- list()
    for (i in 1:length(data)) {
      narea[i] <- sum(data[, remove] %in% "area")
      nyear[i] <- sum(data[, remove] %in% "year")
      nstate[i] <- sum(data[, remove] %in% "state")
      nlength[i] <- sum(data[, remove] %in% "length")
      nclean[i] <- sum(data[, remove] %in% "no")
      nremoved[i] <- sum(!data[, remove] %in% "no")

      if (clean) {
        clean_vector[i] <- ifelse(
          data[i][, "remove"] == "no",
          FALSE,
          TRUE
        )
        data[i] <- data[i][clean_vector[i], ]
      }
    }

    narea <- sapply(narea, sum)
    nyear <- sapply(nyear, sum)
    nstate <- sapply(nstate, sum)
    nclean <- sapply(nclean, sum)
    nremoved <- sapply(nremoved, sum)
  }

  if (type %in% c("recent", "mrfss")) {
    narea <- sum(data[, remove] %in% "area")
    nyear <- sum(data[, remove] %in% "year")
    nstate <- sum(data[, remove] %in% "state")
    nclean <- sum(data[, remove] %in% "no")
    nremoved <- sum(!data[, remove] %in% "no")

    if (clean) {
      clean_vector <- ifelse(
        data[, "remove"] == "no",
        FALSE,
        TRUE
      )
      data <- data[clean_vector[i], ]
    }
  }

  cli::cli_bullets(c(
    " " = "Summary of data processing and cleaning checks:",
    " " = "The following records would be removed if clean = TRUE. Users
    should inspect these records to make sure that those record should be
    removed from the cleaned data or if the keep arguments should be revised.",
    " " = "The number of records potentially removed for the various reasons
    below if clean = TRUE are not mutually exclusive.",
    "!" = "Number of records not in federal waters: {narea}",
    "!" = "Number of records without a year: {nyear}",
    "!" = "Number of records without a state: {nstate}",
    "i" = "Number of records remaining if clean = TRUE: {nclean}",
    "i" = "Number of records removed if clean = TRUE: {nremoved}"
  ))

  return(data)
}


#' Clean RecFIN biological data
#'
#' Clean biological datasets from RecFIN and MRFSS so fields are standardized
#' and prepared for analysis.
#'
#' @param data A loaded R data object from `pull_bds_recfin_`. Can be either
#' length data or age data. 
#' @return A data frame with standardized columns along with original and
#'   added fields.
#'
#' @seealso [getAges()], [clean_catch()]
#'
#' @inheritSection getYear Oregon MRFSS bds data
#' @inheritSection getYear Oregon ORBS bds data
#'
#' @author Brian Langseth and Kelli Faye Johnson
clean_bds <- function(data) {
  type <- NULL

  # Dont have historical bds data

  ## 
  # MRFSS bds data
  ##
  
  if ("SERVER_PATH" %in% colnames(data)) {
    type <- "mrfss"

    ## Standardize fields

    # Rename state
    data <- getState(
      data = data,
      source = c("ST"),
      verbose = verbose
    )

    # Rename modes
    data <- getMode(
      data = data,
      source = c("MODE_FX"),
      verbose = verbose
    )

    # Set up year column
    data <- getYear(
      data = data,
      source = c("YEAR"),
      verbose = verbose
    )


    ## Actually removing data

    # # Filter out Washington records because they don't use MRFSS data
    # # Done below in getArea()
    # data <- data |>
    #   dplyr::filter(!state %in% c("WA"))

    # Filter out non-federal records
    # Also removed Washington records because they don't use MRFSS data
    data <- getArea(
      data = data,
      source = c("AREA_X"),
      verbose = verbose
    )

    # Remove any records without lengths and add length_cm column
    # Flags records beyond max length, and also flags different 'total' length
    data <- getLength(
      data = data,
      source = c("LNGTH"),
      verbose = verbose
    )

    cli::cli_inform("Done cleaning MRFSS bds")
  }

  ##
  # Recent bds length data
  ##
  
  if ("RECFIN_YEAR" %in% colnames(data)) {
    type <- "recfin"

    ## Standardize fields

    # Rename state
    data <- getState(
      data = data,
      source = c("STATE_NAME"),
      verbose = verbose
    )

    # Rename modes
    data <- getMode(
      data = data,
      source = c("RECFIN_MODE_NAME"),
      verbose = verbose
    )

    # Set up year column
    data <- getYear(
      data = data,
      source = c("RECFIN_YEAR"),
      verbose = verbose
    )


    ## Actually removing data

    # Filter out non-federal records
    # Flags other records with certain qualities that warrant further decisions 
    # but not removed by this function.
    data <- getArea(
      data = data,
      source = c("AGENCY_FISHED_AREA_NAME"),
      verbose = verbose
    )

    # Remove any records without lengths and add length_cm column
    # Flags records beyond max length, and also flags different 'total' length
    data <- getLength(
      data = data,
      source = c("RECFIN_LENGTH_MM"),
      verbose = verbose
    )

    # Combine length and age data and remove multiple reads from ages
    temp <- getAges(
      len_data = data,
      age_data = age_data,
      verbose = verbose
    )
    data <- temp$len_data
    age_data <- temp$age_data
    # to do: This is working but still need to figure out why some age data
    # aren't in length data
    # Probably will move this to outside the clean function.

    cli::cli_inform("Done cleaning recent bds length data")
  }
  
  ##
  # Recent bds age data
  ##
  
  if ("SAMPLE_YEAR" %in% colnames(data)) {
    type <- "recfin"
    
    ## Standardize fields
    
    # Rename state
    data <- getState(
      data = data,
      source = c("SAMPLING_AGENCY_NAME"),
      verbose = verbose
    )
    
    # Rename modes
    data <- getMode(
      data = data,
      source = c("RECFIN_MODE_NAME"),
      verbose = verbose
    )
    
    # Set up year column
    data <- getYear(
      data = data,
      source = c("SAMPLING_YEAR"),
      verbose = verbose
    )
    
    
    ## Actually removing data
    
    # Filter out non-federal records
    # Flags other records with certain qualities that warrant further decisions 
    # but not removed by this function.
    data <- getArea(
      data = data,
      source = c("SURVEY_PROGRAM_CATCH_AREA_NAME"),
      verbose = verbose
    )
    
    # Remove multiple reads from ages and ages with NA. While this function can 
    # also combine length and age data, this is not done when NULL is used for 
    # length data
    temp <- getAges(
      len_data = NULL,
      age_data = data,
      verbose = verbose
    )
    data <- temp$age_data
    
    cli::cli_inform("Done cleaning recent bds age data")
  }
  
  

  # Report removals and remove cleaned records provided clean == "TRUE"
  narea <- sum(data[, remove] %in% "area")
  nyear <- sum(data[, remove] %in% "year")
  nstate <- sum(data[, remove] %in% "state")
  nlength <- sum(data[, remove] %in% "length")
  nageNA <- sum(age_data[, remove] %in% "naAge")
  nageMult <- sum(age_data[, remove] %in% "multRead")
  nclean <- sum(data[, remove] %in% "no")
  nremoved <- sum(!data[, remove] %in% "no")

  if (clean) {
    clean_vector <- ifelse(
      data[, "remove"] == "no",
      FALSE,
      TRUE
    )
    data <- data[clean_vector[i], ]
  }


  cli::cli_bullets(c(
    " " = "Summary of data processing and cleaning checks:",
    " " = "The following records would be removed if clean = TRUE. Users
    should inspect these records to make sure that those record should be
    removed from the cleaned data or if the keep arguments should be revised.",
    " " = "The number of records potentially removed for the various reasons
    below if clean = TRUE are not mutually exclusive.",
    "!" = "Number of records not in federal waters: {narea}",
    "!" = "Number of records without a year: {nyear}",
    "!" = "Number of records without a state: {nstate}",
    "!" = "Number of records without length: {nlength}",
    "!" = "Number of age records without a valid age: {nageNA}",
    "!" = "Number of multiple age reads of the same fish: {nageMult}",
    "i" = "Number of records remaining if clean = TRUE: {nclean}",
    "i" = "Number of records removed if clean = TRUE: {nremoved}"
  ))

  return(data)
}
