# mod_conclusion.R — static content, no shared state

mod_conclusion_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Conclusion & Discussion"),
    h3("Findings"),
    p("TODO: wastewater N1 gene is a strong predictor of clinical cases;",
      "spatial and temporal effects both significant; model enables earlier,",
      "spatially-targeted response than clinical case data alone."),
    h3("Limitations"),
    tags$ul(
      tags$li("Only 8 of 19 WWTPs sampled — incomplete spatial coverage"),
      tags$li("Case data disaggregated from district to sub-place level (approximation error)"),
      tags$li("MAUP — results may shift with a different spatial unit than sub-place"),
      tags$li("Spatial misalignment between catchment-level wastewater data and sub-place-level cases"),
      tags$li("Only N1 gene used as covariate in the original model"),
      tags$li("ERA5-Land (~9km) is coarser than sub-place polygons — a further MAUP-like caveat for the weather layer")
    ),
    h3("Implications"),
    p("TODO: resource targeting ahead of clinical case confirmation;",
      "relevance for South African / LMIC wastewater surveillance context."),
    h3("Future work"),
    p("TODO: additional time-varying covariates (rainfall, mobility);",
      "refitting with weather as a covariate; finer/coarser spatial units.")
  )
}

mod_conclusion_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # static tab
  })
}
