SLOT1=slides-tuning
SLOT2=slides-nested-resampling
SLOT3=slides-practical

all: $(SLOT1).pdf $(SLOT2).pdf $(SLOT3).pdf 

all_sources: sources $(SLOT1).pdf $(SLOT2).pdf $(SLOT3).pdf

$(SLOT1).pdf: $(SLOT1).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT1).Rnw")'

$(SLOT2).pdf: $(SLOT2).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT2).Rnw")'

$(SLOT3).pdf: $(SLOT3).Rnw
	Rscript -e 'knitr::knit2pdf("$(SLOT3).Rnw")'
	
sources: 
	cd rsrc/; Rscript overtuning-example.R  # create overtuning-example.RData (used in nested-resampling)
