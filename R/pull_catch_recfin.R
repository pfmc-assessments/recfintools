#' Functions to pull catch data from recfin
#'
#' Read catch data from the various total mortality reports in recfin:
#' 'CTE501' or 'CTE001'
#' Historical times series for each state:
#' 'CTE503' or 'CTE507'
#' MRFSS catch data:
#' 'CTE510'
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
#' catch.recfin <- pull_catch_recfin_recent("QUILLBACK ROCKFISH")
#' catch.recfin001 <- pull_catch_recfin_recent("QUILLBACK ROCKFISH", apex = "CTE001")
#' catch.recfin501 <- pull_catch_recfin_recent("QUILLBACK ROCKFISH", apex = "CTE501")
#' catch.hist <- pull_catch_recfin_hist("QUILLBACK ROCKFISH")
#' catch.mrfss <- pull_catch_recfin_mrfss("QUILLBACK ROCKFISH")
#' }
#'
pull_catch_recfin_recent <- function(
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

  file_species_name <- paste(sub(" .*", "", recfin_species_name), collapse = "--")

  catch_recfin <- pacfintools::getDB(
    sql = sql_catch(recfin_species_name, type = "recent", apex = apex),
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
        "Catch", paste0("Recent", if(apex != FALSE) paste0("_", apex)),
        format(Sys.Date(), "%d.%b.%Y"),
        "RData",
        sep = "."
      )
    )
    save(catch_recfin, file = savefn)
  }

  return(invisible(catch_recfin))
}
#'
#'
#' @inheritParams pull_catch_recfin_recent
#'
pull_catch_recfin_hist <- function(
  recfin_species_name,
  username = pacfintools::getUserName("PacFIN"),
  password = pacfintools:::ask_password(),
  savedir = getwd(),
  verbose = TRUE
) {
  # Input checks
  stopifnot(
    "`verbose` must be a logical." = is.logical(verbose) &&
      length(verbose) == 1
  )

  file_species_name <- paste(sub(" .*", "", recfin_species_name), collapse = "--")

  catch_recfin <- lapply(sql_catch(recfin_species_name, type = "hist"),
    pacfintools::getDB,
    username = username, password = password
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
        "Catch", "Hist",
        format(Sys.Date(), "%d.%b.%Y"),
        "RData",
        sep = "."
      )
    )
    save(catch_recfin, file = savefn)
  }

  return(invisible(catch_recfin))
}
#'
#'
#' @inheritParams pull_catch_recfin_recent
#'
pull_catch_recfin_mrfss <- function(
  recfin_species_name,
  username = pacfintools::getUserName("PacFIN"),
  password = pacfintools:::ask_password(),
  savedir = getwd(),
  verbose = TRUE
) {
  # Input checks
  stopifnot(
    "`verbose` must be a logical." = is.logical(verbose) &&
      length(verbose) == 1
  )

  file_species_name <- paste(sub(" .*", "", recfin_species_name), collapse = "--")

  catch_recfin <- pacfintools::getDB(
    sql = sql_catch(recfin_species_name, type = "mrfss"),
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
        "Catch", "MRFSS",
        format(Sys.Date(), "%d.%b.%Y"),
        "RData",
        sep = "."
      )
    )
    save(catch_recfin, file = savefn)
  }

  return(invisible(catch_recfin))
}

