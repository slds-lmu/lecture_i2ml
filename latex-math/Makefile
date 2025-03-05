MATHRMD=latex-math.Rmd
MATHPDF=${MATHRMD:%.Rmd=%.pdf}

TEXFILES=$(shell find . -iname "basic-*tex" -o -iname "ml-*tex")

MATHCOMBINED=combined.tex
MATHCOMBINEDQMD=${MATHCOMBINED:%.tex=%.qmd}


.PHONY: all pdf combined help
all: clean $(MATHPDF) $(MATHCOMBINED)
pdf: $(MATHPDF)
combined: $(MATHCOMBINED) $(MATHCOMBINEDQMD)
help:
	@echo "Usage: make <target>:\n"
	@echo "  pdf:      render $(MATHRMD) to $(MATHPDF). Triggers 'combined' to create $(MATHCOMBINED)"
	@echo "  combined: create the combined tex file $(MATHCOMBINED) and $(MATHCOMBINEDQMD)"
	@echo "  clean:    remove $(MATHPDF) and $(MATHCOMBINED)"
	@echo "  all:      clean + pdf + combined"
	@echo "  help:     show this message"

$(MATHPDF): $(MATHRMD) $(TEXFILES) $(MATHCOMBINED)
	@echo rendering $<;
	Rscript -e "rmarkdown::render('latex-math.Rmd')"

$(MATHCOMBINED): $(TEXFILES)
	@echo creating $@ from $(TEXFILES);
	Rscript --quiet create-latex-math-combined.R

.SILENT: clean
.PHONY: clean
clean:
	@echo Cleaning up;
	latexmk -C > /dev/null 2>&1
	test -f  $(MATHPDF) && rm $(MATHPDF) || true
	test -f $(MATHCOMBINED) && rm $(MATHCOMBINED) || true
	test -f $(MATHCOMBINEDQMD) && rm $(MATHCOMBINEDQMD) || true
