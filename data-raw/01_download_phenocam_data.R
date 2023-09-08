# Note: this script can be run
# as an RStudio job

# load libraries
library(phenocamr)
library(dplyr)

# create output directory
if(!dir.exists("data-raw/phenocam")){
  dir.create("data-raw/phenocam")
}

# download all relevant PhenoCam data
lapply(sites$site, function(site) {
  try(phenocamr::download_phenocam(
    site = paste0(site,"$"),
    veg_type = "DB",
    frequency = "1",
    roi_id = "1000",
    out_dir = "data-raw/phenocam/",
    contract = FALSE,
    daymet = TRUE # complement sites with DAYMET climate data
  ))
})
