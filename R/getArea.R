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
#' For recent RecFIN catch data (`source = "RECFIN_WATER_AREA_NAME"`), records 
#' are removed when area is:
#' * `CANADA`
#' * `MEXICO`
#' * `PUGET SOUND`
#' 
#' For recent RecFIN bds data (`source = "AGENCY_FISHED_AREA_NAME"`), records
#' are kept when area is 
#' * For Washington: PUNCH CARD AREAs 1 through 4, and PUNCH CARD AREAs 0 and 
#' 'Not Known' when RECFIN_PORT_NAME also equals coastal ports.
#' * For California: Because AGENCY_FISHED_AREA_NAME is empty for California,
#' the script automatically uses "AGENCY_WATER_AREA_NAME" for california data. 
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
#' For recent bds data, use `AGENCY_FISHED_AREA_NAME`, which filters out values 
#' of Canada, Mexico, and Puget Sound. Areas with "Not known" or "Unknown" 
#' are kept if they also have coastal port names. Because California data are
#' empty for `AGENCY_FISH_AREA_NAME`, the code instead filters California data 
#' using "AGENCY_WATER_AREA_NAME" when `AGENCY_FISHED_AREA_NAME` is used.
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

  
  ## Recent catch data
  if (source == "RECFIN_WATER_AREA_NAME") { 

    nonfed <- c(
      "CANADA",
      "MEXICO",
      "PUGET SOUND"
    )

    removed <- data |>
      dplyr::filter(tolower(.data[[source]]) %in% tolower(nonfed))
    data <- data |>
      dplyr::filter(!tolower(.data[[source]]) %in% tolower(nonfed))

    noarea <- nrow(removed)
    nsound <- sum(tolower(removed[, source]) == tolower(nonfed[3]))
    ncan <- sum(tolower(removed[, source]) == tolower(nonfed[1]))
    nmex <- sum(tolower(removed[, source]) == tolower(nonfed[2]))
    nunk <- sum(is.na(data[, source]))

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

  
  ## Washington historical catch data
  if (source == "AREA" &
    all(data$AGENCY == "W") & 
    length(data$AGENCY > 0)) { # Ensure AGENCY exists (if not 'all' returns TRUE)

    removed <- data |>
      dplyr::filter(.data[[source]] >= 5)
    data <- data |>
      dplyr::filter(!.data[[source]] >= 5)

    noarea <- nrow(removed)
    nsound <- noarea
    ncan <- nmex <- 0
    nna <- sum(is.na(data[, source]))


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
  
  
  ## Recent bds data
  if (source %in% c("AGENCY_FISHED_AREA_NAME")) { 
    
    wa_fed <- c(
      "PUNCH CARD AREA 0",
      "PUNCH CARD AREA 1",
      "PUNCH CARD AREA 2",
      "PUNCH CARD AREA 3",
      "PUNCH CARD AREA 4",
      "NOT KNOWN"
    )

    removed <- data |>
      dplyr::filter(dplyr::case_when(
        STATE_NAME == "WASHINGTON" & .data[[source]] %in% "NOT KNOWN" ~ 
          !RECFIN_PORT_NAME %in% c("LA PUSH", "NEAH BAY", "SEKIU", "WESTPORT"),
        STATE_NAME == "WASHINGTON" ~ !tolower(.data[[source]]) %in% tolower(wa_fed),
        STATE_NAME == "CALIFORNIA" ~ grepl("MEXICO", .data$AGENCY_WATER_AREA_NAME))
        )
    
    data <- data |>
      dplyr::filter(dplyr::case_when(
        STATE_NAME == "WASHINGTON" & .data[[source]] %in% "NOT KNOWN" ~ 
          RECFIN_PORT_NAME %in% c("LA PUSH", "NEAH BAY", "SEKIU", "WESTPORT"),
        STATE_NAME == "WASHINGTON" ~ tolower(.data[[source]]) %in% tolower(fed),
        STATE_NAME == "CALIFORNIA" ~ !grepl("MEXICO", .data$AGENCY_WATER_AREA_NAME))
      )
    
    noarea <- nrow(removed)
    ncan <- sum(removed[, source] == "PUNCH CARD AREA 20", na.rm = TRUE)
    nsound <- sum(grepl("PUNCH CARD AREA", removed[, source]), na.rm = TRUE) - ncan
    nmex <- sum(grepl("MEXICO", removed[, "AGENCY_WATER_AREA_NAME"]), na.rm = TRUE)
    nunk <- sum(removed[, source] %in% c("NOT KNOWN", "UNKNOWN"), na.rm = TRUE) +
      sum(is.na(removed[, source]), na.rm = TRUE)
    
    if (verbose) {
      cli::cli_bullets(c(
        " " = "{.fn getArea} summary information -",
        "i" = "There are {noarea} records outside federal waters and were removed.",
        "i" = "These include {ncan} records from Canada",
        "i" = "These include {nsound} records from Puget Sound",
        "i" = "These include {nmex} records from Mexico",
        "i" = "There are {nunk} records designated as Not Known or Unknown that 
        could also not be associated with federal areas in other fields and so 
        were removed."
      ))
    }
    
    flag <- TRUE
  }

  if (!flag) {
    cli::cli_inform("No adjustments to {source} were made. No records outside
                    of federal waters were identified")
  }

  return(data)
}
