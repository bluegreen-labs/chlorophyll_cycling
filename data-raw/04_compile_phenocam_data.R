# list all MCD43A4 files, note that
# that list.files() uses regular
# expressions when using wildcards
# such as *, you can convert general
# wildcard use to regular expressions
# with glob2rx()
library(dplyr)

files <- list.files(
  "data-raw/phenocam/",
  "*.csv",
  recursive = TRUE,
  full.names = TRUE
)

df <- lapply(files,
    function(file){
     df <- read.table(
       file,
       skip = 24,
       header = TRUE,
       sep = ","
     )

     df$site <- basename(gsub('_DB_1000_1day.csv',"", file))
     return(df)
    })

df <- bind_rows(df) |>
  as_tibble() |>
  mutate(
    gcc = gcc_90,
    temp = (tmax..deg.c. + tmin..deg.c.)/2,
    daylength = dayl..s. / 3600,
    date = as.Date(date)
  )

# only retain full years (n >= 365)
df <- df |>
  group_by(site, year) |>
  mutate(
    n = n()
  ) |>
  filter(
    n >= 365
  ) |>
  select(
    -n
  )

df <- df |>
  select(
    site,
    year,
    doy,
    date,
    gcc,
    temp,
    daylength
  )

# join with modis data
modis <- readRDS("data/modis_data.rds")
df <- left_join(df, modis)

# save as compressed serialized
# data
saveRDS(
  df,
  "data/phenocam_data.rds",
  compress = "xz"
)
