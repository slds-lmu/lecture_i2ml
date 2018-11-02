
SLOT1=slides-d1s1-intro
SLOT2=slides-d1s2-tasks
SLOT3=slides-d1s3-knn
SLOT4=slides-d1s4-loss
SLOT5=slides-d1s5-limo


all: $(SLOT1).pdf $(SLOT2).pdf 	$(SLOT3).pdf $(SLOT4).pdf $(SLOT5).pdf slides-notation.pdf

$(SLOT1).pdf: $(SLOT1).Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("$(SLOT1).Rnw")'

$(SLOT2).pdf: $(SLOT2).Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("$(SLOT2).Rnw")'

$(SLOT3).pdf: $(SLOT3).Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("$(SLOT3).Rnw")'

$(SLOT4).pdf: $(SLOT4).Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("$(SLOT4).Rnw")'

$(SLOT5).pdf: $(SLOT5).Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("$(SLOT5).Rnw")'

slides-notation.pdf: slides-notation.Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("slides-notation.Rnw")'
