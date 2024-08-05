# Supplemental Information for Emmen et al. 2024

## Overview

This repository contains supplemental files associated with Emmen et al. 2024, _SARS-CoV-2 genomic surveillance from community-distributed rapid antigen tests_, including:

1. Data files used to generate figures (see [`data/`](/data))
2. R scripts used to generate figures associated with each data file (see [`scripts/`](/scripts))
3. The PDF-formatted figures themselves (see [`figures/`](/figures))
4. instructions on running [`nf-core/viralrecon`](https://nf-co.re/viralrecon/2.6.0/) with the settings used for the manuscript (see `[viralrecon_setup/`](/viralrecon_setup))

This README will also go over how to use the scripts to reproduce the figures.

## Reproducing Figures

The two R scripts in this repo, [`scripts/plot_ct_by_n_count.R`](/scripts/plot_ct_by_n_count.R) and [`scripts/plot_test_counts.R`](/scripts/plot_test_counts.R), can be used to reproduce the Ct-value and test count figures in Emmen et al. 2024. To do so, make sure R is installed. In an R console, make sure the `tidyverse` and `extrafonts` libraries are installed globally with the following:

```r
install.packages("tidyverse")
install.packages("extrafonts")
```

Once both installations have finished, the scripts can be run like so:

```bash
Rscript scripts/plot_ct_by_n_count.R
Rscript scripts/plot_test_counts.R
```

This will regenerate the figures in [`figures/`](/figures).

## Setting up `nf-core/viralrecon`

Emmen et al. 2024 uses the open-source pipeline [`nf-core/viralrecon`](https://nf-co.re/viralrecon/2.6.0/) to perform its bioinformatics. Comprehensive instructions on setting up `viralrecon` with the same settings the manuscript used can be read at [`viralrecon_setup/README.md`](/viralrecon_setup/README.md).

## Citation

Coming soon!
