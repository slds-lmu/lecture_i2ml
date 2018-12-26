
SLOT0=slides-notation
SLOT1=slides-intro
SLOT2=slides-tasks
SLOT3=slides-knn
SLOT4=slides-loss
SLOT5=slides-limo


all: $(SLOT0).pdf $(SLOT1).pdf $(SLOT2).pdf $(SLOT3).pdf $(SLOT4).pdf $(SLOT5).pdf

$(SLOT0).pdf: $(SLOT0).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT0).Rnw")'

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

# This would be way better:
# %.pdf: %.Rnw
# 	Rscript -e 'knitr::knit2pdf("$^")'

pdf: $(SLOT0).pdf $(SLOT1).pdf $(SLOT2).pdf $(SLOT3).pdf $(SLOT4).pdf $(SLOT5).pdf
	pdfunite $^ day1.pdf
