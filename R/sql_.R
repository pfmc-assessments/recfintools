#' Write SQL text
#'
#' Write SQL text as a single character string that will result in getting the
#' relevant data from the RecFIN database.
#'
#' Basing on the similar file in pacfintools
#'
#' @param species_name A vector of strings specifying the RecFIN species name
#' desired. Must be a valid name though case is automatically corrected.
#' For list of species codes see sql_species.
#' @param type A vector specifying the timeframe of the data. Available options
#' include "recent" for estimates from recent state sponsored surveys; "mrfss" 
#' for estimates from the MRFSS survey; or "hist" for estimates from the
#' historical reconstructions by state. There is no default so the user must 
#' specify a valid option.  
#'
#' @return A character string formatted as an sql call. For type = "hist", the
#' character string is returned as a list
#' @author Brian J Langseth
#' @name sql

sql_catch <- function(species_name, type) {
  species <- paste(sQuote(species_name, q = FALSE), collapse = ", ")
  stopifnot(length(species) == 1)
  
  #Recent years surveys corresponding to CRFS, ORBS, or OSP samples
  if(type == "recent"){
    sqlcall <- glue::glue(
      "
      SELECT *
      FROM RECFIN_MARTS.COMPREHENSIVE_REC_CATCH_EST
      WHERE SPECIES_NAME = {toupper(species)}
      "
    )
    sqlcall <- gsub("\\n", " ", sqlcall)
  }
  
  #Catches from years during MRFSS sampling
  if(type == "mrfss"){
    sqlcall <- glue::glue(
      "
    SELECT *
    FROM RECFIN_MARTS.COMPREHENSIVE_REC_LEGACY_ESTIMATES
    WHERE COMMON = {toupper(species)}
    "
    )
    sqlcall <- gsub("\\n", " ", sqlcall)
  }
  
  #Catches from historical reconstructions of each state
  if(type == "hist"){
    sqlcall_W <- glue::glue(
      "
    SELECT *
    FROM RECFIN_MARTS.COMPREHENSIVE_WDFW_HISTORIC_REC_CATCH_EST
    WHERE SPECIES_NAME = {species}
    "
    )
    sqlcall_O <- glue::glue(
      "
    SELECT *
    FROM RECFIN_MARTS.COMPREHENSIVE_ODFW_HISTORIC_REC_CATCH_EST
    WHERE SPECIES_NAME = {stringr::str_to_title(species)}
    "
    )
    sqlcall_C <- glue::glue(
      "
    SELECT *
    FROM RECFIN_MARTS.COMPREHENSIVE_NOAA_CA_CATCH_RECON_REC
    WHERE SPECIES_NAME = {stringr::str_to_title(species)}
    "
    )
    sqlcall_W <- gsub("\\n", " ", sqlcall_W)
    sqlcall_O <- gsub("\\n", " ", sqlcall_O)
    sqlcall_C <- gsub("\\n", " ", sqlcall_C)
    
    sqlcall <- list(
      "WA" = sqlcall_W,
      "OR" = sqlcall_O,
      "CA" = sqlcall_C
    )
  }
  
  return(sqlcall)
}


#'
#' @rdname sql
#' @details `sql_species()` A data frame of species names
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
