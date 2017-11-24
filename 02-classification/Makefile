
SLOT1=slides-d2s1-classification
SLOT2=slides-d2s2-logistic
SLOT3=slides-d2s3-classification-approaches
SLOT4=slides-d2s4-cultures

all: $(SLOT1).pdf $(SLOT2).pdf 	$(SLOT3).pdf $(SLOT4).pdf

$(SLOT1).pdf: $(SLOT1).Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("$(SLOT1).Rnw")'

$(SLOT2).pdf: $(SLOT2).Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("$(SLOT2).Rnw")'

$(SLOT3).pdf: $(SLOT3).Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("$(SLOT3).Rnw")'

$(SLOT4).pdf: $(SLOT4).Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("$(SLOT4).Rnw")'
