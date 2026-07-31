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

  # Recent years surveys corresponding to CRFS, ORBS, or OSP samples
  if (type == "recent") {
    sqlcall <- glue::glue(
      "
      SELECT *
      FROM RECFIN_MARTS.COMPREHENSIVE_REC_CATCH_EST
      WHERE SPECIES_NAME = ANY ({toupper(species)})
      "
    )

    if (apex == "CTE001") {
      # Based on CTE001
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
        WHERE SPECIES_NAME = ANY ({toupper(species)})
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

    if (apex == "CTE501") {
      # Based on CTE501
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
        WHERE SPECIES_NAME = ANY ({toupper(species)})
        "
      )
    }
    sqlcall <- gsub("\\n", " ", sqlcall)
  }

  # Catches from years during MRFSS sampling
  # As there is no official apex report for this, build own.
  # Cut off data to 2004 and before for CA, 2003 and before for OR and WA
  if (type == "mrfss") {
    sqlcall <- glue::glue(
      "
      SELECT *
      FROM RECFIN_MARTS.COMPREHENSIVE_REC_LEGACY_ESTIMATES
      WHERE COMMON = ANY ({toupper(species)})
        AND ((ST = 6 AND YEAR <= 2004) OR (ST != 6 AND YEAR < 2004))
      "
    )
    sqlcall <- gsub("\\n", " ", sqlcall)
  }

  # Catches from historical reconstructions of each state
  # A few fields (RECFIN_LOG_ID for WA and CA, and SURVEY_PROGRAM_ID for CA)
  # are not selected in apex report, so write out each rather for those states
  # but for Oregon select all
  if (type == "hist") {
    sqlcall_W <- glue::glue(
      "
      SELECT
        agency_code,
        agency,
        state_name,
        recfin_year,
        area,
        recfin_species_code,
        agency_species_name,
        species_name,
        scientific_name,
        pfmc_fishery_management_plan,
        species_group_name,
        stock_complex_name,
        pacfin_species_code,
        retained_num,
        recfin_vdate
      FROM RECFIN_MARTS.COMPREHENSIVE_WDFW_HISTORIC_REC_CATCH_EST
      WHERE SPECIES_NAME = ANY ({species})
      "
    )
    sqlcall_O <- glue::glue(
      "
      SELECT *
      FROM RECFIN_MARTS.COMPREHENSIVE_ODFW_HISTORIC_REC_CATCH_EST
      WHERE SPECIES_NAME = ANY ({stringr::str_to_title(species)})
      "
    )
    sqlcall_C <- glue::glue(
      "
      SELECT
        CA_CATCH_RECON_ID,
        YEAR,
        SURVEY_PROGRAM_CODE,
        SURVEY_PROGRAM_NAME,
        AGENCY_CODE,
        AGENCY,
        STATE_NAME,
        SURVEY_PROGRAM_MODE_CODE,
        SURVEY_PROGRAM_MODE_NAME,
        RECFIN_MODE_CODE,
        RECFIN_MODE_NAME,
        SURVEY_PROGRAM_AREA_NAME,
        SURVEY_PROGRAM_AREA_DESCRIPTION,
        SURVEY_PROGRAM_SPECIES_CODE,
        SURVEY_PROGRAM_SPECIES_NAME,
        RECFIN_SPECIES_CODE,
        SPECIES_NAME,
        SCIENTIFIC_NAME,
        PFMC_FISHERY_MANAGEMENT_PLAN,
        SPECIES_GROUP_NAME,
        STOCK_COMPLEX_NAME,
        PACFIN_SPECIES_CODE,
        RETAINED_NUM AS RETAINED_NUMBER,
        RETAINED_LBS,
        RETAINED_KG,
        RETAINED_MT,
        RECFIN_VDATE
      FROM RECFIN_MARTS.COMPREHENSIVE_NOAA_CA_CATCH_RECON_REC
      WHERE SPECIES_NAME = ANY ({stringr::str_to_title(species)})
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


#'
#' @rdname sql
#' @details `sql_bds`
#'
#' @param type A vector specifying the type of the data. Available options
#' include "recent" for estimates from recent state sponsored surveys; and
#' "mrfss" for estimates from the MRFSS survey. There is no default so the user
#' must specify a valid option.
#' @param apex The specific recfin apex report that you want to reproduce.
#' Available options include "SD001" and "SD501" (which are for lengths) and
#' "SD506" (which is for ages) when type equals "recent", and "SD508" and "SD509"
#' when type equals "mrfss". There is no default so the user must specify a
#' valid option. Currently, there is no option to keep just the raw sql data.
#'
sql_bds <- function(species_name, type, apex) {
  species <- paste(sQuote(species_name, q = FALSE), collapse = ", ")
  stopifnot(length(species) == 1)

  # Recent years surveys corresponding to CRFS, ORBS, or OSP samples
  if (type == "recent") {
    if (apex == "SD001") {
      # Based on SD001
      sqlcall <- glue::glue(
        "
        SELECT
          cbd.bio_detail_id,
          cbd.state_name,
          cbd.recfin_year,
          CASE
            WHEN cbd.recfin_port_code is null then 'NOT KNOWN'
            ELSE cbd.recfin_port_name
          END as recfin_port_name,
          CASE
            WHEN cbd.recfin_trip_type_code is null then 'NOT KNOWN'
            ELSE cbd.recfin_trip_type_name
          END as recfin_trip_type_name,
          cbd.agency_water_area_name,
          cbd.agency_fished_area_name ,
          CASE
              WHEN cbd.recfin_mode_code is null then 'NOT KNOWN'
              ELSE cbd.recfin_mode_name
          END as recfin_mode_name,
          cbd.species_name,
          cbd.scientific_name,
          cbd.species_group_name,
          cbd.stock_complex_name,
          cbd.fishery_management_plan ,
          cbd.agency_length,
          cbd.agency_length_units,
          cbd.is_agency_length_within_max,
          cbd.agency_weight,
          cbd.agency_weight_units,
          cbd.recfin_length_mm,
          null as recfin_imputed_length,
          cbd.recfin_length_type,
          cbd.recfin_imputed_weight_kg,
          cbd.recfin_sex_code,
          cbd.recfin_sex_name,
          CASE
              WHEN cbd.is_retained = 'T' THEN 'RETAINED'
              WHEN cbd.is_retained = 'F' THEN 'RELEASED'
              ELSE 'UNKNOWN'
          END is_retained,
          CASE
              WHEN cbd.caught_by_observed_angler = 'T' THEN 'YES'
              WHEN cbd.caught_by_observed_angler = 'F' THEN 'NO'
              ELSE cbd.caught_by_observed_angler
          END caught_by_observed_angler,
          cbd.source_code
        FROM
          RECFIN_MARTS.COMPREHENSIVE_BIO_DETAIL cbd
        LEFT JOIN recfin_foundation.agency_fished_area afa
          ON cbd.agency_code = afa.agency_code
          AND cbd.agency_fished_area_code = afa.agency_fished_area_code
        WHERE SPECIES_NAME = ANY ({toupper(species)})
          AND (agency_length is not null
          OR agency_weight is not null)
        "
      )
    }

    if (apex == "SD501") {
      # Based on SD501
      sqlcall <- glue::glue(
        "
        SELECT
          cbd.bio_detail_id,
          cbd.state_name,
          cbd.recfin_year,
          cbd.recfin_date,
          cbd.county_number ,
          cbd.interview_site,
          CASE
            WHEN cbd.recfin_port_code is null then 'NOT KNOWN'
            ELSE cbd.recfin_port_name
          END as recfin_port_name,
          CASE
            WHEN cbd.recfin_trip_type_code is null then 'NOT KNOWN'
            ELSE cbd.recfin_trip_type_name
          END as recfin_trip_type_name,
          cbd.agency_water_area_name,
          cbd.agency_fished_area_name ,
          CASE
            WHEN cbd.recfin_mode_code is null then 'NOT KNOWN'
            ELSE cbd.recfin_mode_name
          END as recfin_mode_name,
          cbd.fishery_management_plan ,
          cbd.stock_complex_name,
          cbd.species_group_name,
          cbd.species_name,
          cbd.scientific_name,
          cbd.agency_length,
          cbd.agency_length_units,
          cbd.is_agency_length_within_max,
          cbd.agency_weight,
          cbd.agency_weight_units,
          cbd.recfin_length_mm,
          null as recfin_imputed_length,
          CASE /* This is added by me because Total and Fork length types read out as True/False */
            WHEN cbd.recfin_length_type = 'T' THEN 'TOTAL'
            WHEN cbd.recfin_length_type = 'F' THEN 'FORK'
            ELSE 'UNKNOWN'
          END recfin_length_type,
          cbd.recfin_imputed_weight_kg,
          CASE
            WHEN cbd.is_retained = 'T' THEN 'RETAINED'
            WHEN cbd.is_retained = 'F' THEN 'RELEASED'
            ELSE 'UNKNOWN'
          END is_retained,
          CASE
            WHEN cbd.caught_by_observed_angler = 'T' THEN 'YES'
            WHEN cbd.caught_by_observed_angler = 'F' THEN 'NO'
            ELSE cbd.caught_by_observed_angler
          END caught_by_observed_angler,
          cbd.source_code,
          cbd.recfin_sex_code,
          cbd.recfin_sex_name,
          cbd.interview_time,
          cbd.cpfv_location_id
        FROM
          RECFIN_MARTS.COMPREHENSIVE_BIO_DETAIL cbd
        LEFT JOIN recfin_foundation.agency_fished_area afa
          ON cbd.agency_code = afa.agency_code
          AND cbd.agency_fished_area_code = afa.agency_fished_area_code
        WHERE SPECIES_NAME = ANY ({toupper(species)})
          AND (agency_length is not null
          OR agency_weight is not null)
        "
      )
    }

    if (apex == "SD506") {
      # Based on SD506 for ages
      sqlcall <- glue::glue(
        "
        WITH base AS (
          SELECT
            SAMPLE_ID,
            AGEING_ID,
            CASE
              WHEN SAMPLING_AGENCY_NAME = 'O' THEN
                'ODFW'
              WHEN SAMPLING_AGENCY_NAME = 'W' THEN
                'WDFW'
              ELSE SAMPLING_AGENCY_NAME
            END SAMPLING_AGENCY_NAME,
            SAMPLING_AGENCY_NAME AS SAMPLING_AGENCY_CODE,
            AGEING_LOCATION,
            AGEING_AGENCY_NAME,
            AGED_BY,
            READ_DATE,
            EQUIPMENT_DESCRIPTION,
            RECFIN_STRUCTURE_DESCRIPTION,
            CLARITY_DESCRIPTION,
            AGE_READABILITY_DESCRIPTION,
            RECFIN_AGEING_METHOD_DESC,
            RECFIN_SELECTION_METHOD_DESC,
            EDGE_TYPE_DESCRIPTION,
            READ_ESTIMATE,
            USE_THIS_AGE,
            MULTIPLE_READS,
            RECFIN_READ_NUMBER,
            NUMBER_OF_READS,
            AGE_COMMENTS,
            SAMPLE_DATE,
            SAMPLE_YEAR,
            SAMPLE_MONTH,
            PORT_NAME,
            SURVEY_PROGRAM_CATCH_AREA_CODE,
            SURVEY_PROGRAM_CATCH_AREA_NAME,
            RECFIN_CATCH_AREA_ID,
            RECFIN_CATCH_AREA_NAME,
            VESSEL_NAME,
            NVL(RECFIN_MODE_CODE,9) as RECFIN_MODE_CODE_QUERY,
            RECFIN_MODE_CODE,
            RECFIN_MODE_NAME,
            RECFIN_SPECIES_NAME,
            REEF_NUMBER,
            CUBICLE_NUMBER,
            SAMPLER_NAME,
            SAMPLE_COMMENTS,
            RECFIN_SEX_CODE,
            RECFIN_SEX_NAME,
            MEASURED_LENGTH,
            LENGTH_UNITS,
            LENGTH_TYPE,
            RECFIN_LENGTH_MM,
            RETURN_TIME
          FROM
            RECFIN_MARTS.COMPREHENSIVE_REC_AGEING b
          )
        SELECT
          SAMPLE_ID,
          AGEING_ID,
          SAMPLING_AGENCY_NAME,
          AGEING_LOCATION,
          AGEING_AGENCY_NAME,
          AGED_BY,
          READ_DATE,
          EQUIPMENT_DESCRIPTION,
          RECFIN_STRUCTURE_DESCRIPTION,
          CLARITY_DESCRIPTION,
          AGE_READABILITY_DESCRIPTION,
          RECFIN_AGEING_METHOD_DESC,
          RECFIN_SELECTION_METHOD_DESC,
          EDGE_TYPE_DESCRIPTION,
          READ_ESTIMATE,
          USE_THIS_AGE,
          MULTIPLE_READS,
          RECFIN_READ_NUMBER,
          NUMBER_OF_READS,
          AGE_COMMENTS,
          SAMPLE_DATE,
          SAMPLE_YEAR,
          SAMPLE_MONTH,
          PORT_NAME,
          SURVEY_PROGRAM_CATCH_AREA_CODE,
          SURVEY_PROGRAM_CATCH_AREA_NAME,
          RECFIN_CATCH_AREA_ID,
          RECFIN_CATCH_AREA_NAME,
          VESSEL_NAME,
          RECFIN_MODE_CODE,
          RECFIN_MODE_NAME,
          RECFIN_SPECIES_NAME,
          REEF_NUMBER,
          CUBICLE_NUMBER,
          SAMPLER_NAME,
          SAMPLE_COMMENTS,
          RECFIN_SEX_CODE,
          RECFIN_SEX_NAME,
          MEASURED_LENGTH,
          LENGTH_UNITS,
          LENGTH_TYPE,
          RECFIN_LENGTH_MM,
          RETURN_TIME
        FROM
          base t
        WHERE RECFIN_SPECIES_NAME = ANY ({toupper(species)})
        "
      )
    }
    sqlcall <- gsub("\\n", " ", sqlcall)
  }

  # Biological data from years during MRFSS sampling
  if (type == "mrfss") {
    if (apex == "SD508") {
      # Based on SD508 bio data for unavailable catch (Type 2 - B1 and B2)
      sqlcall <- glue::glue(
        "
        SELECT
          crl.ID_CODE,
          crl.YEAR,
          crl.WAVE,
          crl.MONTH,
          crl.WEEK,
          crl.TIME,
          crl.DATE1,
          crl.ST,
          CASE  /* Manually adding ST_NAME into script */
            WHEN crl.ST = 6 THEN
              'California'
            WHEN crl.ST = 41 THEN
              'Oregon'
            WHEN crl.ST = 53 THEN
              'Washington'
          END AS ST_NAME,
          crl.CNTY,
          crl.SUB_REG,
          CASE  /* Manually adding ST_NAME into script */
            WHEN crl.SUB_REG = 1 THEN
              'Southern California'
            WHEN crl.SUB_REG = 2 THEN
              'Northern California'
            WHEN crl.SUB_REG = 3 THEN
              'Oregon'
            WHEN crl.SUB_REG = 4 THEN
              'Washington'
          END AS SUB_REG_NAME,
          crl.DIST,
          crl.MODE_FX,
          /* MODE_FX_NAME, */
          crl.MODE_F,
          /* MODE_F_NAME,	*/
          crl.AREA_X,
          /* AREA_X_NAME,	*/
          crl.AREA,
          /* AREA_NAME, */
          crl.PORT,
          crl.SP_CODE,
          rs.SPECIES_NAME AS SP_NAME,
          crl.PRIM1,
          crl.PRIM2,
          crl.INTSITE,
          crl.GEAR,
          crl.HRSF,
          crl.CNTRBTRS,
          crl.NUM_TYP2,
          crl.NUM2,
          crl.NUM_FISH,
          crl.PUNCH,
          crl.ADD_HRS,
          crl.ID_CODE2,
          crl.DISPO,
          crl.\"NUMBER\", /* Syntax needed because NUMBER is a special keyword in oracle */
          crl.C,
          crl.FSHINSP,
          crl.AREA_NC,
          crl.SP_OCDE,
          crl.NUM_TYP4,
          crl.CATCH,
          crl.STATUS,
          crl.INVALID,
          crl.SALMON,
          crl.SHORT,
          crl.CODE,
          crl.SP,
          crl.FFDAYS2,
          crl.FFDAYS12,
          crl.TRIPSAMP,
          crl.DISP3,
          crl.SFCODE,
          crl.HLOC,
          crl.DISTRICT,
          crl.ASSNID,
          crl.CRFS,
          crl.RECN,
          crl.SPN,
          crl.LOCN,
          crl.DEPTHN,
          crl.SURVEY,
          crl.TRIPTYPE,
          crl.DEPTH,
          crl.SPECIES,
          crl.ADFISH,
          crl.HLOC2,
          crl.TBENC_DATE,
          crl.P,
          crl.DD,
          crl.ALPHA5,
          crl.REF_NUM,
          crl.RELS_DD,
          crl.RELDEVNUM,
          crl.DEPTHFT,
          crl.DEPTHNR,
          crl.RECFIN_VDATE
        FROM
          RECFIN_MARTS.COMPREHENSIVE_REC_LEGACY_TYPE_2 crl
        LEFT JOIN
          RECFIN_FOUNDATION.RECFIN_SPECIES rs
          ON crl.SP_CODE = TO_CHAR(rs.RECFIN_SPECIES_CODE)
        WHERE
          rs.SPECIES_NAME = ANY ({stringr::str_to_title(species)}) /* Renamed as SP_NAME above but need to use original name here */
        "
      )
    }

    if (apex == "SD509") {
      # Based on SD509 bio data for available catch (Type 3 - A)
      sqlcall <- glue::glue(
        "
        SELECT
          crl.ID_CODE,
          crl.YEAR,
          crl.WAVE,
          crl.MONTH,
          crl.WEEK,
          crl.TIME,
          crl.DATE1,
          crl.ST,
          CASE  /* Manually adding ST_NAME into script */
            WHEN crl.ST = 6 THEN
              'California'
            WHEN crl.ST = 41 THEN
              'Oregon'
            WHEN crl.ST = 53 THEN
              'Washington'
          END AS ST_NAME,
          crl.CNTY,
          crl.SUB_REG,
          CASE  /* Manually adding ST_NAME into script */
            WHEN crl.SUB_REG = 1 THEN
              'Southern California'
            WHEN crl.SUB_REG = 2 THEN
              'Northern California'
            WHEN crl.SUB_REG = 3 THEN
              'Oregon'
            WHEN crl.SUB_REG = 4 THEN
              'Washington'
          END AS SUB_REG_NAME,
          crl.DIST,
          crl.MODE_FX,
          /* MODE_FX_NAME, */
          crl.MODE_F,
          /* MODE_F_NAME,	*/
          crl.AREA_X,
          /* AREA_X_NAME,	*/
          crl.AREA,
          /* AREA_NAME, */
          crl.PORT,
          crl.SP_CODE,
          rs.SPECIES_NAME AS SP_NAME,
          crl.PRIM1,
          crl.PRIM2,
          crl.INTSITE,
          crl.GEAR,
          crl.HRSF,
          crl.CNTRBTRS,
          crl.NUM_TYP3,
          crl.NUM3,
          crl.NUM_FISH,
          crl.PUNCH,
          crl.ADD_HRS,
          crl.ID_CODE3,
          crl.DISPO,
          crl.\"NUMBER\", /* Syntax needed because NUMBER is a special keyword in oracle */
          crl.C,
          crl.FSHINSP,
          crl.AREA_NC,
          crl.LNGTH,
          crl.WGT,
          crl.X1,
          crl.T_LEN,
          crl.OLD_WGT,
          crl.WGT_FLAG,
          crl.OLD_LEN,
          crl.RIG,
          crl.DISP3,
          crl.LEADER,
          crl.OLDWGT,
          crl.FISHINSP,
          crl.NUM_TYP4,
          crl.CATCH,
          crl.A_FT,
          crl.B_FT,
          crl.R,
          crl.Z,
          crl.STATUS,
          crl.INVALID,
          crl.TEMP,
          crl.SALMON,
          crl.SHORT,
          crl.F_SEX,
          crl.SP_CPDE,
          crl.LENGTH,
          crl.FFDAYS2,
          crl.FFDAYS12,
          crl.TRIPSAMP,
          crl.FSEX,
          crl.LEN,
          crl.SFCODE,
          crl.HLOC,
          crl.TAG,
          crl.DISTRICT,
          crl.ASSNID,
          crl.CRFS,
          crl.RECN,
          crl.SPN,
          crl.LOCN,
          crl.DEPTHN,
          crl.SURVEY,
          crl.NRS,
          crl.MEASN,
          crl.LENFLAG,
          crl.REC,
          crl.TRIPTYPE,
          crl.DEPTH,
          crl.SPECIES,
          crl.CWTFISH,
          crl.ADFISH,
          crl.OTOFISH,
          crl.HLOC3,
          crl.SCAN_RSLT,
          crl.MAXLEN,
          crl.HEART,
          crl.TBENC_DATE,
          crl.DD,
          crl.P,
          crl.PC,
          crl.SP,
          crl.BT,
          crl.TRIPSPECIES,
          crl.TT,
          crl.ALPHA5,
          crl.TINY,
          crl.MICRO,
          crl.REF_NUM,
          crl.RELDEVNUM,
          crl.DEPTHFT,
          crl.DEPTHNR,
          crl.RECFIN_VDATE
        FROM
          RECFIN_MARTS.COMPREHENSIVE_REC_LEGACY_TYPE_3 crl
        LEFT JOIN
          RECFIN_FOUNDATION.RECFIN_SPECIES rs
          ON crl.SP_CODE = TO_CHAR(rs.RECFIN_SPECIES_CODE)
        WHERE
          rs.SPECIES_NAME = ANY ({stringr::str_to_title(species)}) /* Renamed as SP_NAME above but need to use original name here */
        "
      )
    }
    sqlcall <- gsub("\\n", " ", sqlcall)
  }
  return(sqlcall)
}
