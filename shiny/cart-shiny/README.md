# CART Splitting Criteria Shiny App

This folder contains a self-contained Shiny app for the CART exercise in
`exercises/trees/trees.qmd`.

The app fits a regression tree to the `bike_sharing` task with the `date`
feature omitted. The sliders control the CART stopping and pruning settings
used in the exercise:

- `maxdepth`
- `minsplit`
- `minbucket`
- `cp`

The `cp` control can be switched off. When it is off, the app fits with
`cp = 0`, so the displayed tree is controlled by the remaining stopping rules.
The `minbucket` control can also be switched off. When it is off, the app uses
the `rpart` default `round(minsplit / 3)`.

## Folder Contents

```text
cart-shiny/
  app.R
  bike_sharing.csv
  README.md
```

## Requirements

You need R installed and the following packages:

```r
install.packages(c("shiny", "rpart", "rpart.plot"))
```

## Run

Open `app.R` in RStudio and click `Run App`, or run:

```r
shiny::runApp("shiny/cart-shiny")
```
