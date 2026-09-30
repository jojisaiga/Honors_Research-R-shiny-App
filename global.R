# global.R ---------------------------------------------------------------
# Loaded once at app startup. Real data loading/joining (per SPEC.md s4)
# will replace the placeholder stat values below once files are supplied.

library(shiny)
library(bslib)

# ---- Theme tokens (locked from swatch review) ---------------------------
THEME <- bs_theme(
  version     = 5,
  bg          = "#F7F9F8",
  fg          = "#22312D",
  primary     = "#227D74",   # teal — wastewater / water
  secondary   = "#F0805C",   # coral — case / signal data
  base_font   = font_google("Work Sans"),
  heading_font = font_google("Fraunces", wght = c(400, 500, 600)),
  "border-radius" = "0.75rem"
)

COL <- list(
  paper      = "#F7F9F8",
  paper_alt  = "#EEF3F1",
  ink        = "#22312D",
  ink_soft   = "#5B6864",
  teal       = "#227D74",
  teal_deep  = "#164F49",
  coral      = "#F0805C",
  coral_deep = "#D65F3B",
  sand       = "#EFE7DA",
  line       = "#DCE3DF"
)

# ---- Paper facts (used in Home stat boxes) -------------------------------
# Sourced from Torres et al., Spatial Statistics 74 (2026) 101012, Sec. 2.
# NOTE: paper states 27 hospital facilities (Sec 2.5), not 29 — using the
# paper's figure here.
PAPER_FACTS <- list(
  wwtps_sampled   = 8,
  wwtps_total     = 19,
  hospitals       = 27,
  sub_places      = 470,
  study_weeks     = 28,
  observations    = 470 * 28,   # 13,160, per Sec 3.1.1
  study_period    = "21 Sep 2021 \u2013 29 Mar 2022"
)

# ---- Shared reactive state (created once, passed into modules) ----------
# selected_state <- reactiveValues(sub_place = NULL, week = 1)
# (instantiated in app.R server, per SPEC.md s2)

# TODO once data supplied:
#   sp_geometry  <- readRDS("data/sp_geometry.rds")
#   wwtp_locs    <- readRDS("data/wwtp_locations.rds")
#   catchments   <- readRDS("data/catchments.rds")
#   hospitals    <- readRDS("data/hospitals.rds")
#   era5_weekly  <- readRDS("data/era5_weekly.rds")
