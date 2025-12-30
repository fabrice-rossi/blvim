fortify_sim_internal <- function(model,
                                 flows = c("full", "destination", "attractiveness"),
                                 with_names = FALSE,
                                 with_positions = FALSE,
                                 cut_off = 100 * .Machine$double.eps^0.5,
                                 call = rlang::caller_env()) {
  if (with_positions) {
    positions <- location_positions(model)
    if (flows == "destination" || flows == "attractiveness") {
      if (is.null(positions[["destination"]])) {
        cli::cli_abort("Missing destination location positions",
          call = call
        )
      }
      if (flows == "destination") {
        value <- destination_flow(model)
      } else {
        value <- attractiveness(model)
      }
      sim_data <- positions_as_df(positions[["destination"]], NULL)
      sim_data[[flows]] <- value
      if (with_names) {
        dnames <- destination_names(model)
        if (is.null(dnames)) {
          dnames <- seq_len(nrow(sim_data))
        }
        sim_data$name <- dnames
      }
      sim_data <- sim_data[value >= cut_off, ]
      sim_data
    } else {
      if (is.null(positions) ||
        is.null(positions[["origin"]]) ||
        is.null(positions[["destination"]])) {
        cli::cli_abort("Missing location positions",
          call = call
        )
      }
      sim_data <- flow_to_lines(
        positions$origin,
        positions$destination,
        flows(model),
        cut_off
      )
      sim_data
    }
  } else {
    if (flows == "destination" || flows == "attractiveness") {
      if (flows == "destination") {
        dest_f <- destination_flow(model)
        sim_data <- data.frame(
          destination = factor(seq_along(dest_f)),
          flow = dest_f
        )
      } else {
        attra <- attractiveness(model)
        sim_data <- data.frame(
          destination = factor(seq_along(attra)),
          attractiveness = attra
        )
      }
      if (with_names) {
        sim_data$name <- rownames(sim_data)
      }
      sim_data
    } else {
      full_f <- flows(model)
      sim_data <- expand.grid(
        origin = factor(seq_len(nrow(full_f)),
          levels = seq_len(nrow(full_f))
        ),
        destination = factor(seq_len(ncol(full_f)),
          levels = seq_len(ncol(full_f))
        )
      )
      sim_data$flow <- as.vector(full_f)
      sim_data
    }
  }
}

#' Turn a spatial interaction model into a data frame
#'
#' This function extracts from a spatial interaction model different types of
#' data frame that can be used to produce graphical representations.
#' [autoplot.sim()] leverages this function to produce its graphical
#' representations.
#'
#' The data frame produced by the method depends on the values of `flows` and
#' `with_positions`. The general principal is to have one row per flow, either a
#' single flow from an origin location to a destination location, or an
#' aggregated flow to a destination location. Flows are stored in one column of
#' the data frame, while the other columns are used to identify origin and
#' destination.
#'
#' If `with_position` is `FALSE` (default value), data frames are simple.
#' Depending on `flows`, the function extracts different data frames:
#'
#' -  `"full"`: this is the default case for which the full flow matrix is extracted.
#' The data frame has three variables:
#'    - `origin`: identifies the origin location by its index from 1 to the number
#' of origin locations
#'    - `destination`: identifies the destination location by its index from 1
#' to the number of destination locations
#'    - `flow`: the flow between the corresponding location
#' It is recommend to use [flows_df()] for more control over the extraction
#' outside of simple graphical representations.
#' -  `"destination"`: the data frame has only two or three columns:
#'    - `destination`: identifies the destination location by its index from 1
#' to the number of destination locations
#'     - `flow`: the incoming flows (see [destination_flow()])
#'     - `name`: the name of the destination location if `with_names` is `TRUE`
#' -  `"attractiveness"`: the data frame has also two ot three columns,
#' `destination` and `name` as in the previous case and `attractiveness` which
#' contains the attractivenesses of the destinations (see [attractiveness()]).
#'
#' When the  `with_positions` parameter is `TRUE`, the location positions
#' ([location_positions()]) are used to produce more "geographically informed"
#' extractions. Notice that if no positions are known for the locations, the use
#' of `with_positions = TRUE` is an error. Depending on `flows` we have the
#' following representations:
#'
#' -  `"full"`: this is the default case for which the full flow matrix is extracted.
#' Positions for both origin and destination locations are needed. The data
#' frame contains five columns:
#'    - `x` and `y` are used for the coordinates of the origin locations
#'    - `xend` and `yend` are used for the coordinates of the destination locations
#'    - `flow` is used for the flows
#' - `"destination"` and `"attractiveness"` produce both a data frame with three
#' or four columns. As when `with_positions` is `FALSE`, one column is dedicated either
#' to the incoming flows ([destination_flow()]) for `flows="destination"` (the
#' name of the column is `destination`) or to the attractivenesses
#' ([attractiveness()]), in which case its name is `attractiveness`. The other
#' two columns are used for the positions of the destination locations. Their
#' names are the names of the columns of the positions
#' (`colnames(destination_location(object))`) or `"x"` and `"y"`, when such
#' names are not specified. If `with_names` is `TRUE`, a `name` column is included
#' and contains the names of the destination locations.
#'
#' In the position based data frames, rows are excluded from the returned data
#' frames when the flow they represent are small, i.e. when they are smaller
#' than the `cut_off` value.
#'
#' @param model a spatial interaction model object
#' @param data not used
#' @param flows  `"full"` (default),  `"destination"` or `"attractiveness"`, see
#'   details.
#' @param with_names specifies whether the extracted data frame includes
#'   location names (`FALSE` by default)
#' @param with_positions specifies whether the extracted data frame is based on
#'   location positions (`FALSE` by default)
#' @param cut_off cut off limit for inclusion of a flow row in the final data
#'   frame.
#' @param ... additional parameters, not used currently
#'
#' @exportS3Method ggplot2::fortify
#' @seealso [autoplot.sim()], [flows_df()]
#' @returns a data frame, see details
#' @examplesIf requireNamespace("ggplot2", quietly = TRUE)
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' flows <- blvim(distances, production, 1.5, 4, attractiveness,
#'   origin_data =
#'     list(names = LETTERS[1:10], positions = positions), destination_data =
#'     list(names = LETTERS[1:10], positions = positions)
#' )
#' ggplot2::fortify(flows)
#' ggplot2::fortify(flows, flows = "destination")
#' ggplot2::fortify(flows, flows = "attractiveness")
#' ## positions
#' ggplot2::fortify(flows, flows = "attractiveness", with_positions = TRUE)
#' ## names and positions
#' ggplot2::fortify(flows,
#'   flows = "destination", with_positions = TRUE,
#'   with_names = TRUE
#' )
#' ggplot2::fortify(flows, with_positions = TRUE, cut_off = 0.1)
fortify.sim <- function(model, data,
                        flows = c("full", "destination", "attractiveness"),
                        with_names = FALSE,
                        with_positions = FALSE,
                        cut_off = 100 * .Machine$double.eps^0.5,
                        ...) {
  with_cut_off <- !missing(cut_off)
  flows <- rlang::arg_match(flows)
  sim_autoplot_warning(
    with_names, with_positions, with_cut_off, cut_off,
    FALSE, NA, FALSE, NA
  )
  fortify_sim_internal(model, flows, with_names, with_positions, cut_off)
}
