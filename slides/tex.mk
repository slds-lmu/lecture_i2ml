TSLIDES = $(shell find . -maxdepth 1 -iname "slides-*.tex")
TPDFS = $(TSLIDES:%.tex=%.pdf)
MARGINPDFS = $(TSLIDES:%.tex=%_withmargin.pdf)
FLSFILES = $(TSLIDES:%.tex=%.fls)

.PHONY: all most all-margin copy texclean clean

all: $(TPDFS) copy

all-margin: $(MARGINPDFS) copy

most: $(FLSFILES) 

$(TPDFS): %.pdf: %.tex
	-rm speakermargin.tex
	latexmk -pdf $<

$(MARGINPDFS): %_withmargin.pdf: %.tex
	touch speakermargin.tex
	latexmk -pdf -jobname=%A_withmargin $<

$(FLSFILES): %.fls: %.tex
	-rm speakermargin.tex
	latexmk -pdf -g $<

copy: | $(TPDFS) $(MARGINPDFS)
	cp *.pdf ../../slides-pdf
	
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
	-rm -rf speakermargin.tex
	
clean: texclean
	-rm $(TPDFS) $(MARGINPDFS) 2>/dev/null
