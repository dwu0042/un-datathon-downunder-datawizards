box::use(
  shiny[
    moduleServer,
    NS,
    tags,
    actionButton,
    icon,
    reactiveValues,
    observeEvent,
    req
  ],
  semantic.dashboard[
    dashboardBody,
    dashboardSidebar,
    dashboardHeader,
    dashboardPage,
    sidebarMenu
  ],
  shiny.semantic[button, range_input, segment]
)

box::use(
  app/view/map_module,
  app/view/info_card_module
)

#' @export
ui <- function(id, state) {
  ns <- NS(id)
  dashboardPage(
    dashboardHeader(
      center = tags$h1("From darkness to",tags$span("solar brilliance", class = "color-lightorange")),
      title = NULL,
      inverted = TRUE,
      menu_button_label = ""
    ),
    dashboardSidebar(
      side = "left", size = "very wide", inverted = TRUE,
      sidebarMenu(
        info_card_module$ui(ns("info")),
        button(ns("flip"), label = "Switch view", icon = icon("refresh"), class = "huge inverted orange")
      )
    ),
    dashboardBody(
      map_module$ui(ns("map"))
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    state <- reactiveValues(
      selected_side = "pred",
      power_ratio_input = NULL,
      map_click = NULL,
      group_select = NULL
    )

    observeEvent(input$flip, {
      state$selected_side <- ifelse(state$selected_side == "pred", "solar", "pred")
    })

    map_module$server("map", state)
    info_card_module$server("info", state)

  })
}
