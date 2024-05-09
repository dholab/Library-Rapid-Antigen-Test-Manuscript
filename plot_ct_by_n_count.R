#!/usr/bin/env Rscript

library(tidyverse)
library(ggplot2)

# user inputs
n_counts_path <- "data/final_counts.csv"
cts_path <- "data/RAT_Ct_Data.txt"

# read in the dataframes while trimming any unintentional whitespace 
n_counts_df <- read_csv(n_counts_path, trim_ws = TRUE, show_col_types = FALSE)
ct_df <- read_tsv(cts_path, trim_ws = TRUE, show_col_types = FALSE)

# clean the n counts
percentages <- n_counts_df |>
  rename(Sample_ID = `#Filename`) |>
  mutate(Sample_ID = str_remove(Sample_ID, ".fa")) |>
  select(Sample_ID, Total, N) |>
  mutate(N_percentage = (N / Total) * 100)

# clean the ct dataframe
clean_cts <- ct_df |>
  mutate(Ct = as.numeric(Ct))

# join the two together
plotting_df <- percentages |>
  left_join(clean_cts, by = join_by(Sample_ID)) |>
  filter(!is.na(Ct)) |>
  rename(Passing = `Pass?`)

# plot them
ct_by_n <- plotting_df |>
  ggplot(aes(x = Ct, y = N_percentage)) +
  geom_point(size = 2.5, aes(color = Passing)) +
  geom_smooth(method = "loess", se = TRUE, show.legend = FALSE) +
  labs(x = "qPCR Cycle Threshold Value", y = "Percent ambiguous bases") + 
  theme_linedraw()

# export the plot
ggsave("visuals/ct_by_n.pdf", ct_by_n, height = 5, width = 7)
