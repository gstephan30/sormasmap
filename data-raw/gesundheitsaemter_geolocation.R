library(tidyverse)
library(ggmap)
library(janitor)

# import data
load("data-raw/gesundheitsaemter_plz.rda")

# prep data
# filter geo locations with address
gesus_nested_prep <- gesus_nested %>%
  mutate(geo_string = paste(Street, Postalcode, Place),
         geo_string= str_trim(geo_string)) %>%
  # filter geo locations with address
  filter(geo_string != "")

# get geocodes of authority
get_geocode <- function(id, string){
  print(string)
  geo <- geocode(string, output = "all", force = FALSE)

  df <- tibble(
    id = id,
    key = names(geo),
    geo = geo
  ) %>%
    filter(key == "results") %>%
    unnest(geo) %>%
    unnest_wider(geo)

  return(df)
}

gesus_geo <- NULL
for (i in 1:nrow(gesus_nested_prep)) {
  gesus_geo[[i]] <- get_geocode(gesus_nested_prep$id[i], gesus_nested_prep$geo_string[i])
}
gesus_geo <- bind_rows(gesus_geo)

# it appears that some locations have multiple geo locations in the same area
# check this
gesus_geo %>%
  add_count(id) %>%
  filter(n > 1) %>%
  select(formatted_address, geometry) %>%
  unnest_wider(geometry) %>%
  unnest_wider(location)

# delete this double entries and clean
delete_double <- function(df){
  df %>%
    group_by(id) %>%
    mutate(ind = 1:n()) %>%
    ungroup() %>%
    filter(ind == 1) %>%
    select(-ind)
}

gesus_geo_clean <- gesus_geo %>%
  delete_double()

# combine the data
gesus_nestes_geo <- gesus_nested %>%
  left_join(gesus_geo_clean) %>%
  unnest_wider(geometry) %>%
  unnest_wider(location) %>%
  rename(long = lng)

# for validation get zip code from google
plz_ids <- gesus_geo %>%
  select(address_components) %>%
  rownames_to_column("id") %>%
  unnest(address_components) %>%
  unnest_wider(address_components) %>%
  unnest_wider(types) %>%
  janitor::clean_names() %>%
  filter(x1 == "postal_code") %>%
  select(id, plz_google = long_name)

gesus_nested_geo_plz <- gesus_nestes_geo %>%
  left_join(plz_ids) %>%
  rename(plz_rki = PLZ)

# cleanerize
gesundheitsaemter_pre <- gesus_nested_geo_plz %>%
  clean_names()

rki_data <- gesundheitsaemter_pre %>%
  select(id, code, phone, fax, email, contains("covid"), contains("aussteige")) %>%
  nest(data_rki = -c("id"))

google_data <- gesundheitsaemter_pre %>%
  select(id, key, address_components, formatted_address, location_type, viewport, bounds, place_id,
         plus_code, types, partial_match) %>%
  nest(data_google = -c("id"))

gesundheitsaemter <- gesundheitsaemter_pre %>%
  select(id, name, department, street, postalcode, place, plz_rki,
         gemeinden, long, lat, plz_google) %>%
  left_join(
    rki_data
  ) %>%
  left_join(
    google_data
  )

# use it
usethis::use_data(gesundheitsaemter, overwrite = TRUE)
#usethis::use_r("gesundheitsaemter")
#usethis::use_test("gesundheitsaemter")
