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
#' @param species The species name that the files represent. The user
#'   must enter a value for this. Is case insensitive.
#' @param verbose Whether to print a message about the files that were saved.
#'   Default is TRUE.
#'
#' @return A message alerting the user of the names and number of files that 
#' were saved to `path`.
#'
#' @export
#' @seealso [readData()] Reads the data pulled by this function
#' @author Brian Langseth
#'
readData <- function(path = getwd(),
                     species = NULL, 
                     verbose = TRUE) {
  if (is.null(species)) {
    cli::cli_abort(c(
      "{.fn pullData} will not work because {species} was not assigned a value.
    Please assign a value to {.var species}"
    ))
  }
  
  if (!dir.exists(path)){
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
  
  #To Do: All ability to save password to each of these so only need to call once
  
  #Pull the catch data and save to path
  pull_catch_recfin_recent(species, apex = "CTE501", savedir = path)
  pull_catch_recfin_mrfss(species, savedir = path)
  pull_catch_recfin_hist(species, savedir = path)
  
  #Pull the bio data and save to path
  pull_bds_recfin_recent(species, apex = "SD501", savedir = path)
  pull_bds_recfin_recent(species, apex = "SD506", savedir = path)
  pull_bds_recfin_mrfss(species, apex = "SD517", savedir = path)
  
  files_new <- list.files(
    path = path,
    full.names = FALSE,
    ignore.case = TRUE
  )

  if (verbose) {
    added_files <- files_new[!files_new %in% files_old] #added files
    msg <- c(
      "Pulled and saved {length(added_files)} RecFIN data file{?s}:",
      stats::setNames(added_files, rep("*", length(added_files)))
    )
    cli::cli_inform(msg)
  }

}
