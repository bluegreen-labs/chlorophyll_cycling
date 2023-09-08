# list all MCD43A4 files, note that
# that list.files() uses regular
# expressions when using wildcards
# such as *, you can convert general
# wildcard use to regular expressions
# with glob2rx()
files <- list.files(
  "data-raw/MODIS/",
  glob2rx("*MCD43A4-061-results*"),
  recursive = TRUE,
  full.names = TRUE
)

# read in the data (very fast)
# with {vroom} and set all
# fill values (>=32767) to NA
nbar <- vroom::vroom(files) |>
  select(
    Category,
    Date,
    starts_with("MCD43A4_061_Nadir")
  ) |>
  rename(
    site = Category,
    date = Date
  )

# does not work for long file names
# as they code to a number too large
# where(is.double()) should be used
# to screen values
nbar <- nbar |>
  mutate(
    across(
      where(is.double),
      ~replace(., . >= 32767 , NA)
      )
    ) |>
  mutate(
    ndvi = (MCD43A4_061_Nadir_Reflectance_Band2 - MCD43A4_061_Nadir_Reflectance_Band1)/
      (MCD43A4_061_Nadir_Reflectance_Band2 + MCD43A4_061_Nadir_Reflectance_Band1)
  ) |>
  select(
    -contains("band")
  )

# save as compressed serialized
# data
saveRDS(
  nbar,
  "data/modis_data.rds",
  compress = "xz"
)
