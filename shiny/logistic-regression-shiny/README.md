# Interactive Logistic Regression Shiny App

This folder contains a self-contained Shiny app for exploring 1D and 2D logistic regression.

The app lets you change model parameters and the decision threshold interactively. It shows how the logistic probability curve or surface changes, how the decision rule changes, and how fixed observations are assigned to class 0 or class 1.

## Folder Contents

```text
logistic-regression-shiny/
  app.R
  README.md
```

- `app.R` contains the full Shiny app.
- `README.md` contains these instructions.

## Requirements

You need R installed on your computer.

The app also uses two R packages:

```r
install.packages(c("shiny", "plotly"))
```

You only need to install these packages once.

## Recommended Way To Run The App In RStudio

1. Download or copy the complete `logistic-regression-shiny` folder.
2. Open RStudio.
3. In RStudio, open the file `app.R`.
4. Click the `Run App` button at the top of the editor.
5. The app will open in the RStudio viewer or in your web browser.

If RStudio asks whether to run the app externally or in the viewer, either option is fine.
