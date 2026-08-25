#' Read RecFIN data files
#'
#' Read the primary `.RData` files produced by this package and assign each
#' loaded object to a standardized object name.
#'
#' @details
#' This function currently focuses on the six primary RecFIN data files:
#' `BDS.Recent_SD501`, `BDS.Recent_SD506`, `BDS.MRFSS_SD509`,
#' `Catch.Recent_CTE501`, `Catch.MRFSS`, and `Catch.Hist`. If multiple files
#' with the same keyword are present, the most recently modified file is used.
#' The loaded objects are assigned into `envir` using standardized object names:
#' `bds_recent_len`, `bds_recent_age`, `bds_mrfss`, `catch_recent`,
#' `catch_mrfss`, and `catch_hist`.
#'
#' @param path A file path to the directory containing the `.RData` files.
#'   The default is the current working directory.
#' @param envir The environment to which the loaded objects should be assigned.
#'   The default is the calling environment.
#' @param species The species name that the `.Rdata` files represent. The user
#'   must enter a value for this. Is case insensitive.
#' @param verbose Whether to print a message about the files that were loaded.
#'   Default is TRUE.
#'
#' @return An invisible named list of loaded objects. The number of data files
#' that were read.
#' @export
#' @author Brian Langseth
#'
readData <- function(path = getwd(), envir = parent.frame(),
                     species = NULL, verbose = TRUE) {
  if (is.null(species)) {
    cli::cli_abort(c(
      "{.fn readData} will not work because {species} was not assigned a value.
    Please assign a value to {.var species}"
    ))
  }

  species <- toupper(species)

  keywords <- c(
    BDS.Recent_SD501 = "bds_recent_len",
    BDS.Recent_SD506 = "bds_recent_age",
    BDS.MRFSS_SD509 = "bds_mrfss",
    Catch.Recent_CTE501 = "catch_recent",
    Catch.MRFSS = "catch_mrfss",
    Catch.Hist = "catch_hist"
  )

  # Obtain Rdata files in working directory
  files <- list.files(
    path = path,
    full.names = TRUE,
    ignore.case = TRUE
  )
  files <- files[grepl("\\.rdata$", basename(files), ignore.case = TRUE)]

  # Function to keep the most recent versions of the data when multiple files
  # of the same type exist
  latest_files <- vapply(
    names(keywords), function(keyword) {
      keyword_files <- files[
        grepl(
          tolower(paste(species, keyword, sep = ".")),
          tolower(basename(files)),
          fixed = TRUE
        )
      ]

      if (length(keyword_files) == 0) {
        return(NA_character_)
      }

      keyword_files[which.max(file.info(keyword_files)$mtime)]
    },
    character(1)
  )

  loaded_objects <- list()

  for (file_keyword in names(keywords)) {
    object_name <- keywords[[file_keyword]]
    file <- latest_files[[file_keyword]]

    if (is.na(file)) {
      next
    }

    file_env <- new.env(parent = emptyenv())
    object_names <- base::load(file, envir = file_env)

    if (length(object_names) == 0) {
      next
    }

    loaded_name <- if (file_keyword %in% object_names) {
      file_keyword
    } else if (length(object_names) == 1) {
      object_names[[1]]
    } else {
      stop(sprintf(
        "File '%s' contains %d objects (%s); expected exactly 1, or an object named '%s'.",
        basename(file),
        length(object_names),
        paste(object_names, collapse = ", "),
        file_keyword
      ))
    }

    loaded_object <- get(loaded_name, envir = file_env)
    assign(object_name, loaded_object, envir = envir)
    loaded_objects[[object_name]] <- loaded_object
  }

  if (verbose) {
    cli::cli_inform("Loaded {length(loaded_objects)} RecFIN data file{?s}.")
  }

  invisible(loaded_objects)
}
