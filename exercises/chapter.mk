# Slide .tex files, relative paths
EX = $(shell find . -maxdepth 1 -type f \( -iname "ex_*.Rnw" -o -iname "sol_*.Rnw" -o -iname "ic_*.Rnw" -o -iname "collection_*.Rnw" \))
# Substitute file extension Rnw -> pdf for output pdf filenames
EXPDFS = $(EX:%.Rnw=%.pdf)
	
FLSFILES = $(TSLIDES:%.Rnw=%.fls)

.PHONY: all most copy texclean clean

all: $(EXPDFS)
	$(MAKE) copy-all
	
most: $(EXPDFS)

$(EXPDFS): %.pdf: %.Rnw
	Rscript -e 'setwd("$(dir $<)"); knitr::knit2pdf("$(notdir $<)")'

copy: $(F)
	cp $(F) ../../exercises-pdf

copy-all:
	cp *.pdf ../../exercises-pdf
	
texclean: 
	-rm -rf *.out
	-rm -rf *.dvi
	-rm -rf *.log
	-rm -rf *.aux
	-rm -rf *.bbl
	-rm -rf *.blg
	-rm -rf *.ind
	-rm -rf *.idx
	-rm -rf *.ilg
	-rm -rf *.lof
	-rm -rf *.lot
	-rm -rf *.toc
	-rm -rf *.nav
	-rm -rf *.snm
	-rm -rf *.vrb
	-rm -rf *.fls
	-rm -rf *.fdb_latexmk
	-rm -rf *.synctex.gz
	-rm -rf *-concordance.tex
	-rm -rf *.tex
	
clean: texclean
	-rm $(EXPDFS) 2>/dev/null
