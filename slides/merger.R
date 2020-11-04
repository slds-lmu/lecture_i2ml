
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
  sof <- list.files(path = paste0("./", sd), pattern = "*-order.txt", full.names = TRUE)
  
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
sorted_dat <- sldat0[with(sldat0, order(dirorder, order)), c("dir", "deck")]

files <- paste(paste0(sorted_dat$dir,.Platform$file.sep ,sorted_dat$deck, ".pdf"), collapse = " ")
system(paste("gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile=finished.pdf", files))

       