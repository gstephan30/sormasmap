#' Loading the shape files
#'
#' Loading shape files with its polygon location, zip codes
#' and population.
#'
#' @param zip_dim integer if zip code dimension has 1, 2, 3 or 5 digits
#'
#' @return tibble with geo location, population and zip code
#'
#' @import dplyr tibble rgdal broom here
#'
#'
#' @export
load_shp <- function(zip_dim){

  if (!zip_dim %in% c(1, 2, 3, 5)) {
    stop("Please select zip code level 1, 2, 3 or 5")
  }

  layer <- paste0("plz-", zip_dim, "stellig")
  folder <- paste0(layer, ".shp")
  path <- here("inst", "extdata", folder)

  data <- readOGR(path, layer = layer)

  df <- data@data %>%
    rownames_to_column("id") %>%
    inner_join(
      tidy(data), by = "id"
    ) %>%
    as_tibble()

  return(df)
}
