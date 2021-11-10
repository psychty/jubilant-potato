
# Code for creating table using {gt} and {gtExtras} packages
# remotes::install_github("jthomasmock/gtExtras")

# loading libraries
library(gt)
library(gtExtras)
library(tidyverse)

# create some data
df <- data.frame(
  unit = as.factor(c("Unit 1", "Unit 2", "Unit 3", "Unit 4", "Unit 5")),
  wc = rnorm(500, 25, 5)
) %>%
  # calculate summary stats for each unit & create data for the histogram and density plot
  group_by(unit) %>%
  summarise(
    nr = n(),
    min = min(wc, na.rm = TRUE),
    med = median(wc, na.rm = TRUE),
    max = max(wc, na.rm = TRUE),
    sd = sd(wc, na.rm = TRUE),
    hist_data = list(wc),
    dens_data = list(wc),
    .groups = "drop"
  ) 

# You need to end up with lists of data nested within each row in the input dataframe.

# basic summary table
df_basic <- df %>%
  gt() %>%
  gt_sparkline(hist_data,
               type = "histogram",
               line_color = "#474747FF",
               fill_color = "#474747FF",
               bw = 0.75,
               same_limit = TRUE) %>%
  gt_sparkline(dens_data,
               type = "density",
               line_color = "#474747FF",
               fill_color = "#DFDFDFFF",
               bw = 0.75,
               same_limit = TRUE) %>% 
  fmt_number(columns = min:sd, decimals = 1) # format decimals

df_basic_header_footnotes <- df_basic %>%
  tab_header(title = md("**Water content**"),
             subtitle = md("Summary results from laboratory tests")) %>%  # header%>%
  tab_footnote(footnote = "Fictitious data, for illustration purposes only",
               locations = cells_title(groups = "subtitle")) %>% # footnotes - you can stack these %>%
  tab_footnote(footnote = md("**Histogram** of water content for each soil unit"),
               locations = cells_column_labels(columns = hist_data)) %>% # specify which column to add the footnote %>%
  tab_footnote(footnote = md("**Density** plot of water content for each soil unit"),
               locations = cells_column_labels(columns = dens_data)) %>% 
  tab_spanner(label = "Units",
              columns = unit) %>% # you can specify hierarchical headings %>%
  tab_spanner(label = "Summary statistics",
              columns = nr:sd) %>% 
  tab_spanner(label = "Graphics",
              columns = hist_data:dens_data) %>%
  cols_label(unit = html("Soil <br> unit"),
             nr = html("No. <br> tests"),
             min = html("Min. <br> (%)"),
             med = html("Median <br> (%)"),
             max = html("Max. <br> (%)"),
             sd = html(("St. dev. <br> (%)")),
             hist_data = "Histogram",
             dens_data = "Density") %>% # You can add html to include line breaks or special characters
  cols_align(align = "right", 
             columns = everything()) %>% # align elements - you can specify all columns with everything()
  cols_align(align = "left",
             columns = unit) %>% 
  opt_align_table_header(align = "left") %>% 
  cols_width(unit ~ px(150)) %>% # set column widths
  cols_width(nr:sd ~ px(75)) %>%
  cols_width(hist_data:dens_data ~ px(100))

# add coloured dots and lines on the first column
df_basic_header_footnotes %>%
   gt_plt_dot(med,
              unit,
              palette = c("#FECEA8FF", "#FF847CFF", "#019875FF", "#5A8BB7", "#78A9CE"))

# set column widths

df_basic_header_footnotes %>%  
  tab_options(data_row.padding = px(6),
    heading.padding = px(0),
    column_labels.padding = px(0),
    footnotes.padding = px(0),
    table_body.hlines.width = px(0.5),
    table_body.hlines.color = "#474747FF",
    table_body.vlines.width = px(0.5),
    table_body.vlines.color = "#474747FF",
    row_group.border.bottom.width = px(0.5),
    row_group.border.bottom.color = "#474747FF",
    row_group.border.top.width = px(0.5),
    row_group.border.top.color = "#474747FF",
    column_labels.border.bottom.width = px(0.5),
    column_labels.border.bottom.color = "#474747FF",
    column_labels.border.top.width = px(0.5),
    column_labels.border.top.color = "#474747FF",
    table_body.border.bottom.width = px(0.5),
    table_body.border.bottom.color = "#474747FF",
    table_body.border.top.width = px(0.5),
    table_body.border.top.color = "#474747FF",
    table.border.bottom.width = px(1.5),
    table.border.bottom.color = "#474747FF",
    table.border.top.width = px(1.5),
    table.border.top.color = "#474747FF",
    heading.border.bottom.width = px(1.5),
    heading.border.bottom.color = "#474747FF",
    stub.border.width = px(1.5),
    stub.border.color = "#474747FF",
    table.background.color = "white",
    table.font.color = "#474747FF",
    table.font.names = "Open Sans",
    table.font.weight = "normal",
    table.font.size = "14px",
    heading.subtitle.font.size = "14px",
    column_labels.font.weight = "bold",
    footnotes.font.size = "12px")
