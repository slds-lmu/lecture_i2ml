
SLOT1=slides-d4s1-cart1
SLOT2=slides-d4s2-cart2
SLOT3=slides-d4s3-forests1
SLOT4=slides-d4s4-forests2

all: $(SLOT1).pdf $(SLOT2).pdf 	$(SLOT3).pdf $(SLOT4).pdf

$(SLOT1).pdf: $(SLOT1).Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("$(SLOT1).Rnw")'

$(SLOT2).pdf: $(SLOT2).Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("$(SLOT2).Rnw")'

$(SLOT3).pdf: $(SLOT3).Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("$(SLOT3).Rnw")'

$(SLOT4).pdf: $(SLOT4).Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("$(SLOT4).Rnw")'
