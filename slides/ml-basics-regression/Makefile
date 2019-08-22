
SLOT1=slides-basics-definition
SLOT2=slides-basics-notation
SLOT3=slides-basics-learners
SLOT4=slides-basics-supervised
SLOT5=slides-basics-regressionlosses
SLOT6=slides-basics-riskminimization
SLOT7=slides-basics-linearregression
SLOT8=slides-basics-polynomialregression
SLOT9=slides-basics-knnregression
SLOT10=slides-basics-mlontology

all: texclean $(SLOT1).pdf $(SLOT2).pdf $(SLOT3).pdf $(SLOT4).pdf $(SLOT5).pdf $(SLOT6).pdf $(SLOT7).pdf $(SLOT8).pdf $(SLOT9).pdf $(SLOT10).pdf 

$(SLOT1).pdf: $(SLOT1).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT1).Rnw")'

$(SLOT2).pdf: $(SLOT2).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT2).Rnw")'

$(SLOT3).pdf: $(SLOT3).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT3).Rnw")'

$(SLOT4).pdf: $(SLOT4).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT4).Rnw")'

$(SLOT5).pdf: $(SLOT5).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT5).Rnw")'

$(SLOT6).pdf: $(SLOT6).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT6).Rnw")'

$(SLOT7).pdf: $(SLOT7).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT7).Rnw")'

$(SLOT8).pdf: $(SLOT8).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT8).Rnw")'

$(SLOT9).pdf: $(SLOT9).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT9).Rnw")'

$(SLOT10).pdf: $(SLOT10).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT10).Rnw")'

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
