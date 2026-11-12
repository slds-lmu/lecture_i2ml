# Evaluation 2 Shiny App

This folder contains a first-draft Shiny app for teaching Exercise 6 -- Evaluation II.

The app has two blocks:

- Exercise 1: an interactive overfitting and underfitting demo using polynomial regression.
- Exercise 2: a draft resampling block with a polynomial-degree slider, a sample-size slider, a CV/subsampling/bootstrap selector, a repetitions selector, and a train/test MSE table. In CV mode, the app creates one row per held-out fold for each repetition. In subsampling mode, it repeats one fixed two-thirds/one-third train/test split procedure. In bootstrap mode, it samples with replacement for training and evaluates on the out-of-bag observations.

## Folder Contents

```text
evaluation-02-shiny/
  app.R
  README.md
```

The app is self-contained and uses synthetic data generated inside `app.R`.

## Requirements

You need R installed and the following packages:

```r
install.packages(c("shiny", "ggplot2"))
```

## Run

Open `app.R` in RStudio and click `Run App`, or run:

```r
shiny::runApp("shiny/evaluation-02-shiny")
```
