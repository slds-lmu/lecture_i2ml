library("tm")
library("igraph")
library("plyr")

## Get all slide Rnws
slidedir <- "./slides/"
topics <- fs::dir_ls(path = slidedir, type = "directory")
slides <- purrr::map(topics, 
                     ~ list.files(path = .x, pattern = "*.Rnw", full.names = TRUE))

## get includes
get_dependencies <- function(slideset) {
    inc <- grep("%! includes:*", readLines(slideset), value = TRUE) 
    if (length(inc)) {
        slides <- gsub(pattern = "^slides-(.+)\\.Rnw$", 
                       replacement = "\\1", 
                       basename(slideset))
        data.frame(
            slides = slides,
            includes = included_dependencies(inc),
            stringsAsFactors = FALSE
        )
    }
}

## get dependencies from include statement
included_dependencies <- function(inc) {
    inc <- gsub(pattern = "%! includes: ", replacement = "", inc)
    deps <- unlist(strsplit(x = inc, split = ", "))
    ## split into single strings
    if (length(deps) == 0) {
        return(NA)
    }
    gsub(pattern = " ", replacement = "", deps)
}


includes <- purrr::map_depth(slides, 2, get_dependencies) %>% 
    purrr::map(~ purrr::discard(., is.null)) %>% 
    purrr::map(~ do.call(rbind, .)) %>% 
    purrr::discard(., is.null) %>% 
    purrr::imap(~ cbind(.x, topic = basename(.y), 
                        stringsAsFactors = FALSE)) %>% 
    { 
        do.call(rbind, .) 
    }

includes$slides_short <- gsub("^[a-z]+-", "", includes$slides)
includes$includes_short <- gsub("^[a-z]+-", "", includes$includes)   
with(includes) {
    for (slide in unique(slides)) {
        slide_short <- slides_short[[]] # ?!?!?!
    }
}


# 
# depends <- ldply(names(includes), get_dependencies)
# dependencymat <- na.omit(depends)
# 
# dependencymat_simple <- dependencymat
# 
# simplify_dp <- function(x) {
#     nams <- gsub(".*([^-]*-[^-]*)-*$", "\\1", x)
#     gsub("-", "", nams)
# }
# 
# dependencymat_simple$target <- simplify_dp(dependencymat_simple$target)
# dependencymat_simple$depends <- simplify_dp(dependencymat_simple$depends)
# 
# 
# ## Create a dependency matrix (using igraph package)
# graph_simple <- graph.data.frame(dependencymat_simple)
# graph <- graph.data.frame(dependencymat)
# 
# ## ... and plot
# plot(graph, vertex.shape = "none", edge.arrow.size = 0.1)
# plot(graph_simple, vertex.shape = "none", edge.arrow.size = 0.1)
# plot(graph_simple, vertex.shape = "none", edge.arrow.size = 0.1, 
#      layout = layout_with_sugiyama(graph_simple)$)
