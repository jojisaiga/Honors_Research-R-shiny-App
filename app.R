# app.R ----------------------------------------------------------------
# Top-level UI (navbar) + server wiring. See SPEC.md for full architecture.
# Only Home is built out below; other tabs are placeholders until their
# modules are ready, so this file runs standalone for review.

source("global.R")
source("mod_home.R")
# source("R/mod_about.R")
# source("R/mod_methodology.R")
# source("R/mod_application.R")
# source("R/mod_weather.R")
# source("R/mod_conclusion.R")

ui <- page_navbar(
  title = "Under the weather",
  theme = THEME,
  id = "tabs",
  nav_panel("Home", mod_home_ui("home")),
  nav_panel("About", div(style = "padding:40px;", em("About tab \u2014 pending"))),
  nav_panel("Methodology", div(style = "padding:40px;", em("Methodology tab \u2014 pending"))),
  nav_panel("Application", div(style = "padding:40px;", em("Application tab \u2014 pending"))),
  nav_panel("Weather", div(style = "padding:40px;", em("Weather tab \u2014 pending"))),
  nav_panel("Conclusion", div(style = "padding:40px;", em("Conclusion tab \u2014 pending")))
)

server <- function(input, output, session) {

  # Shared reactive state (SPEC.md s2) — instantiated once, passed to
  # Application & Weather modules once they're built.
  selected_state <- reactiveValues(sub_place = NULL, week = 1)

  mod_home_server("home", switch_tab = function(tab) {
    updateNavbarPage(session, "tabs", selected = tab)
  })
}

shinyApp(ui, server)
