#' Identify records from Puget Sound, Canada, Mexico areas based
#' on input column specified in `source`.
#'
#' @details
#' This function is used for both catch and composition data. Because the case
#' for values are sometimes different across data sets, fields with values as
#' character strings are converted to lowercase when filtering.
#' Based on similar function from pacfintools, but modified for recreational data
#' Records are flagged in `remove` for removal by [clean_catch()] or
#' [clean_bds()], rather than removed here. The exception is Washington MRFSS
#' bds data, which are removed by this function.
#'
#' @section Area filtering rules:
#' Values in `source` are evaluated using case-insensitive matching.
#'
#' For recent RecFIN catch data (`source = "RECFIN_WATER_AREA_NAME"`), records
#' are flagged for removal when area is:
#' * `CANADA`
#' * `MEXICO`
#' * `PUGET SOUND` in areas other than area 4B (which equates to
#' SURVEY_PROGRAM_CATCH_AREA_NAME equal to BONILLA-TATOOSH LINE - SEKIU RIVER).
#'
#' For recent RecFIN bds data (`source = "AGENCY_FISHED_AREA_NAME"`):
#' * For Washington: PUNCH CARD AREAs 1 through 4, and PUNCH CARD AREAs 0 and
#' 'Not Known' when RECFIN_PORT_NAME also equals coastal ports are kept. All other
#' records are flagged for removal.
#' * For Oregon: All records are kept,
#' * For California: All records are kept. Because AGENCY_FISHED_AREA_NAME is
#' empty for California, the script automatically uses "AGENCY_WATER_AREA_NAME"
#' for California data.
#'
#' For Washington historical catch data (`source = "AREA"` and `AGENCY == "W"`),
#' records with `AREA >= 5` are flagged for removal.
#'
#' For MRFSS catch data (`source = "AREA_X`):
#' *For California: Flags Mexico ("M") records for removal
#'
#' For MRFSS bds data (`source = "AREA_X"`):
#' *For Washington: Removes Washington bds data
#' *For Oregon: All records are kept
#' *For California: All records are kept
#'
#' If `verbose = TRUE`, the function reports the number of records identified by
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
#' For recent catch data, use `RECFIN_WATER_AREA_NAME`, which flags records with values
#' of Canada, Mexico, and Puget Sound (but not area 4B) for removal. Areas with
#' `Not Known` are not flagged for removal.
#' For Washington historical catch data, use `AREA`, which flags values
#' of 5 and greater (i.e. Puget Sound) for removal.
#' For MRFSS catch data, use `AREA_X`, which flags Mexico records ("M") for removal.
#'
#' For recent bds data, use `AGENCY_FISHED_AREA_NAME`, which flags records with values
#' of Canada, Mexico, and Puget Sound for removal. Areas with "Not known" or "Unknown" for
#' Washington are kept if they also have coastal port names, but in Oregon
#' and California these are kept. Because California data are NA for
#' `AGENCY_FISHED_AREA_NAME`, the code instead filters California data using
#' "AGENCY_WATER_AREA_NAME" to flag Mexico records for removal. Records with Estuary or
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
                    Records outside federal waters have not been flagged for removal")
  }
  if (!"remove" %in% colnames(data)) {
    data$remove <- "no"
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
      dplyr::mutate(
        remove = dplyr::if_else(
          tolower(.data[[source]]) %in% tolower(nonfed) |
            ((tolower(.data[[source]]) == tolower("PUGET SOUND")) &
              SURVEY_PROGRAM_CATCH_AREA_NAME == "EAST OF SEKIU RIVER"),
          "area",
          .data$remove
        )
      )

    noarea <- nrow(removed)
    nsound <- sum(tolower(removed[, source]) == tolower("PUGET SOUND"))
    ncan <- sum(tolower(removed[, source]) == tolower(nonfed[1]))
    nmex <- sum(tolower(removed[, source]) == tolower(nonfed[2]))
    nunk <- sum(
      is.na(data[, source]),
      tolower(data[, source]) == tolower("NOT KNOWN")
    )

    if (verbose) {
      cli::cli_bullets(c(
        " " = "{.fn getArea} summary information -",
        "i" = "There were {noarea} records identified as outside federal waters, flagged for removal.",
        "i" = "There were {ncan} records determined to be from Canada.",
        "i" = "There were {nmex} records determined to be from Mexico.",
        "i" = "There were {nsound} records determined to be from Puget Sound outside area 4B.",
        "i" = "There were {nunk} records with an unknown area, not flagged for removal by {.fn getArea}.",
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
      dplyr::mutate(
        remove = dplyr::if_else(
          .data[[source]] %in% "M",
          "area",
          .data$remove
        )
      )

    nmex <- nrow(removed)
    nna <- sum(
      is.na(data[, source]),
      data[, source] %in% c(6, 8)
    )

    if (verbose) {
      cli::cli_bullets(c(
        " " = "{.fn getArea} summary information -",
        "i" = "There were {nmex} records determined to be from Mexico, flagged for removal.",
        "i" = "There were {nna} records with unknown {.field {source}}, not flagged for removal by {.fn getArea}.",
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
      dplyr::mutate(
        remove = dplyr::if_else(
          .data[[source]] >= 5,
          "area",
          .data$remove
        )
      )

    noarea <- nrow(removed)
    nsound <- noarea
    ncan <- nmex <- 0
    nna <- sum(is.na(data[, source]))


    if (verbose) {
      cli::cli_bullets(c(
        " " = "{.fn getArea} summary information -",
        "i" = "There were {noarea} records identified as outside federal waters, flagged for removal.",
        "i" = "There were {ncan} records determined to be from Canada.",
        "i" = "There were {nmex} records determined to be from Mexico.",
        "i" = "There were {nsound} records determined to be from Puget Sound.",
        "i" = "There were {nna} records missing {.field {source}}, not flagged for removal by {.fn getArea}.",
        ""
      ))
    }

    flag <- TRUE
  }


  ## Recent bds LENGTH data
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
      dplyr::mutate(
        remove = dplyr::if_else(
          dplyr::case_when(
            STATE_NAME == "WASHINGTON" & .data[[source]] %in% "NOT KNOWN" ~
              RECFIN_PORT_NAME %in% c("CHINOOK", "ILWACO", "LA PUSH", "NEAH BAY", "SEKIU", "WESTPORT", "OCEAN SHORES"),
            STATE_NAME == "WASHINGTON" ~ tolower(.data[[source]]) %in% tolower(wa_fed),
            STATE_NAME == "CALIFORNIA" ~ !grepl("MEXICO", .data$AGENCY_WATER_AREA_NAME),
            STATE_NAME == "OREGON" ~ TRUE
          ),
          .data$remove,
          "area"
        )
      )

    noarea <- nrow(removed)
    ncan <- sum(removed[, source] == "PUNCH CARD AREA 20", na.rm = TRUE)
    nsound <- sum(grepl("PUNCH CARD AREA", removed[, source]), na.rm = TRUE) - ncan
    nmex <- sum(grepl("MEXICO", removed[, "AGENCY_WATER_AREA_NAME"]), na.rm = TRUE)
    nunk <- sum(removed[, source] %in% c("NOT KNOWN", "UNKNOWN"), na.rm = TRUE) +
      sum(is.na(removed[, source]), na.rm = TRUE)

    # Identify records not flagged for removal but which the user should decide what
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
        "i" = "There were {noarea} records identified as outside federal waters, flagged for removal.",
        "i" = "There were {ncan} records determined to be from Canada.",
        "i" = "There were {nsound} records determined to be from Puget Sound.",
        "i" = "There were {nmex} records determined to be from Mexico.",
        "i" = "There were {nunk} records designated as Not Known or Unknown in
        Washington that could not be associated with federal areas in other
        fields, flagged for removal.",
        "i" = "Of the records not flagged for removal by {.fn getArea}, {flag_EstUnkOr} records in Oregon
        have Not Known or Estuary water area names, and {flag_InBay} records in
        California are from Inland or San Francisco Bay water area names.
        The user should decide how to handle these, which are not
        typically included in compositions, but could be depending on their
        distributions and sample size.",
        "i" = "There were also {flag_WaCa} records from Oregon of fish caught in
        Washington or California. The user should decide how to handle these.
        It is recommended to match the treatment of catch for fish caught in
        Washington or California waters that are landed in Oregon ports.",
        ""
      ))
    }

    flag <- TRUE
  }
  
  ## Recent bds AGE data
  if (source %in% c("SURVEY_PROGRAM_CATCH_AREA_NAME")) {
    wa_fed <- c(
      "PUNCH CARD AREA 0",
      "PUNCH CARD AREA 1",
      "PUNCH CARD AREA 2",
      "PUNCH CARD AREA 3",
      "PUNCH CARD AREA 4"
    )
    
    removed <- data |>
      dplyr::filter(dplyr::case_when(
        SAMPLING_AGENCY_NAME == "WDFW" & .data[[source]] %in% c(NA, "PUNCH CARD AREA 0") ~
          !PORT_NAME %in% c("CHINOOK", "ILWACO", "LA PUSH", "NEAH BAY", "SEKIU", "WESTPORT", "OCEAN SHORES"),
        SAMPLING_AGENCY_NAME == "WDFW" ~ (!is.na(.data[[source]]) & !(tolower(.data[[source]]) %in% tolower(wa_fed)))
      ))
    
    data <- data |>
      dplyr::mutate(
        remove = dplyr::if_else(
          dplyr::case_when(
            SAMPLING_AGENCY_NAME== "WDFW" & .data[[source]] %in% c(NA, "PUNCH CARD AREA 0") ~
              PORT_NAME %in% c("CHINOOK", "ILWACO", "LA PUSH", "NEAH BAY", "SEKIU", "WESTPORT", "OCEAN SHORES"),
            SAMPLING_AGENCY_NAME == "WDFW" ~ (!is.na(.data[[source]])) & (tolower(.data[[source]]) %in% tolower(wa_fed)),
            SAMPLING_AGENCY_NAME == "ODFW" ~ TRUE
          ),
          .data$remove,
          "area"
        )
      )
    
    noarea <- nrow(removed)
    ncan <- sum(removed[, source] == "PUNCH CARD AREA 20", na.rm = TRUE)
    nsound <- sum(grepl("PUNCH CARD AREA", removed[, source]), na.rm = TRUE) - ncan
    nunk <- sum(removed[, source] %in% c("PUNCH CARD AREA 0"), na.rm = TRUE) +
      sum(is.na(removed[, source]), na.rm = TRUE)
    
    if (verbose) {
      cli::cli_bullets(c(
        " " = "{.fn getArea} summary information -",
        "i" = "There were {noarea} records identified as outside federal waters, flagged for removal.",
        "i" = "There were {ncan} records determined to be from Canada.",
        "i" = "There were {nsound} records determined to be from Puget Sound.",
        "i" = "There were {nunk} records designated as Not Known or Unknown in
        Washington that could not be associated with federal areas in other
        fields, flagged for removal.",
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
    # to do with. These include records with AREA_X = 3 (unavailable) or
    # 5 (inland) or 6 (not known) or NA.
    flag <- data |>
      dplyr::filter(.data[[source]] %in% c(3, 5, 6, NA))

    nflag <- nrow(flag)

    if (verbose) {
      if (noWA > 0) {
        cli::cli_bullets(c(
          " " = "{.fn getArea} summary information -",
          "i" = "There were {noWA} records from Washington removed by {.fn getArea}.
          Washington does not use MRFSS bds data for compositions.",
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
          "i" = "There were {nflag} records from Unavailable
          ({source} = 3), inland ({source} = 5), Unknown ({source} = 6), or
          NA ({source} = NA) areas. The user should decide how to handle these,
          which are not typically included in compositions, but could be
          depending on sample size and the similarity of their distributions.",
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
