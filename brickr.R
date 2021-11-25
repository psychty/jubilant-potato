#install.packages("brickr")

library(png)
library(brickr)

mosaic1 <- readPNG('C:/Users/richt/OneDrive/Pictures/weird_al.png') %>% 
  image_to_mosaic(img_size = 184)

mosaic1 %>% 
  build_mosaic()

mosaic1 %>% 
  build_instructions(9)

mosaic1 %>% 
  build_pieces()
