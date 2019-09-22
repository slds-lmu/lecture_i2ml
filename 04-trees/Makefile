
SLOT1=slides-cart1
SLOT2=slides-cart2
SLOT3=slides-forests1
SLOT4=slides-forests2
SLOT5=slides-forests2_rand_prox_2

#<<<<<<< improve-regression-tree-picture-#358
all: $(SLOT1).pdf $(SLOT2).pdf 	$(SLOT3).pdf $(SLOT4).pdf $(SLOT5).pdf

all_sources: sources $(SLOT1).pdf $(SLOT2).pdf 	$(SLOT3).pdf $(SLOT4).pdf $(SLOT5).pdf

#=======
#all_sources: sources all

#all: texclean $(SLOT1).pdf $(SLOT2).pdf 	$(SLOT3).pdf $(SLOT4).pdf
#>>>>>>> devel

$(SLOT1).pdf: $(SLOT1).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT1).Rnw")'

$(SLOT2).pdf: $(SLOT2).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT2).Rnw")'

$(SLOT3).pdf: $(SLOT3).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT3).Rnw")'

$(SLOT4).pdf: $(SLOT4).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT4).Rnw")'

#<<<<<<< improve-regression-tree-picture-#358
$(SLOT5).pdf: $(SLOT5).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT5).Rnw")'

#=======
#>>>>>>> devel
sources: 
	cd rsrc/; Rscript monotone_trafo.R # create two pictures monotone_trafo<1/2>.png used in cart2

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
