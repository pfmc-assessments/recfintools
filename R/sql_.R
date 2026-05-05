#' Write SQL text
#'
#' Write SQL text as a single character string that will result in getting the
#' relevant data from the RecFIN database.
#' 
#' Basing on the similar file in pacfintools
#' 
#' @param species_name A vector of strings specifying the RecFIN species name
#' desired. Must be a valid name, in all caps. For list of species codes see sql_species.   
#'
#' @return A single character string formatted as an sql call.
#' @author Brian J Langseth 
#' @name sql
NULL
#'
#' @rdname sql
#' @details `sql_catch()` results in recent catch data
sql_catch <- function(species_name) {
  species <- paste(sQuote(species_name, q = FALSE), collapse = ", ")
  stopifnot(length(species) == 1)
  
  sqlcall <- glue::glue(
    "
    SELECT *
    FROM RECFIN_MARTS.COMPREHENSIVE_REC_CATCH_EST
    WHERE SPECIES_NAME = {species}
    "
  )
  sqlcall <- gsub("\\n", " ", sqlcall)
  return(sqlcall)
}

#'
#' @rdname sql
#' @details `sql_species()` results in data frame of species names
sql_species <- function() {
  sqlcall <- glue::glue(
    "
    SELECT DISTINCT SPECIES_NAME, SCIENTIFIC_NAME
    FROM RECFIN_MARTS.COMPREHENSIVE_REC_CATCH_EST
    ORDER BY SPECIES_NAME, SCIENTIFIC_NAME;
    "
  )
  sqlcall <- gsub("\\n", " ", sqlcall)
  return(sqlcall)
}