all: day1-slot1-intro.pdf day1-slot2-knn.pdf 	day1-slot3-loss.pdf day1-slot4-limo.pdf day1-notation.pdf

day1-slot1-intro.pdf: day1-slot1-intro.Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("day1-slot1-intro.Rnw")'

day1-slot2-knn.pdf: day1-slot2-knn.Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("day1-slot2-knn.Rnw")'

day1-slot3-loss.pdf: day1-slot3-loss.Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("day1-slot3-loss.Rnw")'

day1-slot4-limo.pdf: day1-slot4-limo.Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("day1-slot4-limo.Rnw")'

day1-notation.pdf: day1-notation.Rnw
	Rscript --vanilla -e 'knitr::knit2pdf("day1-notation.Rnw")'
