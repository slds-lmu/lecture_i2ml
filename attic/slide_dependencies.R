library("tidygraph")
library("ggraph")
library("purrr")

## Get all slide Rnws
slidedir <- "./slides/"
topics <- fs::dir_ls(path = slidedir, type = "directory")
slides <- map(topics, 
              ~ list.files(path = .x, pattern = "*.Rnw", full.names = TRUE))

get_includes <- function(slideset) {
    inc <- grep("%! includes:*", readLines(slideset), value = TRUE) 
    if (length(inc)) {
        slides <- gsub(pattern = "^slides-(.+)\\.Rnw$", 
                       replacement = "\\1", 
                       basename(slideset))
        data.frame(
            slides = slides,
            includes = process_includes(inc),
            stringsAsFactors = FALSE
        )
    }
}

## extract dependencies from include statement:
process_includes <- function(inc) {
    inc <- gsub(pattern = "%! includes: ", replacement = "", inc)
    deps <- unlist(strsplit(x = inc, split = ", "))
    ## split into single strings
    if (length(deps) == 0) {
        return(NA)
    }
    gsub(pattern = " ", replacement = "", deps)
}


includes <- map_depth(slides, 2, get_includes) %>% 
    map(~ discard(., is.null)) %>% 
    map(~ do.call(rbind, .)) %>% 
    discard(., is.null) %>% 
    imap(~ cbind(.x, 
                 topic = rep(basename(.y), nrow(.x)), 
                 stringsAsFactors = FALSE)) %>% 
    { 
        do.call(rbind, .) 
    }

includes$slides_short <- gsub("^[a-z]+-", "", includes$slides)
includes$includes_short <- gsub("^[a-z]+-", "", includes$includes)   

# check if all files define proper dependencies: 
# (should only contain basics-notation (?), eventually:)
setdiff(includes$includes, includes$slides)

# start with rare slides
slidenames <- names(sort(table(c(includes$slides, includes$includes))))
for (slide in slidenames) {
    longs <- which(includes$slides == slide)
    # get shorter name
    slide_short <- includes$slides_short[longs[1]]
    # if not all identical, replace with longer names
    shorts <- which(includes$slides_short == slide_short)
    if (!identical(longs, shorts)) {
        includes$slides_short[shorts] <- includes$slides[shorts]
        shorts <- which(includes$includes_short == slide_short)
        includes$includes_short[shorts] <- includes$includes[shorts]
    }
}

topics <- includes %>% select(topic, slides) %>% 
    filter(!duplicated(slides)) %>% rename(name = "slides")
topics_short <- includes %>% select(topic, slides_short) %>% 
    filter(!duplicated(slides_short)) %>% rename(name = "slides_short")

graph <- includes %>% select(slides, includes) %>% as_tbl_graph() %>% 
    left_join(topics)
graph_short <- includes %>% select(c("slides_short", "includes_short")) %>% 
    as_tbl_graph() %>% 
    left_join(topics_short)

#sugiyama layout seems useful to group the topics:
topic_layers <- graph_short %>% pull(topic) %>% factor %>% as.numeric
topic_layers[is.na(topic_layers)] <- max(topic_layers) + 1
graph_short %>%  
    ggraph(layout = 'sugiyama', layers = topic_layers) + 
    geom_edge_fan0(
        arrow = grid::arrow(angle = 10, length = unit(.2, "inches"))) + 
    geom_node_point(aes(col = topic)) + 
    geom_node_text(aes(label = name, col = topic), repel = TRUE, 
                   show.legend = FALSE)

# other ideas: maybe weigh up edges within the same topic to force other layout
# algs to keep topics closer together?
set.seed(1211)
graph_short %>%  
    ggraph(layout = 'gem') + 
    geom_edge_fan0(
        arrow = grid::arrow(angle = 10, length = unit(.2, "inches"))) + 
    geom_node_point(aes(col = topic)) + 
    geom_node_text(aes(label = name, col = topic), repel = TRUE, 
                   show.legend = FALSE)
