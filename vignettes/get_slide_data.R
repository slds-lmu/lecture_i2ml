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


## Link data videos
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
    
    c("slides-classification-tasks", "Classification Tasks", "https://youtu.be/JhNydqlMVeE"),
    c("slides-classification-basicdefs", "Basic Definitions", "https://youtu.be/cURlX3q69kk"),
    c("slides-classification-linear", "Linear Classifiers", "https://youtu.be/wR43JOYxTZM"),
    c("slides-classification-logistic", "Logistic Regression", "https://youtu.be/TLb29_fEzhU"),
    c("slides-classification-discranalysis", "Discriminant Ananlysis", "https://youtu.be/inIhdMwQ4Ik"),
    c("slides-classification-naivebayes", "Naive Bayes", "https://youtu.be/bvAYZsIt04U"),
    c("slides-classification-knn", "K-Nearest Neighbors", "https://youtu.be/WkECa1jRTmw"),
    
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
    
    c("slides-tuning-intro", "Introduction", "https://youtu.be/lG4Ul1Liq-U"),
    c("slides-tuning-tuningproblem", "Problem Definition", "https://youtu.be/Eo7iqMOeILY"),
    c("slides-tuning-basicalgos", "Basic Techniques", "https://youtu.be/A1cx4FkS0lw"),
    c("slides-tuning-nestedintro", "Nested Resampling Motivation", "https://youtu.be/_GVysctg5sY"),
    c("slides-tuning-trainvalidtest", "Training - Validation - Testing", "https://youtu.be/8LdpxLyH34c"),
    c("slides-tuning-nestedresampling", "Nested Resampling", "https://youtu.be/-d338rc076s")
)
colnames(linkdat) <- c("deck", "description", "youtube")


## Link data playlists

pldat <- rbind(
    c(1, "https://www.youtube.com/playlist?list=PLGViarxWrOJdvHGLGpJB5iZPlsC1V71H1"),
    c(2, "https://www.youtube.com/playlist?list=PLGViarxWrOJdiwHJy547DyBOejp3EJro0"),
    c(3, "https://www.youtube.com/playlist?list=PLGViarxWrOJc3tyUwneL5GiSkiDaWiA4m"),
    c(4, "https://www.youtube.com/playlist?list=PLGViarxWrOJeR02Di6ofPm6fMKTJVySUy"),
    c(5, "https://www.youtube.com/playlist?list=PLGViarxWrOJeTqM3tE2cAi7WJFBjW_frE"),
    c(6, "https://www.youtube.com/playlist?list=PLGViarxWrOJcVlBm2kclFeSIzItgLVRhb"),
    c(7, "https://www.youtube.com/playlist?list=PLGViarxWrOJeTk9zEUECXS7fDysIlo8Of")
)
colnames(pldat) <- c("dirorder", "playlist")


## Combine all data
sldat1 <- merge(sldat0, linkdat, by = "deck", all = TRUE)
sldat2 <- merge(sldat1, pldat, by = "dirorder", all = TRUE)
sldat <- sldat2[with(sldat2, order(dirorder, order)), ]


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
# nbviewer gives you a real PDF viewer, not the crappy render from github.....
sldat$PDF <- paste0("[pdf](https://nbviewer.jupyter.org/github/compstat-lmu/lecture_i2ml/blob/master/slides-pdf/", sldat$Deck, ".pdf)")
# sldat$PDF[is.na(sldat$Youtube)] <- "Coming soon"
sldat$YouTube <- paste0("[link](", sldat$Youtube, ") / [playlist ", sldat$Dirorder,"](", sldat$Playlist, ")")
sldat$YouTube[is.na(sldat$Youtube)] <- "Coming soon"

# Lesson ID
sldat$Lesson <- paste(sldat$Dirorder, sldat$Order, sep = ".")


# write.csv(sldat, "slide_data.csv")

