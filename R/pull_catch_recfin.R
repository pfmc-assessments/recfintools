#' Functions to pull catch data from recfin
#' 
#' Read catch data from the various total mortality reports in recfin: 
#' 'CTE501' or 'SDE001'
#' Historical times series
#' MRFSS
#'
#' @inheritParams sql
#' @inheritParams pacfintools::getDB
#' 
#' @param recfin_species_name A vector of strings specifying the RecFIN species 
#' name desired. Must be a valid name, in all caps. For list of species codes 
#' see sql_species.
#' @param savedir A file path to the directory where the results will be saved.
#' The default is the current working directory.
#' @param verbose Currently a holdover from pacfin nominal species. Can delete.
#' 
#' @author Brian J Langseth
#'
#' @examples
#' \dontrun{
#' catch.recfin <- pull_catch_recfin("QUILLBACK ROCKFISH")
#' }
#' 
#'
pull_catch_recfin_recent <- function(
    recfin_species_name,
    username = pacfintools::getUserName("PacFIN"),
    #password = pacfintools::ask_password(),
    password = ask_password(),
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
        sql = sql_catch_recent(recfin_species_name),
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
      #}
      
      # Save pulled data
      savefn <- file.path(
        savedir,
        paste(
          "RecFIN",
          file_species_name,
          "Catch", "Recent",
          format(Sys.Date(), "%d.%b.%Y"),
          "RData",
          sep = "."
        )
      )
      save(catch_recfin, file = savefn)
      
      return(invisible(catch_recfin))
}



pull_catch_recfin_hist <- function(
    recfin_species_name,
    username = pacfintools::getUserName("PacFIN"),
    #password = pacfintools::ask_password(),
    password = ask_password(),
    savedir = getwd(),
    verbose = TRUE
  ) {
  # Input checks
  stopifnot(
    "`verbose` must be a logical." = is.logical(verbose) &&
      length(verbose) == 1
  )
  
  file_species_name <- paste(sub(" .*", "", recfin_species_name), collapse = "--")
  
  catch_recfin <- lapply(sql_catch_hist(recfin_species_name),
                         pacfintools::getDB,
                         username = username, password = password)
  
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
  #}
  
  # Save pulled data
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
  
  return(invisible(catch_recfin))
}


#'
#'
#'
#'
#'
#' @section cte501:
#' Estimates of recent catches.
#'
#' @section mrfss:
#' Estimates of catches from thes
#' Marine Recreational Fisheries Statistics Survey (MRFSS).
#' Catches are for the years between 1980 and approximately 2003
#' for all three states.
#' 
#' @section Historical time series:
#' Estimates of catches from the historical time periods prior to but
#' possibly including 1980
#'
#' @return
#' An `.RData` file is saved with the object inside the file stored as
#' `catch_recfin`. This same data frame is also returned invisibly.
#'
#' @author Brian J Langseth
#' @export
#' @return Separate Rdata files containing pulled catch data
#' 
#' 
read_cte501 <- function(file) {
  data <- utils::read.csv(file)

  datacleaned <- clean_cte501(data)

  return(datacleaned)
}

#' @export
#' @rdname read_cte501
#'
read_mrfss <- function(file) {
  data <- utils::read.csv(file)

  datacleaned <- clean_mrfss(data)
  return(datacleaned)
}
