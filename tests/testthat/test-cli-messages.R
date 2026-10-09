capture_cli <- function(expression) {
  messages <- character()
  value <- withCallingHandlers(
    expression,
    message = function(condition) {
      messages <<- c(messages, conditionMessage(condition))
      invokeRestart("muffleMessage")
    }
  )
  list(value = value, messages = gsub("[[:space:]]+", " ", paste(messages, collapse = "\n")))
}

test_that("year summaries describe flags without removing rows", {
  data <- data.frame(
    RECFIN_YEAR = c(1999, 2004, NA),
    RECFIN_LENGTH_MM = c(10, 20, 30),
    STATE_NAME = "OREGON"
  )
  result <- capture_cli(getYear(data))
  expect_equal(nrow(result$value), nrow(data))
  expect_equal(result$value$remove, c("year", "no", "year"))
  expect_match(result$messages, "1 records missing a year")
  expect_match(result$messages, "1 Oregon ORBS records.*flagged for removal")
  expect_false(grepl("records removed", result$messages))
  expect_equal(getYear(data, verbose = FALSE), result$value)
  expect_message(getYear(data, verbose = FALSE), NA)

  data <- data.frame(YEAR = c(2001, 2000), ID_CODE = 1:2, ST = 41)
  result <- capture_cli(getYear(data, source = "YEAR"))
  expect_equal(result$value$remove, c("year", "no"))
  expect_match(result$messages, "1 Oregon MRFSS records.*flagged for removal")
})

test_that("area summaries distinguish flags from actual MRFSS removals", {
  data <- data.frame(
    RECFIN_WATER_AREA_NAME = c("CANADA", "MEXICO", "PUGET SOUND", "NOT KNOWN"),
    SURVEY_PROGRAM_CATCH_AREA_NAME = "EAST OF SEKIU RIVER"
  )
  result <- capture_cli(getArea(data))
  expect_equal(nrow(result$value), nrow(data))
  expect_equal(result$value$remove, c("area", "area", "area", "no"))
  expect_match(result$messages, "3 records identified as outside federal waters, flagged for removal")
  expect_false(grepl("were removed", result$messages))
  expect_message(getArea(data, verbose = FALSE), NA)

  data <- data.frame(AREA_X = c(3, 5), LNGTH = c(100, 200), ST = c(53, 41))
  result <- capture_cli(getArea(data, source = "AREA_X"))
  expect_equal(nrow(result$value), 1)
  expect_match(result$messages, "1 records from Washington removed by")
})

test_that("length summaries describe flags without removing rows", {
  data <- data.frame(
    RECFIN_LENGTH_MM = c(NA, 0, 100),
    IS_AGENCY_LENGTH_WITHIN_MAX = c(TRUE, TRUE, FALSE),
    RECFIN_LENGTH_TYPE = c("FORK", "FORK", "TOTAL")
  )
  result <- capture_cli(getLength(data))
  expect_equal(nrow(result$value), nrow(data))
  expect_equal(result$value$remove, c("length", "length", "no"))
  expect_match(result$messages, "2 records with NA or 0.*flagged for removal")
  expect_match(result$messages, "1 otherwise unflagged records")
  expect_message(getLength(data, verbose = FALSE), NA)

  data <- data.frame(LNGTH = c(NA, 0, 100))
  result <- capture_cli(getLength(data, source = "LNGTH"))
  expect_equal(result$value$remove, c("length", "length", "no"))
  expect_match(result$messages, "2 records with NA or 0.*flagged for removal")
})

test_that("age summaries describe flags in the returned age data", {
  data <- data.frame(SAMPLE_ID = c(1, 1, 2), USE_THIS_AGE = c(5, 6, NA))
  result <- capture_cli(getAges(NULL, data))
  expect_equal(nrow(result$value$age_data), nrow(data))
  expect_equal(result$value$age_data$remove, c("no", "multRead", "naAge"))
  expect_match(result$messages, "1 duplicate age reads flagged for removal")
  expect_match(result$messages, "1 records missing.*flagged for removal")
  expect_false(grepl("were removed", result$messages))
  expect_message(getAges(NULL, data, verbose = FALSE), NA)
})

test_that("state and mode summaries report unknown assignments", {
  data <- data.frame(STATE_NAME = c("OREGON", "UNKNOWN"), RECFIN_MODE_NAME = c("Private", "UNKNOWN"))
  result <- capture_cli(getState(data))
  expect_equal(result$value$state, c("OR", "UNK"))
  expect_match(result$messages, "There were 1 records for which the state")
  result <- capture_cli(getMode(data))
  expect_equal(result$value$mode, c("PR", "UNK"))
  expect_match(result$messages, "There were 1 records for which the mode")
})

test_that("other area summaries describe flags and leave rows intact", {
  fixtures <- list(
    AREA = data.frame(AREA = c(4, 5), AGENCY = "W"),
    AREA_X = data.frame(AREA_X = c("M", "1"), WGT_AB1 = 1),
    AGENCY_FISHED_AREA_NAME = data.frame(
      AGENCY_FISHED_AREA_NAME = c("PUNCH CARD AREA 1", "PUNCH CARD AREA 20"),
      STATE_NAME = "WASHINGTON",
      RECFIN_PORT_NAME = "WESTPORT",
      AGENCY_WATER_AREA_NAME = "OCEAN"
    ),
    SURVEY_PROGRAM_CATCH_AREA_NAME = data.frame(
      SURVEY_PROGRAM_CATCH_AREA_NAME = c("PUNCH CARD AREA 1", "PUNCH CARD AREA 20"),
      SAMPLING_AGENCY_NAME = "WDFW",
      PORT_NAME = "WESTPORT"
    )
  )
  for (source in names(fixtures)) {
    data <- fixtures[[source]]
    result <- capture_cli(getArea(data, source = source))
    expect_equal(nrow(result$value), nrow(data))
    expect_equal(sum(result$value$remove == "area"), 1)
    expect_match(result$messages, "flagged for removal")
    expect_false(grepl("were removed", result$messages))
    expect_message(getArea(data, source = source, verbose = FALSE), NA)
  }

  data <- data.frame(AREA_X = 5, LNGTH = 100, ST = 41)
  result <- capture_cli(getArea(data, source = "AREA_X"))
  expect_equal(nrow(result$value), nrow(data))
  expect_match(result$messages, "There were 1 records from Unavailable")
})

test_that("age join summaries distinguish omitted reads from flagged age rows", {
  age_data <- data.frame(
    SAMPLE_ID = c(1, 1, 2, 3),
    USE_THIS_AGE = c(5, 6, NA, 8),
    SAMPLE_YEAR = 2004,
    RECFIN_SPECIES_NAME = "ROCKFISH",
    PORT_NAME = "WESTPORT",
    RECFIN_MODE_NAME = "Private",
    RECFIN_LENGTH_MM = 100,
    RECFIN_SEX_CODE = 1,
    RECFIN_SEX_NAME = "MALE"
  )
  len_data <- data.frame(
    BIO_DETAIL_ID = 1:2,
    RECFIN_YEAR = 2004,
    SPECIES_NAME = "ROCKFISH",
    RECFIN_PORT_NAME = "WESTPORT",
    RECFIN_MODE_NAME = "Private",
    RECFIN_LENGTH_MM = 100,
    RECFIN_SEX_CODE = 1,
    RECFIN_SEX_NAME = "MALE"
  )
  result <- capture_cli(getAges(len_data, age_data))
  expect_equal(nrow(result$value$len_data), nrow(len_data))
  expect_equal(nrow(result$value$age_data), nrow(age_data))
  expect_equal(result$value$age_data$remove, c("no", "multRead", "naAge", "no"))
  expect_match(result$messages, "1 duplicate age reads omitted before joining")
  expect_match(result$messages, "2 age records not added to the length data, including duplicate reads and unmatched records")
  expect_match(result$messages, "1 duplicate reads and 1 records missing.*flagged for removal")
  expect_message(getAges(len_data, age_data, verbose = FALSE), NA)
})