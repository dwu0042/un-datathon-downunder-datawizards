box::use(
  shiny[NS, moduleServer, tags, reactive, req, observe, isolate, reactiveVal, observeEvent],
  leaflet[
    leaflet,
    renderLeaflet,
    leafletOutput,
    leafletProxy,
    addProviderTiles,
    providers,
    addCircles,
    addRectangles,
    addCircleMarkers,
    clearShapes,
    clearMarkers,
    clearMarkerClusters,
    clearControls,
    flyToBounds,
    setView,
    markerClusterOptions,
    providerTileOptions,
    addLayersControl,
    layersControlOptions,
    leafletOptions,
    setMaxBounds,
    addMeasure
  ],
  dplyr[rename, mutate, filter, group_by, summarise, ungroup, row_number],
  here[here],
  readr[read_csv]
)

box::use(
  app/logic/scale_fns[min_max_scale]
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  leafletOutput(ns("map"))
}

#' @export
server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    
    min_lng <- -20
    max_lng <- 50
    min_lat <- -40
    max_lat <- 40

    CIRCLE_RADIUS <- 20000

    # night_light_data <- readRDS(here("data_rds", "night_light_data.rds"))
    # pop_density_data <- readRDS(here("data_rds", "pop_density.rds"))

    demand_data <- readRDS(here("data_rds", "demand_data.rds"))

    prediction_data_raw <- readRDS(here("data_rds", "prediction_data.rds"))
    prediction_data <- reactiveVal(prediction_data_raw)
  
    solar_data <- readRDS(here("data_rds", "solar_table_data.rds"))
    slope_data <- readRDS(here("data_rds", "slope_data.rds"))
    pv_potential <- readRDS(here("data_rds", "pv_potential.rds"))
    biomass_data <- readRDS(here("data_rds", "biomass_data.rds"))

    DEMAND_GROUP_ID <- "Energy Accessibility Need"
    PRED_GROUP_ID <- "Predicted solar farms"

    BIOMASS_GROUP_ID <- "Biomass"
    PV_POTENTIAL_GROUP_ID <- "PV Potential"
    SLOPE_GROUP_ID <- "Slope Data"
    SOLAR_FARM_GROUP_ID <- "Existing solar farms"

    FREEZE_AT_ZOOM_LEVEL <- 8

    output$map <- renderLeaflet({
        leaflet(options = leafletOptions(preferCanvas = TRUE)) |>
        setView(lng = 8.6774567, lat = 9.077751, zoom = 5) |>
        addProviderTiles(
          providers$CartoDB.DarkMatterNoLabels, 
          providerTileOptions(minZoom = 5, maxZoom = 7),
          group = "Without labels"
        ) |>
        addProviderTiles(
          providers$CartoDB.DarkMatter,
          providerTileOptions(minZoom = 5, maxZoom = 7),
          group = "With labels"
        ) |>
        htmlwidgets::onRender("
          function(el, x) {
            var map = this;
            map.options.minZoom = 3;
            map.options.maxZoom = 6;
          }
        ") |>
        addMeasure(
          position = "bottomright",
          primaryLengthUnit = "kilometers",
          primaryAreaUnit = "sqkilometers",
          activeColor = "#3D535D",
          completedColor = "#7D4479"
        )
    })

    observe({
      req(
        !is.null(state$selected_side),
        !is.null(prediction_data())
      )
      
      if(state$selected_side == "pred") {
        leafletProxy("map") |>
          clearMarkers() |> clearMarkerClusters() |> clearShapes() |> clearControls() |>
          addCircleMarkers(
            data = demand_data,
            lat = ~lat,
            lng = ~lng,
            radius = 10,
            color = "white",
            label = ~radius,
            stroke = FALSE,
            fillOpacity = ~radius,
            clusterOptions = markerClusterOptions(freezeAtZoom = FREEZE_AT_ZOOM_LEVEL),
            group = DEMAND_GROUP_ID
          ) |> 
          addRectangles(
            data = prediction_data() |>
              dplyr::mutate(lng1 = lng - 0.5, lat1 = lat - 0.5, lng2 = lng + 0.5, lat2 = lat + 0.5),
            lat1 = ~lat1, lng1 = ~lng1,
            lat2 = ~lat2, lng2 = ~lng2,
            fillOpacity = ~radius,
            fillColor = "red",
            stroke = FALSE,
            group = PRED_GROUP_ID
          ) |>
          addLayersControl(
            baseGroups = c("With labels", "Without labels"),
            overlayGroups = c(DEMAND_GROUP_ID, PRED_GROUP_ID),
            options = layersControlOptions(collapsed = FALSE)
          )
      } else if(state$selected_side == "solar") {
        leafletProxy("map") |>
          clearMarkers() |> clearMarkerClusters() |> clearShapes() |> clearControls() |>
          addCircleMarkers(
            data = solar_data |>
              tidyr::drop_na() |>
              mutate(lid = row_number()) |>
              mutate(power_ratio = min_max_scale(power_ratio)),
            lat = ~latitude,
            lng = ~longitude,
            radius = 10,
            color = "orange",
            stroke = FALSE,
            fillOpacity = ~power_ratio,
            clusterOptions = markerClusterOptions(freezeAtZoom = FREEZE_AT_ZOOM_LEVEL),
            group = SOLAR_FARM_GROUP_ID,
            layerId = ~lid
          )
      }
    })

    observeEvent(state$power_ratio_input, {
      req(!is.null(state$power_ratio_input))
      print(state$power_ratio_input)
      prediction_data(
        prediction_data_raw |> 
        dplyr::filter(
          pred > state$power_ratio_input[1],
          pred < state$power_ratio_input[2])
      )
    })

    observeEvent(state$group_select, {
      req(!is.null(state$group_select))
      map <- leafletProxy("map") |> 
        clearMarkers() |> clearMarkerClusters() |> clearShapes() |> clearControls()
      if(state$group_select == "Biomass") {
        map <- map |> 
        addRectangles(
            data = biomass_data |> dplyr::mutate(lng1 = lng - 0.5, lat1 = lat - 0.5, lng2 = lng + 0.5, lat2 = lat + 0.5),
            lat1 = ~lat1, lng1 = ~lng1,
            lat2 = ~lat2, lng2 = ~lng2,
            fillOpacity = ~radius,
            fillColor = "green",
            stroke = FALSE,
            group = BIOMASS_GROUP_ID
          )
      } else if(state$group_select == "Slope") {
        map <- map |> 
        addRectangles(
            data = slope_data |> dplyr::mutate(lng1 = lng - 0.5, lat1 = lat - 0.5, lng2 = lng + 0.5, lat2 = lat + 0.5),
            lat1 = ~lat1, lng1 = ~lng1,
            lat2 = ~lat2, lng2 = ~lng2,
            fillOpacity = ~radius,
            fillColor = "gray",
            stroke = FALSE,
            group = SLOPE_GROUP_ID
          )
      } else if(state$group_select == "Potential") {
        map <- map |> 
        addRectangles(
            data = pv_potential |> dplyr::mutate(lng1 = lng - 0.5, lat1 = lat - 0.5, lng2 = lng + 0.5, lat2 = lat + 0.5),
            lat1 = ~lat1, lng1 = ~lng1,
            lat2 = ~lat2, lng2 = ~lng2,
            fillOpacity = ~radius,
            fillColor = "blue",
            stroke = FALSE,
            group = PV_POTENTIAL_GROUP_ID
          )
      }
      map <- map |> 
        addCircleMarkers(
            data = solar_data |>
              tidyr::drop_na() |>
              mutate(lid = row_number()) |>
              mutate(power_ratio = min_max_scale(power_ratio)),
            lat = ~latitude,
            lng = ~longitude,
            radius = 10,
            color = "orange",
            stroke = FALSE,
            fillOpacity = ~power_ratio,
            clusterOptions = markerClusterOptions(freezeAtZoom = FREEZE_AT_ZOOM_LEVEL),
            group = SOLAR_FARM_GROUP_ID,
            layerId = ~lid
          )
    })

    observeEvent(input$map_marker_click, {
      print(input$map_marker_click)
      state$map_click <- input$map_marker_click
    })
    
  })
}
