MATHRMD=latex-math.Rmd
MATHPDF=${MATHRMD:%.Rmd=%.pdf}

TEXFILES=$(shell find . -iname "basic-*tex" -o -iname "ml-*tex")

MATHCOMBINED=latex-math-combined.tex


.PHONY: all pdf combined help
all: $(MATHPDF) $(MATHCOMBINED)
pdf: $(MATHPDF)
combined: $(MATHCOMBINED)
help:
	@echo "Usage: make <target>:\n"
	@echo "  pdf:      render $(MATHRMD) to $(MATHPDF)"
	@echo "  combined: create the combined tex file $(MATHCOMBINED)"
	@echo "  clean:    remove $(MATHPDF) and $(MATHCOMBINED)"
	@echo "  all:      render $(MATHRMD) to $(MATHPDF) and create the combined tex file $(MATHCOMBINED)"
	@echo "  help:     show this message"

$(MATHPDF): $(MATHRMD) $(TEXFILES)
	@echo rendering $<;
	Rscript -e "rmarkdown::render('latex-math.Rmd')"

$(MATHCOMBINED): $(TEXFILES)
	@echo creating $@ from $(TEXFILES);
	Rscript --quiet create-latex-math-combined.R

.PHONY: clean
clean:
	@echo Removing $(MATHPDF) if it exists;
	latexmk -C
	test -f  $(MATHPDF) && rm  $(MATHPDF)
	test -f combined-latex-and-math.tex && rm combined-latex-and-math.tex
