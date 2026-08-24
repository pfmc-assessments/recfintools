#' Read RecFIN data files
#'
#' Read the primary `.RData` files produced by this package and assign each
#' loaded object to an object name that matches the file keyword.
#'
#' @details
#' This function currently focuses on the six primary RecFIN data files:
#' `BDS.Recent_SD501`, `BDS.Recent_SD506`, `BDS.MRFSS_SD509`,
#' `Catch.Recent_CTE501`, `Catch.MRFSS`, and `Catch.Hist`. If multiple files
#' with the same keyword are present, the most recently modified file is used.
#' The loaded objects are assigned into `envir` using the keyword as the object
#' name.
#'
#' @param path A file path to the directory containing the `.RData` files.
#'   The default is the current working directory.
#' @param envir The environment to which the loaded objects should be assigned.
#'   The default is the calling environment.
#' @param verbose Whether to print a message about the files that were loaded.
#'   Default is TRUE.
#'
#' @return An invisible named list of loaded objects.
#' @export
#' @author Brian Langseth
readData <- function(path = getwd(), envir = parent.frame(), verbose = TRUE) {
  keywords <- c(
    "BDS.Recent_SD501",
    "BDS.Recent_SD506",
    "BDS.MRFSS_SD509",
    "Catch.Recent_CTE501",
    "Catch.MRFSS",
    "Catch.Hist"
  )

  files <- list.files(
    path = path,
    full.names = TRUE,
    ignore.case = TRUE
  )
  files <- files[grepl("\\.rdata$", basename(files), ignore.case = TRUE)]

  latest_files <- vapply(keywords, function(keyword) {
    keyword_files <- files[
      grepl(
        tolower(keyword),
        tolower(basename(files)),
        fixed = TRUE
      )
    ]

    if (length(keyword_files) == 0) {
      return(NA_character_)
    }

    keyword_files[which.max(file.info(keyword_files)$mtime)]
  }, character(1))

  loaded_objects <- list()

  for (keyword in keywords) {
    file <- latest_files[[keyword]]

    if (is.na(file)) {
      next
    }

    file_env <- new.env(parent = emptyenv())
    object_names <- base::load(file, envir = file_env)

    if (length(object_names) == 0) {
      next
    }

    loaded_name <- if (keyword %in% object_names) {
      keyword
    } else if (length(object_names) == 1) {
      object_names[[1]]
    } else {
      stop(sprintf(
        "File '%s' contains %d objects (%s); expected exactly 1, or an object named '%s'.",
        basename(file),
        length(object_names),
        paste(object_names, collapse = ", "),
        keyword
      ))
    }

    loaded_object <- get(loaded_name, envir = file_env)
    assign(keyword, loaded_object, envir = envir)
    loaded_objects[[keyword]] <- loaded_object
  }

  if (verbose) {
    cli::cli_inform("Loaded {length(loaded_objects)} RecFIN data file{?s}.")
  }

  invisible(loaded_objects)
}
