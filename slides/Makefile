SLIDES = $(shell find . -maxdepth 2 -iname "slides-*.Rnw")
PDFS = $(SLIDES:%.Rnw=%.pdf)

all: texclean $(PDFS) slide-dependencies.pdf

$(PDFS): %.pdf: %.Rnw
	Rscript -e 'setwd("$(dir $<)"); knitr::knit2pdf("$(notdir $<)")'

texclean: 
	rm -rf *.out
	rm -rf *.dvi
	rm -rf *.log
	rm -rf *.aux
	rm -rf *.bbl
	rm -rf *.blg
	rm -rf *.ind
	rm -rf *.idx
	rm -rf *.ilg
	rm -rf *.lof
	rm -rf *.lot
	rm -rf *.toc
	rm -rf *.nav
	rm -rf *.snm
	rm -rf *.vrb
	rm -rf *.synctex.gz
	rm -rf *-concordance.tex

slide-dependencies.pdf: $(SLIDES) ../attic/slide_dependencies.R
	Rscript -e 'source("../attic/slide_dependencies.R")'

.PHONY: copypdfs

copypdfs: all
	cp $(PDFS) ../slides-pdf/
