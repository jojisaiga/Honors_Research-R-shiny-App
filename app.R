# app.R — top-level UI + server wiring
# Global control bar (week slider + sub-place selector) is shown only on
# the Application / Weather tabs, and writes into a shared reactiveValues
# object passed into both modules.

source("global.R")

# Explicit (not looped) so a problem in one file gives a clear error
# pointing at that exact file, instead of silently skipping the rest.
source("C:/Users/Esther Mazarura/Downloads/RShiny - Claude construct/mod_about.R")
source("C:/Users/Esther Mazarura/Downloads/RShiny - Claude construct/mod_methodology.R")
source("C:/Users/Esther Mazarura/Downloads/RShiny - Claude construct/mod_application.R")
source("C:/Users/Esther Mazarura/Downloads/RShiny - Claude construct/mod_weather.R")
source("C:/Users/Esther Mazarura/Downloads/RShiny - Claude construct/mod_conclusion.R")

ui <- fluidPage(
  titlePanel("Ekurhuleni Wastewater-Based COVID-19 Surveillance"),

  # Global control bar — only relevant for Application / Weather
  conditionalPanel(
    condition = "input.tabs == 'Application' || input.tabs == 'Weather'",
    wellPanel(
      fluidRow(
        column(8,
          sliderInput("global_week", "Week:",
                      min = min(all_weeks), max = max(all_weeks),
                      value = default_week, step = 7, timeFormat = "%Y-%m-%d",
                      width = "100%")
        ),
        column(4,
          selectInput("global_sp", "Sub-place (optional):",
                      choices = c("(district average)" = "", all_sp_codes),
                      width = "100%")
        )
      )
    )
  ),

  tabsetPanel(id = "tabs",
    tabPanel("Home", h2("Ekurhuleni Wastewater Surveillance Dashboard"),
             p("TODO: one-line research question, short summary, nav guidance.")),
    tabPanel("About", mod_about_ui("about")),
    tabPanel("Methodology", mod_methodology_ui("methodology")),
    tabPanel("Application", mod_application_ui("application")),
    tabPanel("Weather", mod_weather_ui("weather")),
    tabPanel("Conclusion", mod_conclusion_ui("conclusion"))
  )
)

server <- function(input, output, session) {

  # shared state across Application & Weather
  selected_state <- reactiveValues(sub_place = NULL, week = default_week)

  # global controls -> shared state
  observeEvent(input$global_week, {
    selected_state$week <- input$global_week
  })
  observeEvent(input$global_sp, {
    selected_state$sub_place <- if (input$global_sp == "") NULL else input$global_sp
  })

  # if a module sets sub_place via map click, reflect it back into the
  # global selector so the UI stays in sync
  observeEvent(selected_state$sub_place, {
    updateSelectInput(session, "global_sp",
                       selected = if (is.null(selected_state$sub_place)) "" else selected_state$sub_place)
  }, ignoreInit = TRUE)

  mod_about_server("about")
  mod_methodology_server("methodology")
  mod_application_server("application", selected_state)
  mod_weather_server("weather", selected_state)
  mod_conclusion_server("conclusion")
}

shinyApp(ui, server)
