#' Create a mode column based on input column specified in `source`
#'
#' @details
#' This function is used for both catch and composition data
#'
#' @section Mode mapping rules:
#' `source` can be a vector of candidate column names. The first matching
#' column in `data` is used.
#'
#' Values in `source` are evaluated using case-insensitive matching. Values are
#' standardized into `mode` as:
#' * `PR`: anything with `Private` (associated with code 7)
#' * `PC`: anything with `Party` or `Charter` (associated with code 6)
#' * `Other`: `Man-Made/Jetty`, `Man-Made`, `Beach/Bank`, `Shore` (all other codes)
#' * `UNK`: all unmatched values
#'
#' If `verbose = TRUE`, the function reports how many records were assigned
#' `UNK`.
#'
#' @export
#' @seealso [clean_catch()] calls 'getMode'
#'
#' @inheritParams clean_catch
#'
#' @param source Column name where mode information is located. Depends on the
#' type of data (catch or bds) and era (recent, mrfss, or historical). Default
#' value is for recent catch data (RECFIN_MODE_NAME).
#' Coded to accept a vector of names where the same type or era of data has
#' multiple different names. When multiple names within the vector are in the
#' dataset, picks the first.
#'

getMode <- function(
  data,
  source = c("RECFIN_MODE_NAME"),
  verbose = TRUE
) {
  if (!any(source %in% colnames(data))) { #
    cli::cli_inform("The column {source} was not found in the data.
                    Mode information has not been standardized")
  }

  source <- source[which(source %in% colnames(data))[1]]

  data <- data |>
    dplyr::mutate(mode = dplyr::case_when(
      grepl("private", .data[[source]], ignore.case = TRUE) ~ "PR",
      grepl("charter|party", .data[[source]], ignore.case = TRUE) ~ "PC",
      tolower(.data[[source]]) %in% tolower(c("Man-Made/Jetty", "Man-Made", "Beach/Bank", "Shore")) ~ "Other",
      TRUE ~ "UNK"
    ))

  nomode <- sum(data[, "mode"] == "UNK")

  if (verbose) {
    cli::cli_bullets(c(
      " " = "{.fn getMode} summary information -",
      "i" = "There are {nomode} records for which the mode (i.e., PR, PC, Other)
      could not be assigned and were labeled as UNK."
    ))
  }

  return(data)
}
