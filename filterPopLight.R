# packages


## Function ## -----------------------------------------------------------------
strictly_between_zero_and_one <- function(x) {
  # Normalizing x to be within [0, 1]
  x_min <- min(x, na.rm = T)
  x_max <- max(x, na.rm = T)
  x_norm <- (x - x_min) / (x_max - x_min)
  
  # Ensuring values are strictly between 0 and 1 by adjusting the endpoints
  # to be slightly more than 0 and less than 1.
  epsilon <- .Machine$double.eps ^ 0.5
  x_adj <- epsilon + (1 - 2 * epsilon) * x_norm
  
  return(x_adj)
}

## Code ## ------------------------------------------------------------


full_df %>% 
  filter(density >20) %>% 
  slice_sample(prop = 40) %>% 
  ggplot(aes(y = y, x  = x, col = density))+
  geom_point()

full_df %>% 
  mutate(night_light_r = strictly_between_zero_and_one(night_light),
         density_r = strictly_between_zero_and_one(density)) %>% 
  #filter(density_r < 0.1) %>% 
  ggplot(aes(y = density, x = night_light))+
  geom_point()

full_df %>% 
  mutate(night_light_r = strictly_between_zero_and_one(night_light),
         density_r = strictly_between_zero_and_one(density)) %>% 
  ggplot(aes(y = night_light_r, x = 1:nrow(.)))+
  geom_point()

full_df %>% 
  mutate(new_lat = round(y),
         new_lon = round(x)) %>% 
  group_by(new_lat, new_lon) %>% 
  summarise(density = mean(density, na.rm = T)) %>% 
  ggplot(aes(x = density))+
  geom_density()

