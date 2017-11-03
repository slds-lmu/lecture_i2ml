all: slides.pdf

slides.pdf: slides.Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("slides.Rnw")'
