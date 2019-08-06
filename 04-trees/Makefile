
SLOT1=slides-cart1
SLOT2=slides-cart2
SLOT3=slides-forests1
SLOT4=slides-forests2
SLOT5=slides-forests2_rand_prox_2

all: $(SLOT1).pdf $(SLOT2).pdf 	$(SLOT3).pdf $(SLOT4).pdf $(SLOT5).pdf

all_sources: sources $(SLOT1).pdf $(SLOT2).pdf 	$(SLOT3).pdf $(SLOT4).pdf $(SLOT5).pdf


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

sources: 
	cd rsrc/; Rscript monotone_trafo.R # create two pictures monotone_trafo<1/2>.png used in cart2
