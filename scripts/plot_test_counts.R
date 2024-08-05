#!/usr/bin/env Rscript

library(tidyverse)
library(ggplot2)
library(extrafont)

#
csv_path <- "../data/RATs_grouped_by_month.csv"

# read in the counts into memory
test_counts <- read_csv(csv_path, trim_ws = TRUE, show_col_types = FALSE)

# load fonts
# font_import()
loadfonts()

# create color palettes
status_fills <- c(
    "# tests received" = "#FD2929",
    "# tests that passed" = "#3030FD"
)

# make a bar plot of all counts through time
all_counts_plot <- test_counts |>
    pivot_longer(
        cols = -Month,
        names_to = "Status",
        values_to = "Count"
    ) |>
    ggplot(aes(x = Month, y = Count, fill = Status)) +
    geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
    scale_fill_manual(values = status_fills) +
    labs(title = "Count of Tests by Status per Month", x = "Month", y = "Count") +
    theme_minimal() +
    theme(
        text = element_text(family = "Arial", size = 12),
        axis.text = element_text(family = "Arial", size = 12),
        axis.title = element_text(family = "Arial", size = 12),
        legend.title = element_text(family = "Arial", size = 12),
        legend.text = element_text(family = "Arial", size = 12),
    )

# save the all counts plot
ggsave("visuals/all_counts_plot.pdf", all_counts_plot,
    height = 6, width = 8
)

# make a plot that only shows the number of envelopes received and the number
# sequenced
two_counts_plot <- test_counts |>
    select(-`# envelopes sent out`) |>
    pivot_longer(
        cols = -Month,
        names_to = "Status",
        values_to = "Count"
    ) |>
    ggplot(aes(x = Month, y = Count, fill = Status)) +
    geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
    scale_fill_manual(values = status_fills) +
    labs(title = "Count of Tests by Status per Month", x = "Month", y = "Count") +
    theme_minimal() +
    theme(
        text = element_text(family = "Arial", size = 12),
        axis.text = element_text(family = "Arial", size = 12),
        axis.title = element_text(family = "Arial", size = 12),
        legend.title = element_text(family = "Arial", size = 12),
        legend.text = element_text(family = "Arial", size = 12),
    )

# save the plot with two bars
ggsave("figures/two_counts_plot.pdf", two_counts_plot,
    height = 6, width = 8
)
