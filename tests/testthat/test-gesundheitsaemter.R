test_that("test authority plot", {
  library(ggplot2)
  library(raster)

  germany <- getData(country = "Germany", level = 1)

  gesundheitsaemter %>%
    ggplot(aes(long, lat)) +
    geom_polygon(
      data = germany,
      aes(long, lat, group = group),
      colour = "black",
      fill = "white") +
    geom_point() +
    coord_map() +
    theme_void() +
    labs(title = "German Gesundheitsaemter")
})
