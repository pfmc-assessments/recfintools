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
#' @param type A vector specifying the type of the data. Available options
#' include "recent" for estimates from recent state sponsored surveys; "mrfss" 
#' for estimates from the MRFSS survey; or "hist" for estimates from the
#' historical reconstructions by state. There is no default so the user must 
#' specify a valid option.
#' @param apex The specific recfin apex report that you want to reproduce. 
#' This only works when type equals "recent". Available options include
#' "CTE001" and "CTE501". Defaults to FALSE, which gives the full raw sql data.    
#'
#' @return A character string formatted as an sql call. For type = "hist", the
#' character string is returned as a list
#' @author Brian J Langseth
#' @name sql

sql_catch <- function(species_name, type, apex = FALSE) {
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
    
    if(apex == "CTE001"){
      #Based on CTE001
      sqlcall <- glue::glue(
          "
        SELECT
          recfin_year,
          recfin_month,
          recfin_week,
          agency,
          initcap(lower(district_name)) as district_name,
          initcap(lower(recfin_mode_name)) as recfin_mode_name,
          initcap(lower(recfin_water_area_name)) as recfin_water_area_name,
          initcap(lower(recfin_subregion_name)) as recfin_subregion_name,
          initcap(lower(recfin_trip_type_name)) as recfin_trip_type_name,
          initcap(lower(species_name)) as species_name,
          sum(retained_num) as sum_retained_num,
          sum(retained_kg) * 0.001 as sum_retained_mt,
          sum(released_alive_num) as sum_released_alive_num,
          sum(released_alive_kg) * 0.001 as sum_released_alive_mt,
          sum(released_dead_num) as sum_released_dead_num,
          sum(released_dead_kg) * 0.001 as sum_released_dead_mt,
          sum(total_mortality_num) as sum_total_mortality_num,
          sum(total_mortality_kg) * 0.001 as sum_total_mortality_mt
        FROM
          RECFIN_MARTS.COMPREHENSIVE_REC_CATCH_EST
        WHERE SPECIES_NAME = {toupper(species)}
          AND (agency != 'W' OR SURVEY_PROGRAM_CATCH_AREA_CODE NOT IN ('5','84'))
        GROUP BY
          recfin_year,
          recfin_month,
          recfin_week,
          agency,
          district_name,
          recfin_mode_name,
          recfin_water_area_name,
          recfin_subregion_name,
          recfin_trip_type_name,
          species_name
        ORDER BY
          agency,
          district_name,
          recfin_water_area_name,
          species_name,
          recfin_year,
          recfin_month,
          recfin_week
        "
      )
    }
    
    if(apex == "CTE501"){
      #Based on CTE501
      sqlcall <- glue::glue(
        "
        SELECT 
          c.state_name,
          c.recfin_year,
          c.recfin_month,
          c.recfin_week,
          c.estimate_source,
          c.recfin_port_name ,
          c.recfin_subregion_name,
          c.recfin_trip_type_name,
          c.trip_type_detail_name,
          c.recfin_mode_name,
          c.recfin_water_area_name,
          c.survey_program_catch_area_name,
          c.recfin_catch_area_name,
          c.water_fished_country_name,
          c.species_name,
          c.scientific_name,
          c.species_group_name,
          c.stock_complex_name,
          c.pfmc_fishery_management_plan,
          c.ACL_CODE,
          c.released_dead_num,
          c.released_alive_num,
          c.retained_num,
          c.total_mortality_num,
          c.retained_average_weight,
          c.released_average_weight,
          c.released_dead_kg * 0.001 as released_dead_mt,
          c.released_alive_kg * 0.001 as released_alive_mt,
          c.retained_kg * 0.001 as retained_mt,
          c.total_mortality_kg * 0.001 as total_mortality_mt
        FROM 
          RECFIN_MARTS.COMPREHENSIVE_REC_CATCH_EST c
        WHERE SPECIES_NAME = {toupper(species)}
        "
      )
    }
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
