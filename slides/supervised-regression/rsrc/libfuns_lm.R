#  -----------------------------------------------------------------------------
#  LIBRARY FUNCTIONS
#  -----------------------------------------------------------------------------

library(ggplot2)

# FUNCTIONS --------------------------------------------------------------------

univariate_lm <- function(x, coeffs) coeffs[1] + coeffs[2] * x

make_lm_l2_plot <- function(
        x, y, coeffs, plot_color, psize = 3, pcol = "black", add_squares = TRUE
    ) {
    df <- data.table(x, y)
    df[
        , `:=`(
            intercept = coeffs[1],
            slope = coeffs[2],
            yhat = univariate_lm(x, coeffs),
            xmax = x + abs(y - univariate_lm(x, coeffs)),
            ymax = univariate_lm(x, coeffs)
        ),
        by = seq_len(nrow(df))
        ][, sq_error := (y - yhat)^2, by = seq_len(nrow(df))]
    p <- ggplot(data = data.frame(x, y), aes(x, y)) +
        theme_bw() +
        labs(x = expression(x[1])) +
        geom_point(shape = 4, size = psize, col = pcol) +
        geom_abline(
            slope = coeffs[2], intercept = coeffs[1], col = plot_color
        ) 
    if (add_squares == TRUE) {
        p <- p +
        geom_rect(
            df,
            mapping = aes(
                xmin = df$x, xmax = df$xmax, ymin = df$y, ymax = df$ymax
            ),
            alpha = 0.1,
            col = plot_color,
            fill = plot_color,
        )
    }
    p
}
