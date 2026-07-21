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
#' * `NOT KNOWN`
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
#' For recent catch data, use `RECFIN_WATER_AREA_NAME`, which filters out values
#' of Canada, Mexico, Puget Sound, and Not Known. 
#' For Washington historical catch data, use `AREA`, which filters out values
#' of 5 and greater (i.e. Puget Sound)
#' For Oregon historical catch data
#' For California historical catch data  
#' 

getArea <- function(
    data,
    source = c("RECFIN_WATER_AREA_NAME"),
    verbose = TRUE
) {
  
  if (!source %in% colnames(data)) { #
    cli::cli_inform("The column {source} was not found in the data.
                    Records outside federal waters have not been removed")
  }
  
  if(source == "RECFIN_WATER_AREA_NAME"){ #Recent catch data
  
    nonfed <- c("CANADA",
                "MEXICO",
                "PUGET SOUND",
                "NOT KNOWN")
    
    removed <- data |>
      dplyr::filter(tolower(.data[[source]]) %in% tolower(nonfed))
    data <- data |> 
      dplyr::filter(!tolower(.data[[source]]) %in% tolower(nonfed))
      
    noarea <- nrow(removed)
    nsound <- sum(tolower(removed[,source]) == tolower(nonfed[3]))
    ncan <- sum(tolower(removed[,source]) == tolower(nonfed[1]))
    nmex <- sum(tolower(removed[,source]) == tolower(nonfed[2]))
    nunk <- sum(tolower(removed[,source]) == tolower(nonfed[4]))
    
    if (verbose) {
      cli::cli_bullets(c(
        " " = "{.fn getArea} summary information -",
        "i" = "There are {noarea} records outside federal waters and were removed.",
        "i" = "These include {ncan} records from Canada",
        "i" = "These include {nmex} records from Mexico",
        "i" = "These include {nsound} records from Puget Sound",
        "i" = "These include {nunk} records designated as Not Known"
      ))
    }
  }
  
  if(source == "AREA" & all(data$AGENCY == "W")){ #Washington historical catch data

    removed <- data |>
      dplyr::filter(.data[[source]] >= 5)
    data <- data |> 
      dplyr::filter(.data[[source]] %in% c(1:4))
    
    noarea <- nrow(removed)
    nsound <- noarea
    ncan <- nmex <- 0

    
    if (verbose) {
      cli::cli_bullets(c(
        " " = "{.fn getArea} summary information -",
        "i" = "There are {noarea} records outside federal waters and were removed.",
        "i" = "These include {ncan} records from Canada",
        "i" = "These include {nmex} records from Mexico",
        "i" = "These include {nsound} records from Puget Sound",
        "i" = "These include {nna} records without {source}"
      ))
    }
  }
  
  return(data)
}
