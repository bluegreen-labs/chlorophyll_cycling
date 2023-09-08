#' chlorophyll cycling model
#'
#' Models the senescence of vegetation as mass balance of
#' produced and lost chlorophyll in response to temperature
#' and daylength, this in comparison to a threshold based
#' approach which accumulated (chilling) degree days.
#'
#' @param par three parameters specifying the cycling model
#' @param data data consisting of vegetation greenness (G), mean
#'  daytime temperature (T) and daylenght (D) as a data frame
#'
#' @return Vegetation greenness values
#' @export

chlorophyll_cycling <- function(par, data) {

  # split out model parameters
  b0 <- par[1]
  b1 <- par[2]
  b2 <- par[3]

  # set anything after the start period
  # to NA
  data$gcc[2:nrow(data$gcc),] <- NA

  # loop over columns and rows
  for(j in seq(1,ncol(data$gcc))) {

    # set max gcc
    #G_max <- quantile(data$G[,j], 0.95)
    G_max <- data$gcc[1,j]

    for (t in seq(1,nrow(data$gcc))[-1]) {

      # synthesis can be vectorized
      synthesis <- max(b0 + b1 * data$temp[t,j] * data$daylength[t,j], 0)
      previous_pool <- data$gcc[t-1,j]
      breakdown <- b2 * data$gcc[t-1,j]

      # update state of the model
      data$gcc[t,j] <- max(min(previous_pool + synthesis - breakdown, G_max), 0)
    }
  }

  # return data
  return(data$gcc)
}


#' scaled chlorophyll cycling model
#'
#' Models the senescence of vegetation as mass balance of
#' produced and lost chlorophyll in response to temperature
#' and daylength, this in comparison to a threshold based
#' approach which accumulated (chilling) degree days.
#'
#' Deviates from the original by scaling synthesis with
#' the state of the previous Gcc value (production capacity is dependent)
#' on available tissue/capacity in t-1
#'
#' @param par three parameters specifying the cycling model
#' @param data data consisting of vegetation greenness (G), mean
#'  daytime temperature (T) and daylenght (D) as a data frame
#'
#' @return Vegetation greenness values
#' @export

chlorophyll_cycling_scaled <- function(par, data) {

  # split out model parameters
  b0 <- par[1]
  b1 <- par[2]
  b2 <- par[3]
  b3 <- par[4]
  b4 <- par[5]
  b5 <- par[6]

  # set anything after the start period
  # to NA
  data$gcc[2:nrow(data$gcc),] <- NA

  # loop over columns and rows
  for(j in seq(1,ncol(data$gcc))) {
    for (t in seq(1,nrow(data$gcc))[-1]) {

      # spring
      synthesis <- max(b0 + b1 * triangular_temperature_response(data$temp[t,j], T_min = b3, T_opt = b4, T_max = b5) * data$daylength[t,j] * data$gcc[t-1,j], 0)
      previous_pool <- data$gcc[t-1,j]
      breakdown <- b2 * data$gcc[t-1,j]

      # update state of the model
      data$gcc[t,j] <- max(min(previous_pool + synthesis - breakdown, 1), 0)
    }
  }

  # return data
  return(data$gcc)
}
