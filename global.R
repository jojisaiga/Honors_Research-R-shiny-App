# global.R
# Loads & prepares all data ONCE at app startup. Modules only filter/subset.
#
# SCAFFOLD NOTE: real data files (sf geometry, ERA5, catchments) aren't
# wired in yet, so this file SIMULATES a dataset with the same shape as
# what was described (SP_CODE, Date, Cases, Prediction, N1_1..N1_8, weather)
# so the app runs end-to-end. Swap the block marked "REPLACE WITH REAL DATA"
# for real loading code (e.g. readRDS("data/sp_geometry.rds")) later.

library(shiny)
library(leaflet)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(DT)
library(sf)

set.seed(42)

# ---- REPLACE WITH REAL DATA -------------------------------------------
# Real version:
#   sp_data <- readRDS("data/sp_geometry.rds")   # sf object, has SP_CODE, Date,
#                                                 # Cases, Prediction, N1_cusum,
#                                                 # N1_1..N1_8, u, v, time, time2
#   catchment_lookup <- readRDS("data/catchment_lookup.rds") # SP_CODE -> wwtp id (1-8)
#   era5_weekly <- readRDS("data/era5_weekly.rds")           # catchment, Date, precip, tmax, tmin

n_sp   <- 25                                   # number of dummy sub-places
n_week <- 30                                   # number of dummy weeks
sp_codes <- sprintf("SP%03d", seq_len(n_sp))
weeks <- seq(as.Date("2021-09-21"), by = "week", length.out = n_week)
wwtp_for_sp <- setNames(sample(1:8, n_sp, replace = TRUE), sp_codes)

# fake point "centroids" scattered around Ekurhuleni's approximate bbox,
# used as circleMarkers in this scaffold in place of real sf polygons
sp_coords <- data.frame(
  SP_CODE = sp_codes,
  lon = runif(n_sp, 28.05, 28.35),
  lat = runif(n_sp, -26.30, -26.05)
)

sim_grid <- expand.grid(SP_CODE = sp_codes, Date = weeks, stringsAsFactors = FALSE)

sp_data <- sim_grid %>%
  group_by(SP_CODE) %>%
  arrange(Date) %>%
  mutate(
    week_idx  = row_number(),
    wwtp      = wwtp_for_sp[SP_CODE],
    base      = 20 + 15 * sin(week_idx / 5),
    Cases     = pmax(0, round(base + rnorm(n(), 0, 8))),
    Prediction = pmax(0, round(base + rnorm(n(), 0, 4))),
    N1_cusum  = cumsum(pmax(0, rnorm(n(), 5, 2)))
  ) %>%
  ungroup()

# N1_1..N1_8: only the serving WWTP gets a "real" signal, others ~0
for (i in 1:8) {
  colname <- paste0("N1_", i)
  sp_data[[colname]] <- ifelse(
    sp_data$wwtp == i,
    pmax(0, sp_data$N1_cusum + rnorm(nrow(sp_data), 0, 1)),
    0
  )
}

sp_data <- sp_data %>% left_join(sp_coords, by = "SP_CODE")

# dummy weekly weather per WWTP catchment (1-8)
weather_weekly <- expand.grid(wwtp = 1:8, Date = weeks) %>%
  mutate(
    precip_mm = pmax(0, rgamma(n(), shape = 2, scale = 8)),
    tmax_c    = 22 + 6 * sin(as.numeric(Date - min(Date)) / 20) + rnorm(n(), 0, 1.5),
    tmin_c    = tmax_c - runif(n(), 6, 10)
  )

# model comparison table, static, from the paper (Table 1)
model_comparison <- tibble::tribble(
  ~Model,                ~DIC,   ~WAIC,  ~`Log-Sum CPO`, ~`Log PMCC`,
  "Only RW1",            26146,  26149,  8.59,           18.54,
  "Only BYM",            18761,  18767,  8.91,           19.02,
  "BYM and RW1",         -2520,  -2509,  9.76,           15.82,
  "BYM and AR1",         -2521,  -2510,  9.75,           15.82,
  "BYM and RW1 with BE", -4648,  -4688,  9.76,           14.69
)
# --------------------------------------------------------------------

default_week <- min(sp_data$Date)
all_weeks    <- sort(unique(sp_data$Date))
all_sp_codes <- sort(unique(sp_data$SP_CODE))
