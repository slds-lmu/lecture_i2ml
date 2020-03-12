exdir <- "../exercises-pdf"

## exercise and solution files
fn <- FALSE
ex <- list.files(path = exdir, pattern = "exercise_[[:digit:]]*.pdf", 
    full.names = fn)
so <- list.files(path = exdir, pattern = "solution_[[:digit:]]*.pdf", 
    full.names = fn)



## Numbers + Topics
# exid <- as.numeric(gsub("[^0-9.-]+", "", ex))
topics <- c("ML basics and supervised regression", 
    "Supervised classification",
    "Evaluation",
    "Trees and random forests",
    "Tuning")
exdat <- data.frame(Topic = topics)

## Links
linkstring <- "https://nbviewer.jupyter.org/github/compstat-lmu/lecture_i2ml/blob/master/exercises-pdf/"
exdat$Exercise <- paste0("[exercise](", linkstring, ex, ")")
exdat$Solution <- c(paste0("[solution](", linkstring, so, ")"), "")

