cdir <- "../cheatsheets"

## pdf files
fn <- FALSE
cheat <- list.files(path = cdir, pattern = "CheatSheet_i2ml_[[:digit:]]*.pdf", 
    full.names = fn)

## Topics
topics <- c("Notation, Definitions, Terms", 
    "Supervised classification",
    "Supervised regression",
    "Evaluation",
    "trees")
cdat <- data.frame(Topic = topics)


## Links
# current fix, please update once
# https://github.com/compstat-lmu/lecture_i2ml/issues/520
# is fixed
cheat <- cheat[c(1, 2, 5, 3, 4)]


linkstring <- "https://nbviewer.jupyter.org/github/compstat-lmu/lecture_i2ml/blob/master/cheatsheets/"
cdat$PDF <- paste0("[pdf](", linkstring, cheat, ")")
