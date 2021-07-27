EX = $(shell find -maxdepth 2 -type f \( -iname "ex_*.Rnw" -o -iname "sol_*.Rnw" -o -iname "collection_*.Rnw" \))
EXS = $(EX:%.Rnw=%.pdf)

all: texclean $(EXS) texclean move

$(EXS): %.pdf: %.Rnw
	Rscript -e 'setwd("$(dir $<)"); knitr::knit2pdf("$(notdir $<)")'

move: 
	find  -maxdepth 2 -type f \( -iname "ex_*.pdf" -o -iname "sol_*.pdf" \) -exec mv {}  ../exercises-pdf \; 

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
	rm -rf *.tex