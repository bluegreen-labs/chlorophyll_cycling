
#' Converts a long data frame to a listed model data structure
#'
#' Conversion of a long format data frame of environmental driver data
#' and PhenoCam reference data to a wide format where every list item
#' contains a large matrix of each value, with columns the site years and
#' rows day-of-year.
#'
#' This allows for vectorization of the certain operations to speed up
#' model parameterization.
#'
#' @param df a data frame or tibble
#'
#' @return wide format matrix per environmental variable split with columns
#'  named after site and year, and rows as day-of-year
#' @export

df_to_list <- function(df){

  gcc <- df |>
    select(site, year, gcc, doy) |>
    pivot_wider(
      values_from = gcc,
      names_from = c("site","year")
    ) |>
    select(-doy)

  temp <- df |>
    select(site, year, temp, doy) |>
    pivot_wider(
      values_from = temp,
      names_from = c("site","year")
    ) |>
    select(-doy)

  daylength <- df |>
    select(site, year, daylength, doy) |>
    pivot_wider(
      values_from = daylength,
      names_from = c("site","year")
    ) |>
    select(-doy)

  df <- list(
    site = names(gcc),
    gcc = as.matrix(gcc),
    temp = as.matrix(temp),
    daylength = as.matrix(daylength)
  )
}
