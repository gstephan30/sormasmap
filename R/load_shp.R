#' Loading the shape files
#'
#' Loading shape files with its polygon location, zip codes
#' and population.
#'
#' @param zip_dim integer if zip code dimension has 1, 2, 3 or 5 digits
#' @param quality character string either "high" (default) or "low"
#'
#' @return tibble with geo location, population and zip code
#'
#'
#'
#' @export
load_shp <- function(zip_dim, quality = "high"){

  if (!zip_dim %in% c(1, 2, 3, 5)) {
    stop("Please select zip code level 1, 2, 3 or 5")
  }

  if (!quality %in% c("high", "low")) {
    stop("Please use either high or low as quality")
  }

  layer <- paste0("plz-", zip_dim, "stellig")

  if (quality == "low") {
    folder <- paste0(layer, "_mittel.shp")
  } else if (quality == "high") {
    folder <- paste0(layer, ".shp")
  }

  path <- here::here("inst", "extdata", folder)

  data <- rgdal::readOGR(path, layer = layer)

  df <- data@data %>%
    tibble::rownames_to_column("id") %>%
    dplyr::inner_join(
      broom::tidy(data), by = "id"
    ) %>%
    tibble::as_tibble()

  return(df)
}
