#' Pull all RecFIN data files from the server
#'
#' Pulls the primary recreational data within one function and saves each file
#' as an `.Rdata` file. This script is not intended for everyone to run, rather
#' it is for the data provider.
#'
#' @details
#' This function currently focuses on the eight primary RecFIN reports as
#' available on the RecFIN Dashboard:
#' CTE501: Recent catch data
#' CTE008: MRFSS catch data
#' CTE503: Washington historical catch reconstruction
#' CTE507: Oregon historical catch reconstruction
#' CTE508: California historical catch reconstruction
#' SD501: Recent length bds data
#' SD506: Recent age bds data
#' SD517: MRFSS type 3 bds data
#' Historical catch files are pulled for each of the three states separately but
#' are saved as a single list object. All other files are pulled and saved
#' individually
#'
#' @param path A file path to the directory where the files are to be saved.
#'   The default is the current working directory.
#' @param species The species name that the files represent. Can be a single
#'   name, or a vector of multiple names. The user must enter a value for this.
#'   Is case insensitive.
#' @param username Username to access the recfin database of interest. Default is to
#'   automatically set using `pacfintools::getUserName()`
#' @param password Password to access the recfin database. Default is to prompt
#'   user to enter using `pacfintools::ask_password()`
#' @param verbose Whether to print a message about the files that were saved.
#'   Default is TRUE.
#'
#' @return A message alerting the user of the names and number of files that
#' were saved to `path`.
#'
#' @export
#' @seealso [readData()] Reads the data pulled by this function
#' @seealso [pacfintools::getUserName()], [pacfintools::ask_password] which are
#' inputs to this function
#' @author Brian Langseth
#'
pullData <- function(path = getwd(),
                     species = NULL,
                     username = pacfintools::getUserName("PacFIN"),
                     password = pacfintools:::ask_password(),
                     verbose = TRUE) {
  if (is.null(species)) {
    cli::cli_abort(c(
      "{.fn pullData} will not work because {species} was not assigned a value.
    Please assign a value to {.var species}"
    ))
  }

  if (!dir.exists(path)) {
    cli::cli_abort(c(
      "{.fn pullData} will not work because {path} does not exist. Please assign
      a valid directory for 'path'"
    ))
  }

  # Get list of file names in path from which to determine new ones
  files_old <- list.files(
    path = path,
    full.names = FALSE,
    ignore.case = TRUE
  )

  # To Do: All ability to save password to each of these so only need to call once

  # Pull the catch data and save to path
  cli::cli_inform("Pulling catch datasets...")
  pull_catch_recfin_recent(species,
    apex = "CTE501", savedir = path,
    username = username, password = password
  )
  cli::cli_inform("...done pulling recent catch CTE501...")
  pull_catch_recfin_mrfss(species,
    savedir = path,
    username = username, password = password
  )
  cli::cli_inform("...done pulling MRFSS catch CTE008...")
  pull_catch_recfin_hist(species,
    savedir = path,
    username = username, password = password
  )
  cli::cli_inform("...done pulling historical catch CTE503, 507, and 508.")

  # Pull the bio data and save to path
  cli::cli_inform("Pulling biological datasets...")
  pull_bds_recfin_recent(species,
    apex = "SD501", savedir = path,
    username = username, password = password
  )
  cli::cli_inform("...done pulling recent bds lengths SD501...")
  pull_bds_recfin_recent(species,
    apex = "SD506", savedir = path,
    username = username, password = password
  )
  cli::cli_inform("...done pulling recent bds ages SD506...")
  pull_bds_recfin_mrfss(species,
    apex = "SD517", savedir = path,
    username = username, password = password
  )
  cli::cli_inform("...done pulling MRFSS bds SD517.")

  files_new <- list.files(
    path = path,
    full.names = FALSE,
    ignore.case = TRUE
  )

  if (verbose) {
    added_files <- files_new[!files_new %in% files_old] # added files
    msg <- c(
      "Pulled and saved {length(added_files)} RecFIN data file{?s}:",
      stats::setNames(added_files, rep("*", length(added_files)))
    )
    cli::cli_inform(msg)
  }
}
