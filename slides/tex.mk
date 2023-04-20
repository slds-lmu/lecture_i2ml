TSLIDES = $(shell find . -maxdepth 1 -iname "slides-*.tex")
TPDFS = $(TSLIDES:%.tex=%.pdf)
FLSFILES = $(TSLIDES:%.tex=%.fls)
TDIR = $(shell pwd)

.PHONY: all most copy texclean clean

all: clean texclean handlemargin $(TPDFS) rmmargin copy texclean

most: handlemargin $(FLSFILES) rmmargin

$(TPDFS): %.pdf: %.tex
	latexmk -pdf $<

$(FLSFILES): %.fls: %.tex
	latexmk -pdf -g $<

copy: 
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
	
clean: texclean
	-rm $(TPDFS) 2>/dev/null || true
	
handlemargin: 
  ifeq (nomargin, $(filter nomargin,$(MAKECMDGOALS)))
		touch $(TDIR)/nospeakermargin.tex
  endif
  
rmmargin:
  ifeq (nomargin, $(filter nomargin,$(MAKECMDGOALS)))
		rm $(TDIR)/nospeakermargin.tex
  endif 
