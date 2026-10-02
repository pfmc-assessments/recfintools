#' Add age information for recent bds data to the length data. Also flags 
#' records in age data that should be removed.    
#'
#' @details
#' This function is used for only for recent composition data, and combines the
#' length (SD501) and age (SD506) data, which are entered by the user. The fields
#' used to match the datasets are fixed as `BIO_DETAIL_ID` for length data and
#' `SAMPLE_ID` for age data. Other fields are matched as well to avoid duplicate
#' rows but these two are the primary identifiers.
#'
#' Additionally, this function removes records from multiple reads, which are
#' reported as multiple rows in SD506, by keeping the first occurrence. This
#' does not occur often, and only for ODFW, but when it does the length of the
#' fish is duplicated for each read. These records are flagged in the age data
#' as are records where age is not entered. 
#'
#' @export
#' @seealso [clean_bds()] calls 'getAges'
#'
#' @inheritParams clean_bds
#'
#' @param len_data A loaded Rdata object from pull_bds_recfin_recent for apex
#' report SD501.
#' @param age_data A loaded Rdata object from pull_bds_recfin_recent for apex
#' report SD506
#' 
#' @return Returns two data frames. The first `len_data` is the entered length
#' data with age information added. The second `age_data` is the entered age data
#' with a column "remove" added for later filtering because records are either
#' multiple reads of the same fish (`remove = "multRead"`) or are NA 
#' (`remove = "naAge"`).
#'
getAges <- function(
  len_data,
  age_data,
  verbose = TRUE
) {
  #Create temporary age dataset where ages are added to lengths
  temp_age_data <- age_data
  
  len_data$dataset <- "SD501"
  temp_age_data$dataset <- "SD506"

  # Removed rows that correspond to multiple reads from the same fish so that
  # lengths are not duplicated. Keeps first instance. Only applicable for ODFW
  nmult <- nrow(temp_age_data[duplicated(temp_age_data[, "SAMPLE_ID"]), ])
  temp_age_data <- temp_age_data[!duplicated(temp_age_data[, "SAMPLE_ID"]), ]

  data <- dplyr::left_join(len_data, temp_age_data,
    by = dplyr::join_by(
      BIO_DETAIL_ID == SAMPLE_ID,
      RECFIN_YEAR == SAMPLE_YEAR,
      SPECIES_NAME == RECFIN_SPECIES_NAME,
      RECFIN_PORT_NAME == PORT_NAME,
      RECFIN_MODE_NAME == RECFIN_MODE_NAME,
      RECFIN_LENGTH_MM == RECFIN_LENGTH_MM,
      RECFIN_SEX_CODE == RECFIN_SEX_CODE,
      RECFIN_SEX_NAME == RECFIN_SEX_NAME
    )
  ) |>
    dplyr::mutate(dataset = dplyr::coalesce(dataset.y, dataset.x)) |>
    dplyr::select(-dataset.x, -dataset.y)

  # TO DO: There are records in the age data that aren't present in the length data.
  # Fix these when understand what is going on.

  nage <- sum(data$dataset == "SD506")
  nage_read <- sum(!is.na(data$USE_THIS_AGE))
  nage_omit <- nrow(age_data) - nage

  # Also add column into original age dataset flagging ages that were removed
  # or that are NA
  
  if (!"remove" %in% colnames(age_data)){
    age_data$remove <- "no"
  }
  
  #Flag removed records that were multiples reads from the same fish for ODFW 
  #as well as any remaining ages that are NA
  age_data <- age_data |> 
    dplyr::mutate(
      remove = dplyr::if_else(
        duplicated(age_data[, "SAMPLE_ID"]),
        "multRead",
        dplyr::if_else(
          is.na(age_data$USE_THIS_AGE),
          "naAge",
          .data$remove
        ),
        .data$remove
      )
    )
  nnaAge <- sum(age_data$remove %in% "naAge")
  
  if (verbose) {
    cli::cli_bullets(c(
      " " = "{.fn getAges} summary information -",
      "i" = "There are {nage} structures with {nage_read} age reads that were
      added to the length data.",
      "i" = "Some records were not added, and include {nmult} multiple reads
      from ODFW, and {nage_omit} records not present in the length data.",
      "i" = "Within the age data, there are {nnaAge} records with age = NA",
      ""
    ))
  }

  return(list(
    "len_data" = data,
    "age_data" = age_data
    )
  )
}
