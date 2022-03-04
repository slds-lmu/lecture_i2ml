# ------------------------------------------------------------------------------
# TAB: POLYNOMIAL RIDGE
# ------------------------------------------------------------------------------

library(xtable)

betas <- getPolyData(x, y, lambda.vec, baseTrafo, degree = 10)$betas

betas <- cbind(as.numeric(rownames(betas)), betas)

colnames(betas) <- c("$\\lambda$" , sapply(1:(ncol(betas)-1), 
                                           function(i) return (paste0("$\\beta_{",
                                                                      as.character(i-1),
                                                                      "}$"))))

print(xtable(signif(betas, 2), digits = 2, align = "rr|lllllllllll"),
      row.names = FALSE, sanitize.colnames.function = function(x) x, include.rownames = FALSE,
      hline.after = 0, latex.environments = "tiny")
