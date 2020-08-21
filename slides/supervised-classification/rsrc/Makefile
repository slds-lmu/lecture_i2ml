FIGS = $(shell find . -maxdepth 1 -iname "fig-*.R" -printf "%f\n")
PDFS = $(FIGS:%.R=../figure/%.pdf)

all: $(PDFS) 

$(PDFS): ../figure/%.pdf: %.R
	Rscript $<