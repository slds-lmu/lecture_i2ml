src = $(shell ls slides-*.Rnw)
slides = $(src:%.Rnw=%.pdf)

all: texclean $(slides) 

$(slides): %.pdf: %.Rnw
	Rscript -e 'knitr::knit2pdf("$<")'

texclean: 
	rm -rf *.out
	rm -rf *.dvi
	rm -rf *.log
	rm -rf *.aux
	rm -rf *.bbl
	rm -rf *.blg
	rm -rf *.ind
	rm -rf *.idx
	rm -rf *.ilg
	rm -rf *.lof
	rm -rf *.lot
	rm -rf *.toc
	rm -rf *.nav
	rm -rf *.snm
	rm -rf *.vrb
	rm -rf *.synctex.gz
	rm -rf *-concordance.tex
