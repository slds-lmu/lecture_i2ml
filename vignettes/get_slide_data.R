# library("tidyr")
# library("tibble")

library("Hmisc")

## Get slide directories
# slidedirs <- list.dirs(path = ".", recursive = FALSE, full.names = FALSE)
slidedirs <- c(
    "ml-basics", 
    "supervised-regression", 
    "supervised-classification",
    "evaluation", 
    "trees", 
    "forests", 
    "tuning"
)

# ## Get names of all Rnw files
# rnw_list <- sapply(slidedirs, list.files, pattern = "*.Rnw")
# rnw_c <- do.call(c, rnw_list)
# 
# ## Create a data set
# sldat <- rnw_list %>% 
#     enframe(., name = "slidedirs", value = "rnws") %>% 
#     unnest()

## Directory order
sldir_order <- data.frame(dir = slidedirs, dirorder = seq_along(slidedirs), 
    stringsAsFactors = FALSE)

## Slide order
get_slide_order <- function(sd) {
    sof <- list.files(path = paste0("../slides/", sd), pattern = "*-order.txt", full.names = TRUE)
    
    if(length(sof) == 0) return(data.frame(dir = sd, order = 1, deck = NA))
    
    so <- read.table(sof, sep = " ", skip = 1, stringsAsFactors = FALSE)$V2
    so <- so[grep(pattern = "slides-", so)]
    so <- unique(so)
    data.frame(dir = sd, order = seq_along(so), deck = so)
}
sl_order_list <- lapply(slidedirs, get_slide_order)

sl_order <- do.call("rbind", sl_order_list)

## Slide deck and directory order
sldat0 <- merge(sldir_order, sl_order, by = "dir")


## Link data
linkdat <- rbind(
    c("slides-basics-whatisml", "What is ML?", "https://youtu.be/CCzx4UDkzpA"),
    c("slides-basics-supervised", "Supervised Learning", "https://youtu.be/R_HZBY9RMmo"),
    c("slides-basics-datatask", "Tasks and Data", "https://youtu.be/d9YbO6P4AdU"),
    c("slides-basics-learners", "Models & Learners", "https://youtu.be/UW1E4xO0hJQ"),
    c("slides-basics-riskminimization", "Losses and Risk Minimization", "https://youtu.be/2b4x765XbUI"),
    c("slides-basics-learnercomponents-hro", "Components of a Learner", "https://youtu.be/zaB7WioK1Kw"),
    
    c("slides-regression-linearmodel", "Linear Regression Models", "https://youtu.be/XITIVU37wGY"),
    c("slides-regression-losses", "Loss Fuctions for Regression", "https://youtu.be/Syrzezpj2FY"),
    c("slides-regression-polynomials", "Polynomial Regression Models", "https://youtu.be/q1ETfSxEfSg"),
    c("slides-regression-knn", "k-NN", "https://youtu.be/g8H6-MkN_q0"),
    
    c("slides-classification-tasks", "Classification Tasks", NA),
    c("slides-classification-basicsdefs", "Basic Definitions", NA),
    c("slides-classification-linear", "Linear Classifiers", NA),
    c("slides-classification-logistic", "Logistic Regression", NA),
    c("slides-classification-discranalysis", "Discriminant Ananlysis", NA),
    c("slides-classification-naivebayes", "Naive Bayes", NA),
    c("slides-classification-knn", "K-Nearest Neighbors", NA),
    
    c("slides-evaluation-intro", "Introduction", "https://youtu.be/B5PAwfDYt30"),
    c("slides-evaluation-measures-regression", "Measures Regression", "https://youtu.be/_OHCatRSc08"),
    c("slides-evaluation-measures-classification", "Measures Classification", "https://youtu.be/bHwUwrbCHEU"),
    c("slides-evaluation-measures-classification-roc", "Measures Classification ROC", "https://youtu.be/BH4oCliBzZI"),
    c("slides-evaluation-measures-classification-roc-space", "Measures Classification ROC Visualisation", "https://youtu.be/m5We8ITYEVk"),
    c("slides-evaluation-overfitting", "Overfitting", "https://youtu.be/zSlrfST8bEg"),
    c("slides-evaluation-train", "Training Error", "https://youtu.be/dpZLGIf97m0"),
    c("slides-evaluation-test", "Test Error", "https://youtu.be/GOTPjCXhiS8"),
    c("slides-evaluation-resampling", "Resampling", "https://youtu.be/NvDUk8Bxuho"),
    
    c("slides-cart-intro", "Introduction", "https://youtu.be/R_PqefI-ON8"),
    c("slides-cart-splitcriteria", "Splitting Criteria", "https://youtu.be/IgHTJsAJTok"),
    c("slides-cart-treegrowing", "Growing a tree", "https://youtu.be/UjuJCgeZ6HA"),
    c("slides-cart-splitcomputation", "Computational Aspects of Finding Splits", "https://youtu.be/RujQ_xP-NFA"),
    c("slides-cart-stoppingpruning", "Stopping criteria & pruning", "https://youtu.be/oQj3N2T-T90"),
    c("slides-cart-discussion", "Discussion", "https://youtu.be/nKULLVAUk74"),
    
    c("slides-forests-bagging", "Bagging Ensembles", "https://youtu.be/hRBeeFpfMZQ"),
    c("slides-forests-intro", "Introduction", "https://youtu.be/chberfdaTwc"),
    c("slides-forests-benchmark", "Benchmarking Trees, Forests, and Bagging K-NN", "https://youtu.be/uOamholBaZ0"),
    c("slides-forests-proximities", "Proximities", "https://youtu.be/RGa0Uc6ZbX4"),
    c("slides-forests-featureimportance", "Feature Importance", "https://youtu.be/cw4qG9ePZ9Y"),
    c("slides-forests-discussion", "Discussion", "https://youtu.be/9bqNhq6OUUk"),
    
    c("slides-tuning-basics", "Introduction", NA),
    c("slides-tuning-algorithms", "Tuing Algorithms", NA)
)
colnames(linkdat) <- c("deck", "description", "youtube")


## Combine all data
sldat1 <- merge(sldat0, linkdat, by = "deck", all = TRUE)
sldat <- sldat1[with(sldat1, order(dirorder, order)), ]


## Make data presentable on website
# Generate topic
generate_topic <- function(x) {
    s <- strsplit(x, "-")[[1]]
    s <- paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
    gsub(pattern = "Ml", replacement = "ML", s)
}
sldat$topic <- sapply(sldat$dir, generate_topic)

# Capitalize colnames
names(sldat) <- capitalize(names(sldat))

# Create links
sldat$PDF <- paste0("[pdf](https://github.com/compstat-lmu/lecture_i2ml/blob/master/slides-pdf/", sldat$deck, ".pdf)")
sldat$PDF[is.na(sldat$Youtube)] <- "Coming soon"
sldat$YouTube <- paste0("[link](", sldat$Youtube, ")")
sldat$YouTube[is.na(sldat$Youtube)] <- "Coming soon"

# Lesson ID
sldat$Lesson <- paste(sldat$Dirorder, sldat$Order, sep = ".")


# write.csv(sldat, "slide_data.csv")


