#' Create a length_cm column based on input column specified in `source`.
#'
#' @details
#' This function is used for only composition data. It creates a new column
#' in units of cm, and also flags lengths beyond max, as well as total length
#' measurements (as opposed to fork length) or of measurements not directly 
#' measured. Removes lengths with NA or 0
#'
#' @section Length extraction rules:
#' `source` can be a vector of candidate column names. The first matching
#' column in `data` is used.
#'
#' The selected source column is copied directly into a standardized `length_cm`
#' column. The units are cm and adjusted based on whether the input source
#' column includes mm or cm. Extreme length values are flagged but not removed,
#' as are measurements in total length for recent data. MRFSS data have separate
#' columns for fork length (LNGTH) or total length (T_LEN). Lengths that are NA 
#' or 0 are removed.
#'
#' If `verbose = TRUE`, the function reports how many records with unknown or 0
#' length were removed, along with a message conveying the number of extreme
#' lengths that were kept, and number of total length measurements.
#'
#' @export
#' @seealso [clean_catch()] calls 'getLength'
#'
#' @inheritParams clean_bds
#'
#' @param source Column name where length information is located. Depends on the
#' era (recent, mrfss). Default value is for recent catch data
#' (RECFIN_LENGTH_MM). Coded to accept a vector of names where the same era of 
#' data has multiple different names. When multiple names within the vector are 
#' in the dataset, picks the first.
#'

getLength <- function(
  data,
  source = c("RECFIN_LENGTH_MM"),
  verbose = TRUE
) {
  if (!any(source %in% colnames(data))) { #
    cli::cli_inform("The column {source} was not found in the data.
                    Length information has not been standardized")
  }

  source <- source[which(source %in% colnames(data))[1]]

  removed <- data |>
    dplyr::filter(is.na(.data[[source]]) | .data[[source]] == 0)

  data <- data |>
    dplyr::filter(!is.na(.data[[source]]) | .data[[source]] != 0)
  
  
  #Recent bds data
  if(source == "RECFIN_LENGTH_MM"){

    # Add new column 'length_cm' based on units in source
  
    if (grepl("mm", tolower(source))) {
      data$length_cm <- data[, source] / 10
    } else if (grepl("cm", tolower(source))) {
      data$length_cm <- data[, source]
    }
  
    # Count number of lengths with NA removed, number outside Max, and number of
    # lengths with total length
    nolen <- nrow(removed)
    outmax <- sum(!data[, "IS_AGENCY_LENGTH_WITHIN_MAX"])
    lentype <- sum(data[, "RECFIN_LENGTH_TYPE"] == "TOTAL")
  
    if (verbose) {
      cli::cli_bullets(c(
        " " = "{.fn getLength} summary information -",
        "i" = "There are {nolen} records where length was NA or 0 and were removed",
        "i" = "NOTE: there are {outmax} records flagged as being outside the
        maximum length for the species. The user should decide how to handle these",
        "i" = "NOTE: there are {lentype} records flagged as being total length as
        opposed to fork length, which only is specified for Washington. The user 
        should decide how to handle these"
      ))
    }
  }
  
  #MRFSS bds data
  if(source %in% c("LNGTH", "T_LEN")){
    
    # Both are in mm so convert to cm
    data$length_cm <- data[, source] / 10
    
    # Count number of lengths with NA or 0 removed
    # Note that LENFLAG only occurs in 2004 (for CRFS samples)
    nolen <- nrow(removed)
    
    if(source == "LNGTH") {
      #ltype = "fork length" #source length type
      other_l = "T_LEN" #the other length measurement
      #other_ltype = "total length" #the other length measurement type
    }
    if(source == "T_LEN") {
      #ltype = "total length" #source length type
      other_l = "LNGTH" #the other length measurement
      #other_ltype = "fork length" #the other length measurement
    }
    
    if (verbose) {
      cli::cli_bullets(c(
        " " = "{.fn getLength} summary information -",
        "i" = "There are {nolen} records where length was NA or 0 and were removed",
        "i" = "NOTE: There are records where {source} was likely derived from 
        empirical relationships from another measurement, either from {other_l} or
        WGT. This can be inferred based on the number of decimal places. 
        The user should decide how to handle these by checking the number of
        decimals of {source} compared to {other_l} or WGT. For applications 
        where precision is important, such as for W-L or growth relationships, 
        only direct measured samples are encouraged. For compositions, where
        imprecision in the empirical relationship is likely to be less than the 
        bin size used, measurements obtained from conversions are likely suitable."
      ))
    }
  }
  

  return(data)
}
