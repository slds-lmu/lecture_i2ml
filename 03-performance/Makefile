
SLOT1=slides-intro-performance
SLOT2=slides-resampling
SLOT3=slides-nested-resampling
SLOT4=slides-roc-confusion

#rsrc1=rsrc/compare-cv-example.R        # create compare-cv-example.jpg (not used)
rsrc2=rsrc/holdout-biasvar.R           # create holdout-bias-var.png (not used) and holdout-biasvar.RData (used in intro-performance and resampling)
rsrc3=rsrc/learning_curve.R            # create learning_curve.RData (used in resampling)
#rsrc4=rsrc/nested-resample-example.R   # create nested-resample-example.RData (not used)
rsrc5=rsrc/overtuning-example.R        # create overtuning-example.RData (used in nested-resampling)
#rsrc6=rsrc/testerror_confint.R         # no output



all: $(SLOT1).pdf $(SLOT2).pdf $(SLOT3).pdf $(SLOT4).pdf

sources: rsrc_2 rsrc_3 rsrc_5 

all_sources:rsrc_2 rsrc_3 rsrc_5 $(SLOT1).pdf $(SLOT2).pdf $(SLOT3).pdf $(SLOT4).pdf 


$(SLOT1).pdf: $(SLOT1).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT1).Rnw")'

$(SLOT2).pdf: $(SLOT2).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT2).Rnw")'

$(SLOT3).pdf: $(SLOT3).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT3).Rnw")'

$(SLOT4).pdf: $(SLOT4).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT4).Rnw")'



rsrc_2: $(rsrc2)
	Rscript $(rsrc2)

rsrc_3: $(rsrc3)
	Rscript $(rsrc3)

rsrc_5: $(rsrc5)
	Rscript $(rsrc5)













