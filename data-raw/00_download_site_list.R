# load libraries
library(phenocamr)
library(dplyr)

# sites for model training
sites <- c(
  "harvard",
  "umichbiological",
  "bostoncommon",
  "coweeta",
  "howland2",
  "morganmonroe",
  "missouriozarks",
  "queens",
  "dukehw",
  "lacclair",
  "bbc1",
  "NEON.D08.DELA.DP1.00033",
  "bartlettir",
  "oakridge1",
  "hubbardbrook",
  "alligatorriver",
  "readingma",
  "bullshoals",
  "willowcreek",
  "downerwoods",
  "laurentides",
  "russellsage",
  "sanford",
  "boundarywaters"
  )

# download site meta-data
site_list <- phenocamr::list_sites() |>
  as_tibble() |>
  filter(
    site %in% sites
  )

# save site meta-data
# as compressed R file
# bad formatting in the site list
# doesn't allow for easy CSV save
saveRDS(
  site_list,
  "data/site_list.rds",
  compress = "xz"
)
