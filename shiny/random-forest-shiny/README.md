# Random Forest Shiny App

This folder contains a self-contained Shiny app for Exercise 2, "Classifying
spam", from `exercises/forests/forests.qmd`.

The app covers items a), b), and d). It intentionally skips item c), except that
the random forest section reports the OOB error as context for the fitted forest.

## What The App Shows

- Interactive inspection of the `spam` task: class balance and feature
  distributions.
- Decision tree stability: one CART on the full data and two CARTs on random
  60% subsets.
- Random forest permutation importance for the spam predictors.

## Folder Contents

```text
random-forest-shiny/
  app.R
  README.md
```

The app loads the spam data with `mlr3::tsk("spam")`, so no local CSV file is
needed.

## Requirements

You need R installed and the following packages:

```r
install.packages(c(
  "shiny",
  "ggplot2",
  "mlr3",
  "mlr3data",
  "rpart",
  "rpart.plot",
  "ranger"
))
```

## Run

Open `app.R` in RStudio and click `Run App`, or run:

```r
shiny::runApp("shiny/random-forest-shiny")
```
