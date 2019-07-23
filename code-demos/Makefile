SLOT1=code_demo_limo
SLOT2=code_demo_knn
SLOT3=code_demo_splines

all_sources: sources all

all: texclean $(SLOT1).pdf $(SLOT2).pdf $(SLOT3).pdf

$(SLOT1).pdf: $(SLOT1).Rmd
	Rscript -e 'rmarkdown::render("$(SLOT1).Rmd", "pdf_document")'

$(SLOT2).pdf: $(SLOT2).Rmd
	Rscript -e 'rmarkdown::render("$(SLOT2).Rmd", "pdf_document")'

$(SLOT3).pdf: $(SLOT3).Rmd
	Rscript -e 'rmarkdown::render("$(SLOT3).Rmd", "pdf_document")'

sources:
	cd ../03-performance/rsrc/; Rscript holdout-biasvar.R  # create holdout-bias-var.png (not used) and holdout-biasvar.RData (used in intro-performance and resampling)

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
