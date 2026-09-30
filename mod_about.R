# R/mod_home.R -------------------------------------------------------------
# Home tab. Static landing page: title, research question, nav cards with
# sparkline teasers, paper-fact stat boxes, proof-of-concept disclaimer.
# No shared-state dependency, no server logic beyond the module boilerplate.

mod_home_ui <- function(id) {
  ns <- NS(id)

  tagList(
    tags$head(
      tags$style(HTML(sprintf("
        .home-hero { padding: 56px 8px 40px; }
        .home-hero h1 {
          font-family: 'Fraunces', serif; font-weight: 500;
          font-size: clamp(30px, 5vw, 46px);
          color: %s; letter-spacing: -0.01em; margin-bottom: 8px;
        }
        .home-hero .subhead {
          font-size: 16px; color: %s; max-width: 62ch; margin-bottom: 24px;
        }
        .home-hero .rq {
          font-size: 17px; line-height: 1.6; max-width: 68ch; color: %s;
        }
        .nav-card {
          background: #fff; border: 1px solid %s; border-radius: 12px;
          padding: 20px; height: 100%%; transition: box-shadow .15s ease;
        }
        .nav-card:hover { box-shadow: 0 4px 16px rgba(34,49,45,0.08); }
        .nav-card h3 {
          font-family: 'Fraunces', serif; font-size: 19px; font-weight: 500;
          margin-bottom: 6px;
        }
        .nav-card p { font-size: 13.5px; color: %s; line-height: 1.5; }
        .nav-card .spark { width: 100%%; height: 42px; display: block; margin-top: 10px; }
        .stat-box {
          background: %s; border-radius: 12px; padding: 18px 20px; text-align: left;
        }
        .stat-box .num {
          font-family: 'Fraunces', serif; font-weight: 500; font-size: 30px;
          color: %s;
        }
        .stat-box .lbl { font-size: 12.5px; color: %s; margin-top: 2px; }
        .poc-note {
          font-size: 12.5px; color: %s; border-top: 1px solid %s;
          padding-top: 14px; margin-top: 40px;
        }
      ",
      COL$teal_deep, COL$ink_soft, COL$ink, COL$line, COL$ink_soft,
      COL$paper_alt, COL$teal_deep, COL$ink_soft, COL$ink_soft, COL$line
      )))
    ),

    div(class = "home-hero",
      h1("Under the weather"),
      div(class = "subhead",
        "Modelling COVID-19 spread across Ekurhuleni, South Africa, from wastewater surveillance and rainfall data."
      ),
      p(class = "rq",
        "Sewage testing can reveal how many people are infected in a community ",
        "\u2014 before they're ever tested. This app explores whether that signal, ",
        "combined with rainfall patterns, can predict COVID-19 case numbers at ",
        "the neighbourhood level in Ekurhuleni \u2014 and confronts the statistical ",
        "challenge of combining data collected at mismatched spatial scales."
      )
    ),

    # ---- Nav cards --------------------------------------------------------
    fluidRow(
      column(4,
        div(class = "nav-card",
          h3("Explore the model"),
          p("Predicted vs. reported cases, week by week, across Ekurhuleni's sub-places."),
          tags$svg(class = "spark", viewBox = "0 0 300 60", preserveAspectRatio = "none",
            tags$polyline(points = "0,50 20,48 40,45 60,20 80,8 100,15 120,35 140,44 160,46 180,42 200,44 220,45 240,43 260,44 280,44 300,45",
                          fill = "none", stroke = COL$coral, `stroke-width` = "2.5",
                          `stroke-linecap` = "round", `stroke-linejoin` = "round"),
            tags$polyline(points = "0,52 20,50 40,47 60,25 80,12 100,20 120,38 140,46 160,48 180,45 200,46 220,47 240,46 260,47 280,47 300,48",
                          fill = "none", stroke = COL$teal, `stroke-width` = "2",
                          `stroke-linecap` = "round", `stroke-linejoin` = "round", opacity = "0.75")
          ),
          actionLink(ns("go_application"), "View the Application tab \u2192", style = "font-size:13px;")
        )
      ),
      column(4,
        div(class = "nav-card",
          h3("Rainfall & wastewater"),
          p("ERA5-Land rainfall layered against the N1 gene signal \u2014 exploratory, not part of the fitted model."),
          tags$svg(class = "spark", viewBox = "0 0 300 60",
            lapply(seq(0, 11), function(i) {
              x <- 10 + i * 24
              h <- sample(seq(10, 44, 2), 1)
              tags$rect(x = x, y = 54 - h, width = 14, height = h, fill = COL$teal, opacity = "0.85")
            })
          ),
          actionLink(ns("go_weather"), "View the Weather tab \u2192", style = "font-size:13px;")
        )
      ),
      column(4,
        div(class = "nav-card",
          h3("How the statistics work"),
          p("Spatial autocorrelation, contiguity, and why \u201cnext to\u201d isn't as simple as it sounds. Try the interactive demo."),
          actionLink(ns("go_methodology"), "View the Methodology tab \u2192", style = "font-size:13px;")
        )
      )
    ),

    br(),

    # ---- Stat boxes: paper facts ------------------------------------------
    h4("The study, in numbers", style = paste0("font-family:'Fraunces',serif; font-weight:500; color:", COL$ink, "; margin: 28px 0 14px;")),
    fluidRow(
      column(3, div(class = "stat-box",
        div(class = "num", PAPER_FACTS$wwtps_sampled),
        div(class = "lbl", sprintf("wastewater treatment plants sampled (of %d serving Ekurhuleni)", PAPER_FACTS$wwtps_total))
      )),
      column(3, div(class = "stat-box",
        div(class = "num", PAPER_FACTS$hospitals),
        div(class = "lbl", "hospitals used to disaggregate district-level cases to sub-place level")
      )),
      column(3, div(class = "stat-box",
        div(class = "num", PAPER_FACTS$sub_places),
        div(class = "lbl", "sub-places \u2014 the small administrative areas the model predicts cases for")
      )),
      column(3, div(class = "stat-box",
        div(class = "num", PAPER_FACTS$study_weeks),
        div(class = "lbl", sprintf("weeks of overlapping case & wastewater data (%s)", PAPER_FACTS$study_period))
      ))
    ),

    div(class = "poc-note",
      "A research proof-of-concept, not an operational surveillance tool. ",
      "Case counts at sub-place level are themselves modelled estimates, disaggregated from district-level reporting \u2014 not directly observed figures."
    )
  )
}

mod_home_server <- function(id, switch_tab) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$go_application, switch_tab("Application"))
    observeEvent(input$go_weather,     switch_tab("Weather"))
    observeEvent(input$go_methodology, switch_tab("Methodology"))
  })
}
