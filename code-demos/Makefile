SLOT1=code_demo_limo
SLOT2=code_demo_knn
SLOT3=code_demo_splines
SLOT4=code_demo_logreg
SLOT5=code_demo_cmpclass
SLOT6=code_demo_genclass


all_sources: sources all

all: texclean $(SLOT1).pdf $(SLOT2).pdf $(SLOT3).pdf $(SLOT4).pdf $(SLOT5).pdf $(SLOT6).pdf 

$(SLOT1).pdf: $(SLOT1).Rmd
	Rscript -e 'rmarkdown::render("$(SLOT1).Rmd", "pdf_document")'

$(SLOT2).pdf: $(SLOT2).Rmd
	Rscript -e 'rmarkdown::render("$(SLOT2).Rmd", "pdf_document")'

$(SLOT3).pdf: $(SLOT3).Rmd
	Rscript -e 'rmarkdown::render("$(SLOT3).Rmd", "pdf_document")'

$(SLOT4).pdf: $(SLOT4).Rmd
	Rscript -e 'rmarkdown::render("$(SLOT4).Rmd", "pdf_document")'

$(SLOT5).pdf: $(SLOT5).Rmd
	Rscript -e 'rmarkdown::render("$(SLOT5).Rmd", "pdf_document")'

$(SLOT6).pdf: $(SLOT6).Rmd
	Rscript -e 'rmarkdown::render("$(SLOT6).Rmd", "pdf_document")'

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
