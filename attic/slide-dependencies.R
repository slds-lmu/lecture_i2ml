library("tidygraph")
library("ggraph")
library("purrr")
library("fs")

## Get all slide Rnws
slidedir <- "../slides/"
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

# check if files define unknown dependencies: 
# (should only contain basics-notation (?), eventually:)
undefined_deps <- filter(includes, 
       includes %in% setdiff(includes, c(slides, "basics-notation")))
if (nrow(undefined_deps)) {
    stop("following slides define unknown dependencies:")
    print(undefined_deps[, c("slides", "includes")])
}    


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

# topic_order <- c("ml-basics", 
#                  "supervised-regression",
#                  "supervised-classification",
#                  "evaluation",
#                  "trees",
#                  "forests",
#                  "tuning")

graph_short <- includes %>% select(c("slides_short", "includes_short")) %>% 
    as_tbl_graph() %>% 
    left_join(topics_short) %>% 
    mutate(dependencies = centrality_degree(mode = 'out'),
           inclusions = centrality_degree(mode = 'in')) %>% 
    filter(!is.na(topic)) %>%  #drop notation...
    # mutate(topic = ordered(topic, levels = topic_order)) %>%  # coloring not working for ordered
    activate(edges) %>% 
    reroute(from = to, to = from) %>%  #more natural direction of arrow...
    mutate(from_topic = .N()$topic[from])
    #ordered(.N()$topic[from], levels = topic_order))  # coloring not working for ordered

p <- ggraph(graph_short, layout = 'linear', circular = TRUE) + 
    geom_node_point(aes(colour = topic, size = inclusions), 
                    alpha = .5, show.legend = FALSE) + 
    geom_edge_arc(
        aes(colour = from_topic), alpha = .5, show.legend = FALSE,
        arrow = grid::arrow(angle = 8, length = unit(.2, "inches"))) +
    geom_node_text(aes(label = name, colour = topic), repel = TRUE) +
    ggtitle(
         label = 'Dependencies between slide sets, by topic (approximate...)') +
    theme(legend.position = 'bottom')

p 
ggsave("slide-dependencies.pdf", width = 9, height = 9)

#     #sugiyama layout may be useful to group topics:
#     topic_layers <- graph_short %>% pull(topic) %>% factor %>% as.numeric
#     topic_layers[is.na(topic_layers)] <- max(topic_layers) + 1
#     graph_short %>%  
#         ggraph(layout = 'sugiyama', layers = topic_layers) + 
#         geom_edge_fan0(
#             arrow = grid::arrow(angle = 10, length = unit(.2, "inches"))) + 
#         geom_node_point(aes(col = topic)) + 
#         geom_node_text(aes(label = name, col = topic), repel = TRUE, 
#                        show.legend = FALSE)
#     
#     #very clean, but does not show connections within topic...
#     graph_short %>% filter(!is.na(topic)) %>% 
#         ggraph(layout = 'hive', axis = topic, sort.by = inclusions) + 
#         geom_node_point(aes(col = topic)) + 
#         geom_edge_hive(
#             strength = 1,
#             arrow = grid::arrow(angle = 8, length = unit(.1, "inches"))) +
#         geom_node_text(aes(label = name, col = topic), repel = TRUE, 
#                        show.legend = FALSE)
#     
#     # not working, for some reason...?
#     from <- (graph_short %N>% pull(name))[graph_short %E>% pull(from)]
#     to <- (graph_short %N>% pull(name))[graph_short %E>% pull(to)]
#     graph_short %>% 
#         ggraph(layout = 'linear', circular = TRUE) + 
#         geom_node_point(aes(colour = topic, size = dependencies)) + 
#         geom_conn_bundle(data = get_con(from = from, to = to)) +
#         coord_fixed()
