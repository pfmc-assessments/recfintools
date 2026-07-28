#' Functions to pull bio data from recfin, which includes lengths and ages
#'
#' Read bio data from the various biological reports in recfin:
#' 'SD001' or 'SD501' for lengths, 'SD506' for ages
#' MRFSS bio data:
#' 'SD508' or 'SD509' for Type 2 and Type 3 data, respectively
#'
#' @inheritParams sql
#' @inheritParams pacfintools::getDB
#'
#' @param recfin_species_name A vector of strings specifying the RecFIN species
#' name desired. Must be a valid name though case is automatically corrected.
#' For list of species codes see sql_species.
#' @param savedir A file path to the directory where the results will be saved.
#' The default is the current working directory. If don't want to save use NULL.
#' @param verbose Currently a holdover from pacfin nominal species. Can delete.
#'
#' @export
#' @returns An `.RData` file is saved with the object. This same data frame is
#' also returned invisibly.
#' @seealso [pacfintools::getUserName()], [pacfintools::ask_password] which are
#' inputs to this function
#'
#' @author Brian J Langseth
#'
#' @examples
#' \dontrun{
#' bio.recfin.001 <- pull_bds_recfin_recent("QUILLBACK ROCKFISH", apex = "SD001")
#' bio.recfin.501 <- pull_bds_recfin_recent("QUILLBACK ROCKFISH", apex = "SD501")
#' bio.mrfss.508 <- pull_bds_recfin_mrfss("QUILLBACK ROCKFISH", apex = "SD508")
#' bio.mrfss.509 <- pull_bds_recfin_mrfss("QUILLBACK ROCKFISH", apex = "SD509")
#' }
#'
pull_bds_recfin_recent <- function(
  recfin_species_name,
  username = pacfintools::getUserName("PacFIN"),
  password = pacfintools:::ask_password(),
  savedir = getwd(),
  verbose = TRUE,
  apex = FALSE
) {
  # Input checks
  stopifnot(
    "`verbose` must be a logical." = is.logical(verbose) &&
      length(verbose) == 1
  )

  file_species_name <- ifelse(length(recfin_species_name) <= 3, 
                              paste(sub(" .*", "", recfin_species_name), collapse = "--"),
                              "MANY")

  bio_recfin <- pacfintools::getDB(
    sql = sql_bds(recfin_species_name, type = "recent", apex = apex),
    username = username,
    password = password
  )

  # # message calls
  # if (verbose) {
  #   n_species <- dplyr::count(catch.pacfin, PACFIN_SPECIES_CODE)
  #   message <- paste0(
  #     unique(n_species$PACFIN_SPECIES_CODE),
  #     " (",
  #     n_species$n,
  #     ")"
  #   )
  #   cli::cli_alert_info(
  #     "The following PACFIN_SPECIES_CODE(s) were found: {message}"
  #   )
  # }

  # Save pulled data if provided
  if (!is.null(savedir)) {
    savefn <- file.path(
      savedir,
      paste(
        "RecFIN",
        file_species_name,
        "BDS", paste0("Recent", if (apex != FALSE) paste0("_", apex)),
        format(Sys.Date(), "%d.%b.%Y"),
        "RData",
        sep = "."
      )
    )
    save(bio_recfin, file = savefn)
  }

  return(invisible(bio_recfin))
}
#'
#'
#' @inheritParams pull_bds_recfin_recent
#'
pull_bds_recfin_mrfss <- function(
  recfin_species_name,
  username = pacfintools::getUserName("PacFIN"),
  password = pacfintools:::ask_password(),
  savedir = getwd(),
  verbose = TRUE,
  apex = FALSE
) {
  # Input checks
  stopifnot(
    "`verbose` must be a logical." = is.logical(verbose) &&
      length(verbose) == 1
  )

  file_species_name <- ifelse(length(recfin_species_name) <= 3, 
                              paste(sub(" .*", "", recfin_species_name), collapse = "--"),
                              "MANY")

  bio_recfin <- pacfintools::getDB(
    sql = sql_bds(recfin_species_name, type = "mrfss", apex = apex),
    username = username,
    password = password
  )

  # # message calls
  # if (verbose) {
  #   n_species <- dplyr::count(catch.pacfin, PACFIN_SPECIES_CODE)
  #   message <- paste0(
  #     unique(n_species$PACFIN_SPECIES_CODE),
  #     " (",
  #     n_species$n,
  #     ")"
  #   )
  #   cli::cli_alert_info(
  #     "The following PACFIN_SPECIES_CODE(s) were found: {message}"
  #   )
  # }

  # Save pulled data if provided
  if (!is.null(savedir)) {
    savefn <- file.path(
      savedir,
      paste(
        "RecFIN",
        file_species_name,
        "BDS", paste0("MRFSS", if (apex != FALSE) paste0("_", apex)),
        format(Sys.Date(), "%d.%b.%Y"),
        "RData",
        sep = "."
      )
    )
    save(bio_recfin, file = savefn)
  }

  return(invisible(bio_recfin))
}
