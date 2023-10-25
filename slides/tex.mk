# Slide .tex files, relative paths
TSLIDES = $(shell find . -maxdepth 1 -iname "slides-*.tex")
# Substitute file extension tex -> pdf for output pdf filenames
TPDFS = $(TSLIDES:%.tex=%.pdf)
# output pdf filenames for slides without margin (old 4:3 layout)
NOMARGINPDFS = $(TSLIDES:%.tex=%-nomargin.pdf)

FLSFILES = $(TSLIDES:%.tex=%.fls)

.PHONY: all most all-nomargin copy texclean clean

# Default action compiles without margin and copies to slides-pdf!
all: $(TPDFS)
	$(MAKE) copy

# derivative action does the same for slides without margin (different filenames!)
all-nomargin: $(NOMARGINPDFS)
	$(MAKE) copy

# Analogously the same but without copying (arguably should be the default actions)
most: $(FLSFILES)
most-nomargin: $(NOMARGINPDFS)

# Conditionally remove or create empty nospeakermargin.tex file to decide which layout to use
# See /style/lmu-lecture.sty -- it's a whole thing but does the job.
$(TPDFS): %.pdf: %.tex
	-rm nospeakermargin.tex
	latexmk -pdf $<

$(NOMARGINPDFS): %-nomargin.pdf: %.tex
	touch nospeakermargin.tex
	latexmk -pdf -jobname=%A-nomargin $<

$(FLSFILES): %.fls: %.tex
	-rm nospeakermargin.tex
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
	-rm -rf nospeakermargin.tex

clean: texclean
	-rm $(TPDFS) $(NOMARGINPDFS) 2>/dev/null
