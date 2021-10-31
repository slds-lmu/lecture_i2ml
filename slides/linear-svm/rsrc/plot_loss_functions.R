################################################################################
# FIGURE: 0-1 LOSS & HINGE LOSS
################################################################################

# Lisa Wimmer

# PREREQ -----------------------------------------------------------------------

library(ggplot2)

# LOSS FUNCTIONS ---------------------------------------------------------------

zero_one_loss = function(f) {ifelse(f < 0, 1, 0)}

hinge_loss = function(f) {sapply(f, FUN = function(x) max(0, 1 - x))}

squared_hinge_loss = function(f) {
  sapply(f, FUN = function(x) (max(0, 1 - x))^2)}

huber_loss = function(f) {
  ifelse(f <= 1, ifelse(f <= 0, 1 - 2*f, (1 - f)^2), 0)}

log_loss = function(f) log(1 + exp(-f)) / log(2)

# PLOTS ------------------------------------------------------------------------

#' @param x Vector of values to calculate losses for
#' @param include Which losses to show

plot_losses = function(include = c("01", "hinge", "sqhinge", "huber", "log")) {
  x = seq(-2, 1.5, length.out = 10000)
  cols = c("01" = "#067B7F", hinge="#66CC00", sqhinge="#000099", huber="#6B007B", log = "220000")

  p = ggplot(data.frame(x), aes(x = x)) 
  p = p + labs(x = expression(paste(italic(y), italic(f))), 
               y = expression(paste(italic(L), "(", italic(y), ",", italic(f),")"))) 
 
  if ("01" %in% include) {
    # Split 0-1 loss to avoid lopsided line at x = 0
    p = p + stat_function(fun = "zero_one_loss", aes(col = "0-1"), 
                          xlim = c(-2, -0.001), size = 1.5)
    p = p + stat_function(fun = "zero_one_loss", aes(col = "0-1"), 
                          xlim = c(0.001, 1.5), size = 1.5)
    p = p + geom_segment(aes(x = 0, xend = 0, y = 0, yend = 1), 
                         size = 1.5, col = cols["01"])
  }
  if ("hinge" %in% include) 
    p = p + stat_function(fun = "hinge_loss", aes(col = "hinge"), size = 1) 
  if ("sqhinge" %in% include) 
      p = p + stat_function(fun = "squared_hinge_loss", aes(col = "sq. hinge"), size = 1) 
  if ("huber" %in% include) 
      p = p + stat_function(fun = "huber_loss", aes(col = "huber"), size = 1) 
  if ("log" %in% include) 
      p = p + stat_function(fun = "log_loss", aes(col = "log"), size = 1) 
  
  # Axes
  p = p + geom_hline(yintercept = 0)
  p = p + geom_vline(xintercept = 0)
  p = p + scale_y_continuous(limits = c(0, 3))
  
  # Legend
  p = p + scale_color_manual("Losses", values = unname(cols[include]))
  p = p + theme(legend.position = "right")
  p = p + guides(col = guide_legend(nrow = 5, byrow = TRUE))
  return(p)
}

# p = plot_losses(c("01", "hinge", "sqhinge", "huber", "log"))
# print(p)
