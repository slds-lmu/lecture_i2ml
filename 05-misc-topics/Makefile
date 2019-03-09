SLOT1=slides-tuning
SLOT2=slides-nested-resampling

all: $(SLOT1).pdf $(SLOT2).pdf 

all_sources: sources $(SLOT1).pdf $(SLOT2).pdf 

$(SLOT1).pdf: $(SLOT1).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT1).Rnw")'

$(SLOT2).pdf: $(SLOT2).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT2).Rnw")'

sources: 
	cd rsrc/; Rscript overtuning-example.R  # create overtuning-example.RData (used in nested-resampling)
