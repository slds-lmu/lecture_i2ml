# Interactive Regression Evaluation Shiny App

This folder contains a self-contained Shiny app for exploring how regression learners are evaluated.

The app lets you change a polynomial regression degree, sample new test data, and compare linear and polynomial fits using MAE and MSE. It also includes a train-test split exercise with the California housing data, where you can change the split size, sample at random or by ordered income, and compare test MSE across repeated splits.

## Folder Contents

```text
evaluation-01-shiny/
  app.R
  california_housing.csv
  README.md
```

- `app.R` contains the full Shiny app.
- `california_housing.csv` contains the California housing data used in the train-test split exercise.
- `README.md` contains these instructions.

## Requirements

You need R installed on your computer.

The app also uses two R packages:

```r
install.packages(c("shiny", "ggplot2"))
```

You only need to install these packages once.

## Recommended Way To Run The App In RStudio

1. Download or copy the complete `evaluation-01-shiny` folder.
2. Open RStudio.
3. In RStudio, open the file `app.R`.
4. Click the `Run App` button at the top of the editor.
5. The app will open in the RStudio viewer or in your web browser.

Keep `california_housing.csv` in the same folder as `app.R` so the app can load the data.

If RStudio asks whether to run the app externally or in the viewer, either option is fine.
