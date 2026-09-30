# mod_about.R — static content, no shared state

mod_about_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h2("About this study"),
    p("Background on wastewater-based surveillance in Ekurhuleni, the",
      "administrative hierarchy, and the data sources behind this dashboard."),

    h3("Study area"),
    fluidRow(
      column(6, leafletOutput(ns("map_locator"), height = 350)),
      column(6, p("TODO: text on why Ekurhuleni — well-connected metro,",
                   "formal/informal housing, industrial + agricultural mix,",
                   "serviced by 19 WWTPs run by ERWAT, 8 sampled here."))
    ),

    h3("Wastewater treatment plants & catchment areas"),
    fluidRow(
      column(6, leafletOutput(ns("map_wwtp"), height = 350)),
      column(6, p("TODO: text on WWTP sampling, catchment allocation",
                   "methodology (sub-place boundaries + quaternary water",
                   "catchments + DEM + ERWAT operations data)."))
    ),

    h3("Hospitals & service areas"),
    fluidRow(
      column(6, leafletOutput(ns("map_hospitals"), height = 350)),
      column(6, p("TODO: text on 27 hospital facilities, drive-time",
                   "catchment rings (5/10/15-min), DATCOV data source."))
    ),

    h3("Data sources"),
    tags$ul(
      tags$li("Wastewater: SACCESS network, RT-PCR N1/N2 gene targets"),
      tags$li("Case data: South African COVID-19 GitHub repository (district level, disaggregated)"),
      tags$li("Hospitalisation: Gauteng DATCOV system"),
      tags$li("Population: Stats SA 2021 mid-year estimates, dasymetric disaggregation"),
      tags$li("Boundaries: Stats SA sub-places; DWA quaternary water catchments; USGS 90m DEM"),
      tags$li("Weather: ERA5-Land reanalysis, ~9km resolution")
    )
  )
}

mod_about_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Placeholder maps — replace with real sf polygons (addPolygons) once
    # sp_geometry / wwtp_locations / hospitals data is wired in.
    output$map_locator <- renderLeaflet({
      leaflet() %>% addTiles() %>% setView(lng = 28.2, lat = -26.17, zoom = 9)
    })
    output$map_wwtp <- renderLeaflet({
      leaflet() %>% addTiles() %>% setView(lng = 28.2, lat = -26.17, zoom = 10)
    })
    output$map_hospitals <- renderLeaflet({
      leaflet() %>% addTiles() %>% setView(lng = 28.2, lat = -26.17, zoom = 10)
    })
  })
}
