TSLIDES = $(shell find . -maxdepth 1 -iname "slides-*.tex")
TPDFS = $(TSLIDES:%.tex=%.pdf)
FLSFILES = $(TSLIDES:%.tex=%.fls)

.PHONY: all most copy texclean clean

all: texclean $(TPDFS) copy texclean

most: $(FLSFILES)

$(TPDFS): %.pdf: %.tex
	latexmk -pdf $<

$(FLSFILES): %.fls: %.tex
	latexmk -pdf -g $<

copy: 
	cp *.pdf ../../slides-pdf
	
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
	rm -rf *.fls
	rm -rf *.fdb_latexmk
	rm -rf *.synctex.gz
	rm -rf *-concordance.tex
	
clean: texclean
	-rm $(TPDFS) 2>/dev/null || true
