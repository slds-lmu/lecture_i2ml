cdir <- "../cheatsheets"

## pdf files
fn <- FALSE
cheat <- list.files(path = cdir, pattern = "CheatSheet_i2ml_[[:digit:]]*.pdf", 
    full.names = fn)

## Topics
topics <- c("Notation, Definitions, Terms", 
    "Supervised classification",
    "Evaluation")
cdat <- data.frame(Topic = topics)


## Links
linkstring <- "https://nbviewer.jupyter.org/github/compstat-lmu/lecture_i2ml/blob/master/cheatsheets/"
cdat$PDF <- paste0("[pdf](", linkstring, cheat, ")")
