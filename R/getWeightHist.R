#' Calculate and add weight data to historical catches so that catch in weight 
#' can be produced. 
#' 
#' @details
#' This script contains a function that takes historical catches for Oregon 
#' (and in the future for Washington) which are in number, and adds a weight
#' column so that catches can be in weight. This function requires inputs from 
#' both catch and composition data. Weight data is calculated from the 
#' composition data and a `calc_wgt_kg` and `calc_wgt_n` are added to the catch 
#' dataset.
#'  
#' Calculated weight is the average weight by mode and year when mode data exists, 
#' and year when mode data does not exist. For years without weight data, the 
#' overall average (over all modes and years) is used. `calc_wgt_n` is the sample 
#' size used to calculate `calc_wgt_kg`. 
#' 
#' This function has the option to return a figure showing the calculated
#' average weight and sample size. Users should look at this figure to confirm 
#' values and assumptions are appropriate for their species. Should the user 
#' wish to apply a different approach to interpolate missing years, they can 
#' with the information returned from this function. Should a user wish to apply 
#' different ways to calculate weight, feel free to post a github issue, email 
#' the maintainer, or submit a pull request.
#'
#' @section Oregon Historical weights:
#' Weight data is obtained from type 3 MRFSS data (SD509). Only measured weights
#' are used (based on the assumption that measured weights contain two or fewer
#' decimal places and are not zero), from PR/PC modes (MODE_FX = 6 or 7), and 
#' ocean areas (AREA_X = 1 - 4). 
#' 
#' MRFSS samples are missing for some years where catch in numbers exist (e.g. 
#' 1979, 1990-1992). Weights are applied for these years based on an overall 
#' average from all years and modes. Sample sizes for these interpolated years
#' are NA. 
#' 
#' @section Washington Historical weights:
#' 
#' #to do: Add later
#' 
#' @import patchwork
#' @import ggplot2
#' 
#' @export
#' @seealso [clean_catch()] calls 'getWeightHist'
#' @author Brian Langseth and Ali Whitman
#' @return The data frame `catch_data` with a new column of calculated 
#' weight by year `calc_wgt_kg` and samples sizes `calc_wgt_n` used in the 
#' calculation.
#' 
#' 
#' @param catch_data Dataset that contains the state specific historical catch 
#' data as returned by `pull_catch_recfin`.
#' @param bds_data Dataset that contains the weight data as returned by 
#' `pull_bds_recfin`. The current script is coded for type 3 MRFSS data (SD509).
#' @param figure Whether to output a figure showing the average weights 
#' by mode and sample sizes in each year that catch is available. Default is 
#' TRUE. Currently, this function does not save the figure.
#' @param state The state for which average weights are calculated. Can be
#' "WA" or "OR" for Washington or Oregon historical data, respectively. Currently,
#' only "OR" is available.
#' @param verbose  Whether to output detailed information about material added 
#' by this function. Default is TRUE.
#' 

getWeightHist <- function(
    catch_data,
    bds_data,
    figure = TRUE,
    state = NULL,
    verbose = TRUE
) {
  
  if(state == "OR"){
    
    ##
    #Calculate weight and sample sizes
    ## 
    
    or_bds <- bds_data |>
      dplyr::filter(ST == 41)
    
    #Add flags to LNGTH (fork length mm), T_LEN (total length mm), and weight 
    #(kg) when these are likely not direct measurements. Direct measurements
    #are assumed to be lengths in mm with no decimals, and weights in kg with
    #less than 3 decimals. While SD509 includes flags for wgt already, these 
    #do not appear accurate.
    
    #to do: eventually set these up as their own function (getMeasured)
    
    or_bds$lngth_flag <- ifelse(or_bds$LNGTH %in% floor(or_bds$LNGTH),
                          ifelse(is.na(or_bds$LNGTH), "missing", "measured"),
                          "computed")
    
    or_bds$t_len_flag <- ifelse(or_bds$T_LEN %in% floor(or_bds$T_LEN),
                          ifelse(is.na(or_bds$T_LEN), "missing", "measured"),
                          "computed")
    
    or_bds$n_wgt_decimals <- count_decimals(or_bds$WGT) 
    or_bds$wgt_flag <- ifelse(is.na(or_bds$WGT), "missing",
                              ifelse(or_bds$n_wgt_decimals <= 2,"measured","computed"))
    
    #Calculate weights, filtering for mode, area, and measured weight
    avg_wgt_mode <- or_bds |>
      dplyr::group_by(YEAR, MODE_FX) |> 
      dplyr::filter(MODE_FX %in% c(6,7),
                    AREA_X %in% c(1:4),
                    wgt_flag == "measured",
                    WGT > 0) |>
      dplyr::summarise(calc_wgt_kg = mean(WGT), 
                       calc_wgt_n = dplyr::n(),
                       .groups = "drop") |>
      as.data.frame()
    
    avg_wgt_year <- or_bds |>
      dplyr::group_by(YEAR) |> 
      dplyr::filter(MODE_FX %in% c(6,7),
                    AREA_X %in% c(1:4),
                    wgt_flag == "measured",
                    WGT > 0) |>
      dplyr::summarise(calc_wgt_kg = mean(WGT), 
                       calc_wgt_n = dplyr::n()) |>
      as.data.frame()
    
    ##
    #Add calculated weight and sample sizes to the catch dataset
    ##
    
    #First do it by mode, because the oregon historical reconstruction only
    #has mode starting in 1988. This way mode-specific weights are assigned, and
    #records without modes are assigned as NA.
    temp_catch_data <- dplyr::left_join(
      catch_data, avg_wgt_mode, 
      dplyr::join_by("YEAR" == "YEAR", 
                     "RECFIN_MODE_CODE" == "MODE_FX"))
    
    #Second, replace the NA values for records without modes with yearly averages 
    catch_data <- temp_catch_data |>
      dplyr::left_join(avg_wgt_year, 
                       by = "YEAR") |>
      dplyr::mutate(calc_wgt_kg = dplyr::coalesce(calc_wgt_kg.x, calc_wgt_kg.y)) |>
      dplyr::mutate(calc_wgt_n = dplyr::coalesce(calc_wgt_n.x, calc_wgt_n.y)) |>
      dplyr::select(-calc_wgt_kg.x, -calc_wgt_kg.y, 
                    -calc_wgt_n.x, -calc_wgt_n.y)
    
    #Third, calculate and add an overall average weight across years and modes 
    #for catch records in years where no weight data exist 
    interp_values <- catch_data[is.na(catch_data$calc_wgt_kg), c("YEAR", "RECFIN_MODE_CODE")]
    interp_values$interp_wgt <- mean(catch_data$calc_wgt_kg, na.rm = TRUE)
    catch_data[is.na(catch_data$calc_wgt_kg), "calc_wgt_kg"] = mean(catch_data$calc_wgt_kg, na.rm = TRUE)
    
    #Produce figure of average weight and sample size if user selected to do so
    if(figure){
      
      plot_wgt <- 
        ggplot(catch_data, aes(x = YEAR, y = calc_wgt_kg, 
                             group = RECFIN_MODE_CODE,
                             color = factor(RECFIN_MODE_CODE))) +
        geom_line() + 
        geom_point() +
        scale_x_continuous(limits = c(1979, 2001)) + 
        scale_color_manual(
          values = c("6" = "#F8766D", "7" = "#00BA38", "9" = "#619CFF", "Interp" = "black"),
          labels = c("6" = "PC", "7" = "PR", "9" = "Not mode specific", "Interp" = "Interpolated")
        ) + 
        labs(color = "",
             y = "Calculated average weight (kg)") +
        theme(
          legend.position = "inside",
          legend.position.inside = c(0.5, 1.0),
          legend.justification.inside = c(0.5, 1.0),
          legend.direction = "horizontal",
          legend.background = element_blank()) +
        
        #Add in interpolated (overall average) weights
        geom_line(data = interp_values, 
                  aes(x = YEAR, y=interp_wgt, color = "Interp")) +
        geom_point(data = interp_values, 
                  aes(x = YEAR, y=interp_wgt, color = "Interp"))

      plot_n <- 
        ggplot(catch_data, aes(x = YEAR, y = calc_wgt_n, 
                             group = RECFIN_MODE_CODE,
                             fill = factor(RECFIN_MODE_CODE))) +
        stat_summary(fun = "mean", geom = "bar", na.rm = TRUE) + 
        scale_fill_discrete(
          labels = c("6" = "PC", 
                     "7" = "PR", 
                     "9" = "Not mode specific")) +
        scale_x_continuous(limits = c(1979, 2001)) + 
        labs(fill = "",
             y = "Sample size to calculate weight") +
        theme(
          legend.position = "inside",
          legend.position.inside = c(0.5, 1.0),
          legend.justification.inside = c(0.5, 1.0),
          legend.direction = "horizontal",
          legend.background = element_blank())
      
      combined_plot <- plot_wgt / plot_n
      
      print(combined_plot)
    }
    
    if (verbose) {
      cli::cli_bullets(c(
        " " = "{.fn getWeightHist} summary information -",
        "i" = "Average weight from MRFSS type 3 data added to Oregon historical 
        as 'calc_wgt_kg' column"
      ))
    }
  }
  
  if(state %in% c("WA", "CA")){
  
    if (verbose) {
      cli::cli_bullets(c(
        " " = "{.fn getWeightHist} summary information -",
        "i" = "Average weight calculations not needed at this time for 
        Washington or California historical catches"
      ))
    }
  }
  
  return(catch_data)
}


#Function to count the number of decimal points of a column of numbers
#This function is robust to values without decimal points, whereas
#just using sum with regular expressions is not.

count_decimals <- function(x) {
  # Convert to character representation safely
  x_str <- as.character(x)
  
  # Check if a decimal point actually exists
  has_decimal <- grepl("\\.", x_str)
  
  # Extract digits after point and calculate length
  decimals_only <- sub("^.*\\.", "", x_str)
  
  # Return character length if decimal exists, otherwise return 0
  ifelse(has_decimal, nchar(decimals_only), 0)
}
