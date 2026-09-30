# mod_weather.R — reads/writes the SAME shared_state as Application
# (sub_place / week selection carries across both tabs)

mod_weather_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Weather (ERA5-Land)"),
    p("Precipitation and temperature context for the wastewater signal.",
      "Note: ERA5-Land is ~9km resolution — coarser than most sub-places,",
      "so values are aggregated at WWTP catchment level (see Methodology / MAUP)."),

    radioButtons(ns("wx_var"), "Variable:",
                 choices = c("Precipitation (mm)" = "precip_mm",
                             "Max temperature (C)" = "tmax_c",
                             "Min temperature (C)" = "tmin_c"),
                 selected = "precip_mm", inline = TRUE),

    fluidRow(
      column(6, plotlyOutput(ns("weather_ts"), height = 300)),
      column(6, plotlyOutput(ns("overlay_ts"), height = 300))
    ),

    h3("Lag exploration"),
    sliderInput(ns("lag_weeks"), "Lag (weeks):", min = 0, max = 4, value = 0, step = 1),
    plotlyOutput(ns("lag_plot"), height = 300),
    p(em("Cross-correlation between rainfall and N1 signal — exploring the",
         "dilution-effect hypothesis (heavy rain diluting viral concentration",
         "independent of actual case burden)."))
  )
}

mod_weather_server <- function(id, selected_state) {
  moduleServer(id, function(input, output, session) {

    wwtp_id <- reactive({
      req(selected_state$sub_place)
      unique(sp_data$wwtp[sp_data$SP_CODE == selected_state$sub_place])
    })

    wx_series <- reactive({
      if (is.null(selected_state$sub_place)) {
        weather_weekly %>% group_by(Date) %>%
          summarise(across(c(precip_mm, tmax_c, tmin_c), mean), .groups = "drop")
      } else {
        weather_weekly %>% filter(wwtp == wwtp_id())
      }
    })

    output$weather_ts <- renderPlotly({
      df <- wx_series()
      p <- ggplot(df, aes(Date, .data[[input$wx_var]])) +
        geom_line(colour = "darkorange") +
        geom_vline(xintercept = as.numeric(selected_state$week), linetype = "dashed") +
        labs(y = input$wx_var, x = NULL,
             title = if (is.null(selected_state$sub_place)) "Catchment average"
                     else paste("Catchment for", selected_state$sub_place)) +
        theme_minimal()
      ggplotly(p)
    })

    output$overlay_ts <- renderPlotly({
      req(selected_state$sub_place)
      n1_col <- paste0("N1_", wwtp_id())
      df <- sp_data %>% filter(SP_CODE == selected_state$sub_place) %>%
        select(Date, N1 = all_of(n1_col)) %>%
        left_join(wx_series(), by = "Date")
      p <- ggplot(df, aes(Date)) +
        geom_line(aes(y = scale(N1)), colour = "steelblue") +
        geom_line(aes(y = scale(.data[[input$wx_var]])), colour = "darkorange") +
        labs(y = "standardised value", x = NULL,
             title = "N1 (blue) vs weather (orange), standardised") +
        theme_minimal()
      ggplotly(p)
    })

    output$lag_plot <- renderPlotly({
      req(selected_state$sub_place)
      n1_col <- paste0("N1_", wwtp_id())
      df <- sp_data %>% filter(SP_CODE == selected_state$sub_place) %>%
        select(Date, N1 = all_of(n1_col)) %>%
        left_join(wx_series(), by = "Date") %>%
        arrange(Date) %>%
        mutate(wx_lagged = lag(.data[[input$wx_var]], input$lag_weeks))
      p <- ggplot(df, aes(wx_lagged, N1)) +
        geom_point(alpha = 0.6) +
        geom_smooth(method = "lm", se = FALSE, colour = "darkorange") +
        labs(x = paste(input$wx_var, "lagged", input$lag_weeks, "wk(s)"), y = "N1 signal") +
        theme_minimal()
      ggplotly(p)
    })
  })
}
