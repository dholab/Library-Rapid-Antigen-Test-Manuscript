#!/usr/bin/env Rscript

library(tidyverse)
library(ggplot2)

csv_path <- "RATs_grouped_by_month.csv"

test_counts <- read_csv(csv_path, trim_ws = TRUE, show_col_types = FALSE)

cleaned_counts <- test_counts |>
  select(-c(`...5`, `# envelopes sent out`)) |>
  pivot_longer(
    cols = -Month,
    names_to = "Status",
    values_to = "Count"
  )

cleaned_counts |>
  ggplot(aes(x = Month, y = Count, fill = Status)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
  labs(title = "Count of Tests by Status per Month", x = "Month", y = "Count") +
  theme_minimal()
