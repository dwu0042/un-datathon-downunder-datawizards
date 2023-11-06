box::use(
  shiny[
    moduleServer,
    NS,
    uiOutput,
    renderUI,
    req,
    tags,
    includeMarkdown,
    reactiveVal,
    observeEvent,
    sliderInput
  ],
  reactable[renderReactable, reactableOutput],
  shiny.semantic[segment, header, multiple_radio],
  here[here],
  reactable[reactable]
)

#' @export 
ui <- function(id) {
  ns <- NS(id)
  header(
    title = uiOutput(ns("header")),
    description = uiOutput(ns("content")),
  )
}

#' @export 
server <- function(id, state) {
  moduleServer(id, function(input, output, session) {

    ns <- session$ns
    
    power_ratio_input <- reactiveVal(NULL)

    output$content <- renderUI({
      if(state$selected_side == "pred") {
       content <- segment( 
        includeMarkdown(here("content/prediction_info.md")),
        segment(
          tags$span("Filter by Power Ratio"),
          sliderInput(ns("power_ratio_slider"),
            label = "",
            value = c(40,85),
            min = 40, max = 85,
            step = 1
          ),
          class = "inverted"
        ),
        class = "inverted"
      )
      } else if (state$selected_side == "solar"){
        content <- segment(
          includeMarkdown(here("content/solar_info.md")),
          segment(reactableOutput(ns("selected_solar_panel")), class = "raised"),
          segment(
            multiple_radio(ns("group_select"),
              "Select Map", 
              c("Biomass", "Slope", "Potential", "None"), 
              selected = "Biomass", 
              class = "inverted"
            ),
            class = "inverted"
          ),
          class = "inverted"
        )
      }
      segment(
        content,
       class = "inverted")
    })

    output$header <- renderUI({
      req(!is.null(state$selected_side))
      if(state$selected_side == "pred") {
        header <- "Prediction"
      } else if(state$selected_side == "solar") {
        header <- "Solar Success"
      }
      tags$span(header, class = "color-lightorange")
    })

    observeEvent(input$power_ratio_slider, {
      state$power_ratio_input <- input$power_ratio_slider
    })

    observeEvent(input$group_select, {
      state$group_select <- input$group_select
    })

    output$selected_solar_panel <- renderReactable({
      req(state$selected_side == "solar", !is.null(state$map_click))
      print(state$map_click$id)
      solar_table_data <- readRDS(here("data_rds", "solar_table_data.rds")) |> tidyr::drop_na()
      print(solar_table_data[state$map_click$id, ])
      solar_table_data[state$map_click$id, ] |>
        dplyr::mutate(dplyr::across(dplyr::everything(), as.character )) |> 
        tidyr::pivot_longer(cols = dplyr::everything()) |>
        reactable()
    })

  })
}