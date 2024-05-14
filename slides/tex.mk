# Slide .tex files, relative paths
TSLIDES = $(shell find . -maxdepth 1 -iname "slides*.tex")
# Substitute file extension tex -> pdf for output pdf filenames
TPDFS = $(TSLIDES:%.tex=%.pdf)
# Substitute file extension tex -> pdf for output pdf filenames
TPAXS = $(TSLIDES:%.tex=%.pax)
# output pdf filenames for slides without margin (old 4:3 layout)
NOMARGINPDFS = $(TSLIDES:%.tex=%-nomargin.pdf)

FLSFILES = $(TSLIDES:%.tex=%.fls)

.PHONY: all most all-nomargin most-nomargin copy texclean clean help pax

help:
	@echo "\n --- Rendering slides"
	@echo "all                : Renders slides to PDF and runs texclean + copy (see below)"
	@echo "most               : Renders slides to PDF, does not copy or clean"
	@echo "all-normargin      : Same as all, but renders 4:3 slides with -nomargin.pdf suffix"
	@echo "most-normargin     : Same as most, analogous to all-normagin"
	@echo "\n --- Cleaning up"
	@echo "texclean           : Deletes all LaTeX detrituts (.log, .aux, .nav, .synctex, ...)"
	@echo "clean              : Runs texclean and deletes all rendered slides"
	@echo "\n --- Copying to /slides-pdf/ (!! Linked from course website !!)"
	@echo "copy               : Copies PDF files to /slides-pdf/"
	@echo "slides-pdf         : Runs texclean, renders slides, copies to /slides-pdf/, and texclean again"
	@echo "\n --- Utilities"
	@echo "pax                : Runs pdfannotextractor.pl (pax) to store hyperlinks etc. in .pax files for later use"

# Default action compiles without margin and copies to slides-pdf!
all: $(TPDFS)
	@if [ -d "../../latex-math" ]; then\
		$(MAKE) texclean;\
		$(MAKE) copy;\
	else\
		echo "Cannot find 'latex-math' in root directory";\
	fi
# derivative action does the same for slides without margin (different filenames!)
all-nomargin: $(NOMARGINPDFS)
	$(MAKE) copy

# Analogously the same but without copying (arguably should be the default actions)
most: $(FLSFILES)
most-nomargin: $(NOMARGINPDFS)

slides-pdf:
	@if [ -d "../../latex-math" ]; then\
		make texclean;\
		make $(TPDFS);\
		make copy;\
		make texclean;\
	else\
		echo "Cannot find 'latex-math' in root directory";\
	fi

# Conditionally remove or create empty nospeakermargin.tex file to decide which layout to use
# See /style/lmu-lecture.sty -- it's a whole thing but does the job.
$(TPDFS): %.pdf: %.tex
	-rm nospeakermargin.tex
	@echo render $<;
	latexmk -halt-on-error -pdf $<

$(NOMARGINPDFS): %-nomargin.pdf: %.tex
	touch nospeakermargin.tex
	latexmk -halt-on-error -pdf -jobname=%A-nomargin $<

$(FLSFILES): %.fls: %.tex
	-rm nospeakermargin.tex
	latexmk -halt-on-error -pdf -g $<

copy:
	cp -u *.pdf ../../slides-pdf
	cp -u *.pax ../../slides-pdf

# Extract pdf annotations, i.e. hyperlinks, for later reinsertion
# When combining multiple PDFs into one (for slides/all/)
# https://ctan.org/tex-archive/macros/latex/contrib/pax?lang=en
# Depending on installation linked script in PATH does not have file extension
pax:
	@if command -v pdfannotextractor.pl &> /dev/null; then\
		echo "Found pdfannotextractor.pl";\
		pdfannotextractor.pl *.pdf;\
	elif command -v pdfannotextractor &> /dev/null; then\
		echo "Found pdfannotextractor";\
		pdfannotextractor *.pdf;\
	else\
		echo "Did not find pdfannotextractor, install 'pax' with tlmgr";\
	fi

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
	-rm -rf *.pax
	-rm -rf *.fdb_latexmk
	-rm -rf *.synctex.gz
	-rm -rf *-concordance.tex
	-rm -rf nospeakermargin.tex

clean: texclean
	-rm $(TPDFS) $(NOMARGINPDFS) $(TPAXS) 2>/dev/null
