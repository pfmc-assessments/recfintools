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
      "bds_recent_len",
      "bds_recent_age",
      "bds_mrfss",
      "catch_recent",
      "catch_mrfss",
      "catch_hist"
    )
  )
  expect_equal(output_env$bds_recent_len$source, "newer")
  expect_equal(output_env$bds_recent_age$source, "sd506")
  expect_equal(output_env$bds_mrfss$source, "sd509")
  expect_equal(output_env$catch_recent$source, "cte501")
  expect_equal(output_env$catch_mrfss$source, "mrfss")
  expect_equal(output_env$catch_hist$source, "hist")
})
