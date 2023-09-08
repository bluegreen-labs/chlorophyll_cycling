# load libraries and functions
library(dplyr)
library(tidyr)
library(ggplot2)
library(patchwork)
library(BayesianTools)
source("R/likelihood.R")
source("R/chlorophyll_cycling.R")
source("R/df_to_list.R")
source("R/normalize_ts.R")

# load raw (bulk data)
# and filter for a single site
# and a DOY range
# further subsets can be generated
# upon custom filters
raw_data <- readRDS("data/phenocam_data.rds") |>
  filter(
    site == "harvard"
    )|>
  group_by(year) |>
  mutate(
    gcc = normalize_ts(gcc, c(0.1,1)),
  ) |>
  filter(
    doy > 213
  )

# reformat to the required list based
# model input format
df <- raw_data |>
  df_to_list()

# Bayesian optimization routine
control = list(
  sampler = 'DEzs',
  settings = list(
    burnin = 1000,
    iterations = 40000
  )
)

# set parameter ranges
# b1 - b3
lower <- c(-1, 0, 0)
upper <- c(1, 1, 1)

# setup of the BT setup
setup <- BayesianTools::createBayesianSetup(
  likelihood = function(random_par){
    do.call("likelihood",
            list(par = random_par,
                 data = df,
                 model = "chlorophyll_cycling"
            ))},
  # include an additional parameter
  # range for data uncertainty
  lower = c(lower, 0),
  upper = c(upper, 1)
)

# calculate the optimization
# run and return results
out <- BayesianTools::runMCMC(
  bayesianSetup = setup,
  sampler = control$sampler,
  settings = control$settings
  )

# save optimization output
saveRDS(
  out,
  "data/mcmc_output.rds",
  compress = "xz"
)
