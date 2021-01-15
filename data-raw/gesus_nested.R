## code to prepare `gesus_nested` dataset goes here
# usethis::use_data_raw(name = "gesus_nested")
# usethis::use_r("gesus_nested")
library(tidyverse)
library(xml2)

# read recent file (here export 13/1/21)
gesu_xml_file <- system.file("extdata", "aktueller_datenbestand_gesundheitsaemter_rki_20210114.xml", package = "sormasmap")
gesus <- read_xml(gesu_xml_file)

# start generating tibble
children <- gesus %>%
  xml_children() %>%
  xml_attrs()

gesus_df <- tibble(
  xml = children
) %>%
  unnest_wider(xml) %>%
  rownames_to_column('id')

# get all information of node children
get_child_info <- function(xml, node){
  print(paste0("Reading node: ", node))
  values <- xml %>%
    xml_children() %>%
    .[as.numeric(node)] %>%
    xml_children() %>%
    xml_attrs() %>%
    unlist()
  id <- node

  df <- tibble(id, values)

  return(df)
}

child_infos <- map_df(gesus_df$id, function (x) get_child_info(gesus, x))

# categorise zip code (PLZ) and local areas (Gemeinden)
child_df <- child_infos %>%
  mutate(key = if_else(grepl("[0-9]", values), "PLZ", "Gemeinden"))  %>%
  pivot_wider(
    names_from = key,
    values_from = values
  )

# join
gesus_nested <- gesus_df %>%
  left_join(child_df)

# Save in convenient form for further wrangling
save(gesus_nested, file = "data-raw/gesundheitsaemter_plz.rda")
usethis::use_data(gesus_nested, internal = TRUE, overwrite = TRUE)
