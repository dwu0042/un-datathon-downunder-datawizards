find_closest_points <- function(data, target_x, target_y, filter_range = 2) {
  # Filter the data to include only points within the approximate range of the target
  filtered_data <- data[
    data$x >= (target_x - filter_range) & data$x <= (target_x + filter_range) &
      data$y >= (target_y - filter_range) & data$y <= (target_y + filter_range), ]
  
  # Calculate the Euclidean distance for the filtered data
  filtered_data$distance <- sqrt((filtered_data$x - target_x)^2 + (filtered_data$y - target_y)^2)
  
  # Order by distance and select the closest n points
  closest_points <- head(filtered_data[order(filtered_data$distance), ], n)
  
  # Return the closest points without the distance column
  return(closest_points$id)
}

# sub
sub_cov <- covariates %>% 
  slice_max(pred, n = 40)
  
ll <- list()
for(i in 1:nrow(sub_cov)){
  ll[[i]] <- find_closest_points(covariates, sub_cov$x[i], sub_cov$y[i], filter_range = 2)
  message(i)
}
unll <- unlist(ll)
selected_IDs <- unll[!duplicated(unll)]

covariates %>% 
  mutate(here = id %in%selected_IDs) %>% 
  ggplot(aes(y = y, x = x, col = here))+
  geom_point()
