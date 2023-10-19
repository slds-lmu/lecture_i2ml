#! /usr/bin/env Rscript

# Using pak for speed and convenience
# Only installs packages if not installed already.
if (!("pak" %in% installed.packages())) install.packages("pak")

# I started with like 2 dependencies and then it festered. Whoopsie.
pak::pak(c(
  "ggplot2",
  "mlr3verse",
  "rmarkdown"
))

# GH version required due to collapse_rows() bug in CRAN version
# Check if installed manually because GitHub lookup is a lot slower
# if (!("kableExtra" %in% installed.packages())) pak::pak("haozhu233/kableExtra")
