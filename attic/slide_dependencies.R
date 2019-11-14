library("tm")
library("igraph")
library("plyr")

## Get all slide Rnws
slidedir <- "../slides/"
rnws <- list.files(path = slidedir, pattern = "*.Rnw", recursive = TRUE)
nams <- gsub(pattern = "*/slides|.Rnw", replacement = "", x = rnws)

## Read all lines
all_txt <- lapply(paste0(slidedir, rnws), readLines)
names(all_txt) <- nams

## Find relevant lines
includes <- lapply(all_txt, function(x) grep("%! includes:*", x, value = TRUE))

## get relevant words
get_dependencies <- function(nam) {
    
    x <- includes[[nam]]
    
    ## remove %! includes:
    x <- gsub(pattern = "%! includes: ", replacement = "", x)
    
    ## split into single strings
    if (length(x) == 0) {
        dp <- NA 
    } else {
        dp <- unlist(strsplit(x = x, split = ", "))
        
        ## remove spaces
        dp <- gsub(pattern = " ", replacement = "", dp)
        
        ## get correct name
        dp <- sapply(dp, grep, x = nams, value = TRUE, USE.NAMES = FALSE)
    }
    
    data.frame(target = nam, depends = unlist(dp), stringsAsFactors = FALSE)
}

depends <- ldply(names(includes), get_dependencies)
dependencymat <- na.omit(depends)

dependencymat_simple <- dependencymat

simplify_dp <- function(x) {
    nams <- gsub(".*([^-]*-[^-]*)-*$", "\\1", x)
    gsub("-", "", nams)
}

dependencymat_simple$target <- simplify_dp(dependencymat_simple$target)
dependencymat_simple$depends <- simplify_dp(dependencymat_simple$depends)


## Create a dependency matrix (using igraph package)
graph_simple <- graph.data.frame(dependencymat_simple)
graph <- graph.data.frame(dependencymat)

## ... and plot
plot(graph, vertex.shape = "none", edge.arrow.size = 0.5)
plot(graph_simple, vertex.shape = "none", edge.arrow.size = 0.5)

