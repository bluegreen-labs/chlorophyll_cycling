# Note: this script can be run
# as an RStudio job

# load libraries
library(appeears)
library(dplyr)

# create output directory
if(!dir.exists("data-raw/MODIS")){
  dir.create("data-raw/MODIS")
}

# read in site list split by
# site for easier formatting using
# lapply() below
sites <- readRDS("data/site_list.rds") |>
  group_split(
    site
  )

# for every row download the data for this
# location and the specified reflectance
# bands
task_nbar <- lapply(sites, function(x){

  # loop over all list items (phenocam sites)
  base_query <- x |>
    dplyr::rowwise() |>
    do({
      data.frame(
        task = paste0("nbar_",.$site),
        subtask = as.character(.$site),
        latitude = .$lat,
        longitude = .$lon,
        start = "2001-01-01",
        end = "2022-12-31",
        product = "MCD43A4.061",
        layer = paste0("Nadir_Reflectance_Band", 1:3)
      )
    }) |>
    dplyr::ungroup()

  # build a task JSON string
  task <- rs_build_task(
    df = base_query
  )

  # return task
  return(task)
})

# Query the appeears API and process
# data in batches - this function
# requires an active API session/login
rs_request_batch(
  request = task_nbar,
  workers = 10,
  user = "khufkens",
  path = "./data-raw/MODIS",
  verbose = TRUE,
  time_out = 28800
)
