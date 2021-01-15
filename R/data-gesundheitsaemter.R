#' Geo location of German Gesundheitsaemter
#'
#' This data is generated from RKI PLZ Took
#' <https://www.rki.de/DE/Content/Infekt/IfSG/Software/software_node.html>
#' geolocations are generated using the package `ggmap`.
#'
#' The data is nested, hence some columns are lists.
#'
#' @import dplyr
#'
#' @format A tibble with 31 columns
#' \describe{
#'   \item{id}{Technical identifyer of the health authority}
#'   \item{Name}{Name of the health authority}
#'   \item{Code}{RKI Code of the health authority}
#'   \item{Department}{Type of health authority}
#'   \item{Street}{Street name}
#' }
#' @examples
#' library(dplyr)
#' gesundheitsaemter %>% select(name, long, lat, postalcode)
#'
#' library(tidyr)
#' gesundheitsaemter %>%
#'   select(name, postalcode, plz_rki) %>%
#'   unnest(plz_rki)
#'
"gesundheitsaemter"
