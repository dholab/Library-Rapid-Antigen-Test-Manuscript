#!/usr/bin/env Rscript

library(tidyverse)
library(ggplot2)

# user inputs
cts_path <- "data/ct_by_cov_percentage.tsv"

# read in the dataframes while trimming any unintentional whitespace
ct_df <- read_tsv(cts_path, trim_ws = TRUE, show_col_types = FALSE)

# clean the ct dataframe
clean_cts <- ct_df |>
  mutate(`Ct Value` = as.numeric(`Ct Value`)) |>
  filter(!is.na(`Ct Value`))

# write out the plotting data for transparency
# write_tsv(clean_cts, "data/ct_by_n_plotting_data.tsv")

# plot them
ct_by_n <- clean_cts |>
  ggplot(aes(x = `Ct Value`, y = `% Coverage at >10x Depth`)) +
  geom_point(size = 2.5, aes(color = Passing)) +
  # geom_smooth(method = "loess", se = TRUE, show.legend = FALSE) +
  labs(x = "qPCR Cycle Threshold Value") +
  theme_linedraw()

# export the plot
ggsave("visuals/ct_by_cov.pdf", ct_by_n, height = 5, width = 7)
