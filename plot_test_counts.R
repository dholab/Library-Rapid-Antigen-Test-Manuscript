#!/usr/bin/env Rscript

library(tidyverse)
library(ggplot2)

# 
csv_path <- "data/RATs_grouped_by_month.csv"

# 
test_counts <- read_csv(csv_path, trim_ws = TRUE, show_col_types = FALSE) |>
  select(-`...5`)

#
all_counts_plot <- test_counts |>
  pivot_longer(
    cols = -Month,
    names_to = "Status",
    values_to = "Count"
  ) |>
  ggplot(aes(x = Month, y = Count, fill = Status)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
  labs(title = "Count of Tests by Status per Month", x = "Month", y = "Count") +
  theme_minimal()

#
ggsave("visuals/all_counts_plot.pdf", all_counts_plot,
       height = 6, width = 8)

# 
two_counts_plot  <- test_counts |>
  select(-`# envelopes sent out`) |>
  pivot_longer(
    cols = -Month,
    names_to = "Status",
    values_to = "Count"
  ) |>
  ggplot(aes(x = Month, y = Count, fill = Status)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
  labs(title = "Count of Tests by Status per Month", x = "Month", y = "Count") +
  theme_minimal()

#
ggsave("visuals/two_counts_plot.pdf", all_counts_plot,
       height = 6, width = 8)
