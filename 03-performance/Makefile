
SLOT1=slides-intro-performance
SLOT2=slides-resampling
SLOT3=slides-roc-confusion
SLOT4=slides-overfitting


all: $(SLOT1).pdf $(SLOT2).pdf $(SLOT3).pdf $(SLOT4).pdf

all_sources: sources $(SLOT1).pdf $(SLOT2).pdf $(SLOT3).pdf $(SLOT4).pdf


$(SLOT1).pdf: $(SLOT1).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT1).Rnw")'

$(SLOT2).pdf: $(SLOT2).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT2).Rnw")'

$(SLOT3).pdf: $(SLOT3).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT3).Rnw")'

$(SLOT4).pdf: $(SLOT4).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT4).Rnw")'

sources: 
	cd rsrc/; Rscript holdout-biasvar.R  # create holdout-bias-var.png (not used) and holdout-biasvar.RData (used in intro-performance and resampling)
	cd rsrc/; Rscript learning_curve.R  # create learning_curve.RData (used in resampling)













