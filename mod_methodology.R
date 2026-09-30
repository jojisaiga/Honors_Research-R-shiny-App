# mod_methodology.R — static content, no shared state

mod_methodology_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Methodology & Theory"),
    tabsetPanel(
      tabPanel("Global measures",
        p("TODO: Moran's I, Geary's C, Getis-Ord — definitions, formulas,",
          "interpretation, spatial weights matrix choice (contiguity vs",
          "distance vs k-NN).")
      ),
      tabPanel("Local measures & hot/cold spots",
        p("TODO: LISA (local Moran's I, local Geary's C), Getis-Ord Gi*",
          "hot/cold spots, distinguishing clusters/outliers from hot/cold",
          "spots, significance via permutation testing.")
      ),
      tabPanel("Spatial misalignment & Berkson error",
        p("TODO: why wastewater (catchment-level) and case data",
          "(sub-place-level) don't align, and how the Berkson error model",
          "corrects for it (IDW / EDW / DPD distance weighting).")
      ),
      tabPanel("MAUP",
        p("TODO: modifiable areal unit problem — why the choice of",
          "sub-place vs EA as spatial unit can change results.")
      )
    )
  )
}

mod_methodology_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # static tab — nothing reactive yet
  })
}
