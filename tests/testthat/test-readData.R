test_that("readData loads the most recent file for each keyword", {
  tmp_dir <- tempfile("recfintools-readData-")
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  write_rdata <- function(file, source) {
    loaded_object <- list(source = source)
    save(loaded_object, file = file)
  }

  newer_file <- file.path(
    tmp_dir,
    "RecFIN.BDS.Recent_SD501.02.Jan.2020.RData"
  )
  older_file <- file.path(
    tmp_dir,
    "RecFIN.BDS.Recent_SD501.01.Jan.2020.RData"
  )
  write_rdata(older_file, "older")
  write_rdata(newer_file, "newer")
  Sys.setFileTime(older_file, as.POSIXct("2020-01-01 00:00:00", tz = "UTC"))
  Sys.setFileTime(newer_file, as.POSIXct("2020-01-02 00:00:00", tz = "UTC"))

  write_rdata(file.path(tmp_dir, "RecFIN.BDS.Recent_SD506.RData"), "sd506")
  write_rdata(file.path(tmp_dir, "RecFIN.BDS.MRFSS_SD509.RData"), "sd509")
  write_rdata(file.path(tmp_dir, "RecFIN.Catch.Recent_CTE501.RData"), "cte501")
  write_rdata(file.path(tmp_dir, "RecFIN.Catch.MRFSS.RData"), "mrfss")
  write_rdata(file.path(tmp_dir, "RecFIN.Catch.Hist.RData"), "hist")

  output_env <- new.env(parent = emptyenv())
  loaded <- readData(path = tmp_dir, envir = output_env, verbose = FALSE)

  expect_named(
    loaded,
    c(
      "BDS.Recent_SD501",
      "BDS.Recent_SD506",
      "BDS.MRFSS_SD509",
      "Catch.Recent_CTE501",
      "Catch.MRFSS",
      "Catch.Hist"
    )
  )
  expect_equal(output_env$BDS.Recent_SD501$source, "newer")
  expect_equal(output_env$BDS.Recent_SD506$source, "sd506")
  expect_equal(output_env$BDS.MRFSS_SD509$source, "sd509")
  expect_equal(output_env$Catch.Recent_CTE501$source, "cte501")
  expect_equal(output_env$Catch.MRFSS$source, "mrfss")
  expect_equal(output_env$Catch.Hist$source, "hist")
})
