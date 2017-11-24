
SLOT1=slides-d1s1-intro
SLOT2=slides-d1s2-knn
SLOT3=slides-d1s3-loss
SLOT4=slides-d1s4-limo


all: $(SLOT1).pdf $(SLOT2).pdf 	$(SLOT3).pdf $(SLOT4).pdf slides-notation.pdf

$(SLOT1).pdf: $(SLOT1).Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("$(SLOT1).Rnw")'

$(SLOT2).pdf: $(SLOT2).Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("$(SLOT2).Rnw")'

$(SLOT3).pdf: $(SLOT3).Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("$(SLOT3).Rnw")'

$(SLOT4).pdf: $(SLOT4).Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("$(SLOT4).Rnw")'

slides-notation.pdf: slides-notation.Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("slides-notation.Rnw")'
