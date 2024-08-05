#!/usr/bin/env Rscript

library(tidyverse)
library(ggplot2)
library(extrafont)

# user inputs
cts_path <- "../data/ct_by_cov_percentage.tsv"

# read in the dataframes while trimming any unintentional whitespace
ct_df <- read_tsv(cts_path, trim_ws = TRUE, show_col_types = FALSE)

# clean the ct dataframe
clean_cts <- ct_df |>
    mutate(`Ct Value` = as.numeric(`Ct Value`)) |>
    filter(!is.na(`Ct Value`), `Ct Value` < 45)

# write out the plotting data for transparency
write_tsv(clean_cts, "data/ct_by_n_plotting_data.tsv")

# load fonts
# font_import()
loadfonts()

# plot them
ct_by_n <- clean_cts |>
    ggplot(aes(x = `Ct Value`, y = `% Coverage at >10x Depth`)) +
    geom_point(size = 2.5, aes(color = Passing)) +
    # geom_smooth(method = "loess", se = TRUE, show.legend = FALSE) +
    labs(
        x = "qPCR cycle threshold value",
        y = "% coverage at >10x depth"
    ) +
    scale_color_manual(
        labels = c("False", "True"),
        values = c("#FD2929", "#3030FD")
    ) +
    theme_minimal() +
    theme(
        text = element_text(family = "Arial", size = 12),
        axis.text = element_text(family = "Arial", size = 12),
        axis.title = element_text(family = "Arial", size = 12),
        legend.title = element_text(family = "Arial", size = 12),
        legend.text = element_text(family = "Arial", size = 12),
    )

# export the plot
ggsave("figures/ct_by_cov.pdf", ct_by_n, height = 5, width = 7)
