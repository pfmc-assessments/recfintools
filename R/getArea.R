#' Filter out records from Puget Sound, Canada, Mexico, or unknown areas based 
#' on input column specified in `source`. 
#' 
#' 
#' @details
#' This function is used for both catch and composition data. Because the case
#' for values are sometimes different across data sets, fields with values as 
#' character strings are converted to lowercase when filtering.
#' Based on similar function from pacfintools, but modified for recreational data
#'
#' @section Area filtering rules:
#' Values in `source` are evaluated using case-insensitive matching.
#'
#' For recent RecFIN data (`source = "RECFIN_WATER_AREA_NAME"`), records are
#' removed when area is:
#' * `CANADA`
#' * `MEXICO`
#' * `PUGET SOUND`
#'
#' For Washington historical data (`source = "AREA"` and `AGENCY == "W"`),
#' records with `AREA >= 5` are removed.
#'
#' If `verbose = TRUE`, the function reports the number of records removed by
#' category.
#' 
#' @export
#' @seealso [clean_catch()] calls 'getArea'
#' 
#' @inheritParams clean_catch
#' 
#' @param source Column name where area information is located. Depends on the 
#' type of data (catch or bds) and era (recent, mrfss, or historical). 
#' Coded to accept a vector of names where the same type or era of data has 
#' multiple different names. When multiple names within the vector are in the 
#' dataset, picks the first.
#' For recent catch data, use `RECFIN_WATER_AREA_NAME`, which filters out values
#' of Canada, Mexico, and Puget Sound. Areas with `Not Known` are kept. 
#' For Washington historical catch data, uses `AREA`, which filters out values
#' of 5 and greater (i.e. Puget Sound)
#' For all other data sets, use any valid column, since for these areas no 
#' specific records outside federal waters are identifiable. 
#' 

getArea <- function(
    data,
    source = c("RECFIN_WATER_AREA_NAME"),
    verbose = TRUE
) {
  
  if (!any(source %in% colnames(data))) { #
    cli::cli_inform("The column {source} was not found in the data.
                    Records outside federal waters have not been removed")
  }
  
  source <- source[which(source %in% colnames(data))[1]]
  
  flag <- FALSE
  
  if(source == "RECFIN_WATER_AREA_NAME"){ #Recent catch data
  
    nonfed <- c("CANADA",
                "MEXICO",
                "PUGET SOUND")
    
    removed <- data |>
      dplyr::filter(tolower(.data[[source]]) %in% tolower(nonfed))
    data <- data |> 
      dplyr::filter(!tolower(.data[[source]]) %in% tolower(nonfed))
      
    noarea <- nrow(removed)
    nsound <- sum(tolower(removed[,source]) == tolower(nonfed[3]))
    ncan <- sum(tolower(removed[,source]) == tolower(nonfed[1]))
    nmex <- sum(tolower(removed[,source]) == tolower(nonfed[2]))
    nunk <- sum(is.na(data[,source]))
    
    if (verbose) {
      cli::cli_bullets(c(
        " " = "{.fn getArea} summary information -",
        "i" = "There are {noarea} records outside federal waters and were removed.",
        "i" = "These include {ncan} records from Canada",
        "i" = "These include {nmex} records from Mexico",
        "i" = "These include {nsound} records from Puget Sound",
        "i" = "There are {nunk} records designated as Not Known that were kept."
      ))
    }
    
    flag <- TRUE
    
  }
  
  if(source == "AREA" & 
     all(data$AGENCY == "W") & #Washington historical catch data
     length(data$AGENCY > 0)){ #Ensure AGENCY exists (if not 'all' returns TRUE)

    removed <- data |>
      dplyr::filter(.data[[source]] >= 5)
    data <- data |> 
      dplyr::filter(!.data[[source]] >= 5)
    
    noarea <- nrow(removed)
    nsound <- noarea
    ncan <- nmex <- 0
    nna <- sum(is.na(data[,source]))

    
    if (verbose) {
      cli::cli_bullets(c(
        " " = "{.fn getArea} summary information -",
        "i" = "There are {noarea} records outside federal waters and were removed.",
        "i" = "These include {ncan} records from Canada",
        "i" = "These include {nmex} records from Mexico",
        "i" = "These include {nsound} records from Puget Sound",
        "i" = "There are {nna} records without {source} that were kept."
      ))
    }
    
    flag <- TRUE
  }
  
  if(!flag){
    cli::cli_inform("No adjustments to {source} were made. No records outside 
                    of federal waters were identified")
  }
  
  return(data)
}
