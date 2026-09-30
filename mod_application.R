# mod_application.R — core interactive tab
# Reads AND writes `selected_state` (passed in from app.R): map click sets
# selected_state$sub_place; the global week slider (also in app.R) sets
# selected_state$week and is read here.

mod_application_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Application: Miguel's model"),
    p("Bayesian spatio-temporal model (BYM + RW1 + Berkson error correction).",
      "Predicted vs actual COVID-19 cases by sub-place, driven by the",
      "wastewater N1 gene signal."),

    fluidRow(
      column(4, radioButtons(ns("metric"), "Map colour:",
                              choices = c("Actual cases" = "Cases",
                                          "Predicted cases" = "Prediction",
                                          "Error (Actual - Predicted)" = "error"),
                              selected = "Cases"))
    ),

    fluidRow(
      column(7, leafletOutput(ns("map"), height = 420)),
      column(5,
        plotlyOutput(ns("timeseries"), height = 250),
        h4("N1 gene signal (serving WWTP)"),
        plotlyOutput(ns("n1_plot"), height = 170)
      )
    ),

    h3("Model comparison"),
    p("From the original paper (Table 1) — lower DIC/WAIC/PMCC and higher",
      "Log-Sum CPO indicate better fit. Best-performing: BYM and RW1 with BE."),
    DTOutput(ns("model_table")),

    # Placeholder for the optional decomposition view (u,v,time,time2) —
    # deferred, but the data is already in sp_data so this can be filled
    # in later without restructuring the tab.
    h3("Spatial & temporal trend decomposition"),
    p(em("Optional / not yet built — spatial trend (u+v) and temporal",
         "trend (time+time2) would go here, mirroring Fig. 12 in the paper."))
  )
}

mod_application_server <- function(id, selected_state) {
  moduleServer(id, function(input, output, session) {

    # data for the currently selected week (drives the map)
    week_data <- reactive({
      sp_data %>%
        filter(Date == selected_state$week) %>%
        mutate(error = Cases - Prediction)
    })

    # data for the currently selected sub-place, all weeks (drives time series)
    sp_series <- reactive({
      if (is.null(selected_state$sub_place)) {
        sp_data %>% group_by(Date) %>%
          summarise(Cases = mean(Cases), Prediction = mean(Prediction), .groups = "drop")
      } else {
        sp_data %>% filter(SP_CODE == selected_state$sub_place) %>%
          select(Date, Cases, Prediction)
      }
    })

    output$map <- renderLeaflet({
      df <- week_data()
      pal <- colorNumeric("YlOrRd", domain = df[[input$metric]])
      leaflet(df) %>%
        addTiles() %>%
        addCircleMarkers(
          lng = ~lon, lat = ~lat, layerId = ~SP_CODE,
          radius = 8, stroke = FALSE, fillOpacity = 0.85,
          color = ~pal(get(input$metric)),
          label = ~paste0(SP_CODE, ": ", round(get(input$metric), 1))
        ) %>%
        addLegend("bottomright", pal = pal, values = ~get(input$metric),
                   title = input$metric)
      # NOTE: real version should use addPolygons() on sf sub-place geometry
      # instead of addCircleMarkers() on dummy centroids.
    })

    observeEvent(input$map_marker_click, {
      selected_state$sub_place <- input$map_marker_click$id
    })

    output$timeseries <- renderPlotly({
      df <- sp_series() %>%
        pivot_longer(c(Cases, Prediction), names_to = "type", values_to = "value")
      p <- ggplot(df, aes(Date, value, colour = type)) +
        geom_line() +
        geom_vline(xintercept = as.numeric(selected_state$week), linetype = "dashed") +
        labs(y = NULL, x = NULL, colour = NULL,
             title = if (is.null(selected_state$sub_place)) "District average"
                     else paste("Sub-place:", selected_state$sub_place)) +
        theme_minimal()
      ggplotly(p)
    })

    output$n1_plot <- renderPlotly({
      req(selected_state$sub_place)
      df <- sp_data %>% filter(SP_CODE == selected_state$sub_place)
      wwtp_id <- unique(df$wwtp)
      col <- paste0("N1_", wwtp_id)
      p <- ggplot(df, aes(Date, .data[[col]])) +
        geom_line(colour = "steelblue") +
        labs(y = paste("N1 (WWTP", wwtp_id, ")"), x = NULL) +
        theme_minimal()
      ggplotly(p)
    })

    output$model_table <- renderDT({
      datatable(model_comparison, options = list(dom = "t", paging = FALSE),
                rownames = FALSE)
    })
  })
}
