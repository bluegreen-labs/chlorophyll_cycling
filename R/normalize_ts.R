#' Normalize PhenoCam time series
#'
#' Normalize PhenoCam data between 0-1 to to standardize
#' further processing using quantile probability values
#' implicitly addressing outliers
#'
#' @param df a PhenoCam Gcc time series
#' @param prob probability values (0-1) as vector to denote min
#'  and max values in normalizing
#' @return A normalized PhenoCam time series.
#' @export

normalize_ts <- function(df, prob = c(0.1, 0.9)){
  val <- quantile(df, prob, na.rm = TRUE)
  df  <- (df - val[1]) / diff(val)
  return(df)
}
