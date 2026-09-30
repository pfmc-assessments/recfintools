#' Filter out records from Puget Sound, Canada, Mexico areas based
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
#' * `PUGET SOUND` in areas other than area 4B (which equates to
#' SURVEY_PROGRAM_CATCH_AREA_NAME equal to BONILLA-TATOOSH LINE - SEKIU RIVER).
#'
#' For recent RecFIN bds data (`source = "AGENCY_FISHED_AREA_NAME"`):
#' * For Washington: PUNCH CARD AREAs 1 through 4, and PUNCH CARD AREAs 0 and
#' 'Not Known' when RECFIN_PORT_NAME also equals coastal ports are kept. All other
#' records are removed.
#' * For Oregon: All records are kept,
#' * For California: All records are kept. Because AGENCY_FISHED_AREA_NAME is 
#' empty for California, the script automatically uses "AGENCY_WATER_AREA_NAME" 
#' for California data.
#'
#' For Washington historical catch data (`source = "AREA"` and `AGENCY == "W"`),
#' records with `AREA >= 5` are removed.
#' 
#' For MRFSS catch data (`source = "AREA_X`):
#' *For California: Removes Mexico ("M") records
#'
#' For MRFSS bds data (`source = "AREA_X"`):
#' *For Washington: Removes Washington bds data
#' *For Oregon: All records are kept
#' *For California: All records are kept
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
#' 
#' For recent catch data, use `RECFIN_WATER_AREA_NAME`, which filters out values
#' of Canada, Mexico, and Puget Sound (but keeps area 4B). Areas with `Not Known`
#' are kept.
#' For Washington historical catch data, use `AREA`, which filters out values
#' of 5 and greater (i.e. Puget Sound).
#' For MRFSS catch data, use `AREA_X`, which filters out Mexico records ("M").
#'  
#' For recent bds data, use `AGENCY_FISHED_AREA_NAME`, which filters out values
#' of Canada, Mexico, and Puget Sound. Areas with "Not known" or "Unknown" for
#' Washington are kept if they also have coastal port names, but in Oregon
#' and California these are kept. Because California data are NA for
#' `AGENCY_FISHED_AREA_NAME`, the code instead filters California data using
#' "AGENCY_WATER_AREA_NAME" to remove Mexico records. Records with Estuary or
#' Not Known "AGENCY_WATER_AREA_NAME" in Oregon, and Inland or San Francisco Bay
#' AGENCY_WATER_AREA_NAME in California are flagged for the user but not removed.
#' For MRFSS bds data, use `AREA_X`, which flags the user about `AREA_X` values
#' that are "3" (unavailable), "5" (inland) or "6" (unknown") but does not 
#' remove them.
#' 
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
      "MEXICO"
    )

    removed <- data |>
      dplyr::filter((tolower(.data[[source]]) %in% tolower(nonfed)) |
        ((tolower(.data[[source]]) == tolower("PUGET SOUND")) &
          SURVEY_PROGRAM_CATCH_AREA_NAME == "EAST OF SEKIU RIVER"))
    data <- data |>
      dplyr::filter(!(
        tolower(.data[[source]]) %in% tolower(nonfed) |
          ((tolower(.data[[source]]) == tolower("PUGET SOUND")) &
            SURVEY_PROGRAM_CATCH_AREA_NAME == "EAST OF SEKIU RIVER")
      ))

    noarea <- nrow(removed)
    nsound <- sum(tolower(removed[, source]) == tolower("PUGET SOUND"))
    ncan <- sum(tolower(removed[, source]) == tolower(nonfed[1]))
    nmex <- sum(tolower(removed[, source]) == tolower(nonfed[2]))
    nunk <- sum(is.na(data[, source]))

    if (verbose) {
      cli::cli_bullets(c(
        " " = "{.fn getArea} summary information -",
        "i" = "There are {noarea} records outside federal waters and were removed.",
        "i" = "These include {ncan} records from Canada",
        "i" = "These include {nmex} records from Mexico",
        "i" = "These include {nsound} records from Puget Sound outside area 4B",
        "i" = "There are {nunk} records designated as Not Known and were kept.",
        ""
      ))
    }

    flag <- TRUE
  }
  
  ## MRFSS catch data
  if (source %in% c("AREA_X") & "WGT_AB1" %in% colnames(data)) {
    removed <- data |>
      dplyr::filter(.data[[source]] == "M")
    data <- data |>
      dplyr::filter(!.data[[source]] %in% "M")
    
    nmex <- nrow(removed)
    nna <- sum(is.na(data[, source]))
    
    if (verbose) {
      cli::cli_bullets(c(
        " " = "{.fn getArea} summary information -",
        "i" = "There are {nmex} records  from Mexcio that were removed.",
        "i" = "There are {nna} records without {source} and were kept.",
        ""
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
        "i" = "There are {nna} records without {source} that were kept.",
        ""
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
          !RECFIN_PORT_NAME %in% c("CHINOOK", "ILWACO", "LA PUSH", "NEAH BAY", "SEKIU", "WESTPORT", "OCEAN SHORES"),
        STATE_NAME == "WASHINGTON" ~ !tolower(.data[[source]]) %in% tolower(wa_fed),
        STATE_NAME == "CALIFORNIA" ~ grepl("MEXICO", .data$AGENCY_WATER_AREA_NAME)
      ))

    data <- data |>
      dplyr::filter(dplyr::case_when(
        STATE_NAME == "WASHINGTON" & .data[[source]] %in% "NOT KNOWN" ~
          RECFIN_PORT_NAME %in% c("CHINOOK", "ILWACO", "LA PUSH", "NEAH BAY", "SEKIU", "WESTPORT", "OCEAN SHORES"),
        STATE_NAME == "WASHINGTON" ~ tolower(.data[[source]]) %in% tolower(wa_fed),
        STATE_NAME == "CALIFORNIA" ~ !grepl("MEXICO", .data$AGENCY_WATER_AREA_NAME),
        STATE_NAME == "OREGON" ~ TRUE
      ))

    noarea <- nrow(removed)
    ncan <- sum(removed[, source] == "PUNCH CARD AREA 20", na.rm = TRUE)
    nsound <- sum(grepl("PUNCH CARD AREA", removed[, source]), na.rm = TRUE) - ncan
    nmex <- sum(grepl("MEXICO", removed[, "AGENCY_WATER_AREA_NAME"]), na.rm = TRUE)
    nunk <- sum(removed[, source] %in% c("NOT KNOWN", "UNKNOWN"), na.rm = TRUE) +
      sum(is.na(removed[, source]), na.rm = TRUE)

    # Flag records that were not removed but which the user should decide what
    # to do with. These include records with AGENCY_WATER_AREA_NAME = "ESTUARY",
    # and "NOT KNOWN" in Oregon, and contain "Inland" or "Bay" (San Franciso Bay)
    # in California, as well as records for Oregon with AGENCY_FISHED_AREA_NAME
    # that come from Washington or California waters.
    flag <- data |>
      dplyr::filter(dplyr::case_when(
        STATE_NAME == "OREGON" ~ grepl("california|washington", tolower(.data[[source]])) |
          .data$AGENCY_WATER_AREA_NAME %in% c("NOT KNOWN", "ESTUARY"),
        STATE_NAME == "CALIFORNIA" ~ grepl("inland|bay", tolower(.data$AGENCY_WATER_AREA_NAME))
      ))

    flag_EstUnkOr <- sum(flag[, "AGENCY_WATER_AREA_NAME"] %in% c("NOT KNOWN", "ESTUARY"))
    flag_InBay <- sum(grepl("inland|bay", tolower(flag$AGENCY_WATER_AREA_NAME)))
    flag_WaCa <- sum(grepl("california|washington", tolower(flag[, source])))

    if (verbose) {
      cli::cli_bullets(c(
        " " = "{.fn getArea} summary information -",
        "i" = "There are {noarea} records outside federal waters and were removed.",
        "i" = "These include {ncan} records from Canada",
        "i" = "These include {nsound} records from Puget Sound",
        "i" = "These include {nmex} records from Mexico",
        "i" = "There are {nunk} records designated as Not Known or Unknown in
        Washington that could not be associated with federal areas in other
        fields and so were removed.",
        "i" = "NOTE: Of the records that were kept, {flag_EstUnk} records in Oregon
        have Not Known or Estuary water area names, and {flag_InBay} records in
        California are from Inland or San Francisco Bay water area names.
        The user should decide how to handle these, which are not
        typically included in compositions, but could be depending on their 
        distributions and sample size.",
        "i" = "NOTE: There are also {flag_WaCa} records from Oregon of fish caught in
        Washington or California. The user should decide how to handle these.
        It is recommended to match the treatment of catch for fish caught in 
        Washington or Califoria waters but landed in Oregon ports.",
        ""
      ))
    }

    flag <- TRUE
  }

  ## MRFSS bds data
  if (source %in% c("AREA_X") & "LNGTH" %in% colnames(data)) {
    # Remove Washington bds data if not already done
    removed <- data |>
      dplyr::filter(ST == 53)
    data <- data |>
      dplyr::filter(ST != 53)

    noWA <- nrow(removed)


    # Flag records that were not removed but which the user should decide what
    # to do with. These include records with AREA_X = 3 (unavilable) or 
    # 5 (inland) or 6 (not known) or NA.
    flag <- data |>
      dplyr::filter(.data[[source]] %in% c(3, 5, 6, NA))

    nflag <- nrow(flag)

    if (verbose) {
      if (noWA > 0) {
        cli::cli_bullets(c(
          " " = "{.fn getArea} summary information -",
          "i" = "All {noWA} records from Washington were removed.
          Washington does not use MRFSS bds data for compositions",
          "i" = "NOTE: Of the Oregon and California records that were kept,
          {nflag} records are from Unavailable ({source} = 3), 
          inland ({source} = 5), Unknown ({source} = 6), or NA ({source} = NA) 
          areas. The user should decide how to handle these, which are not 
          typically included in compositions, but could be depending on their 
          distributions and sample size.",
          ""
        ))
      } else {
        cli::cli_bullets(c(
          " " = "{.fn getArea} summary information -",
          "i" = "NOTE: There are {nflag} records are from Unavailable 
          ({source} = 3), inland ({source} = 5), Unknown ({source} = 6), or 
          NA ({source} = NA) areas. The user should decide how to handle these, 
          which are not typically included in compositions, but could be 
          depending on sample size and the similarirty of their distributions.",
          ""
        ))
      }
    }

    flag <- TRUE
  }


  if (!flag) {
    cli::cli_inform("No adjustments to {source} were made. No records outside
                    of federal waters were identified")
  }

  return(data)
}
