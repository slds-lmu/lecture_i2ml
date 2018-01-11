all: d1 d2 d3 d4

d1: day1/exercise_1.pdf day1/solution_1.pdf
d2: day2/exercise_2.pdf day2/solution_2.pdf
d3: day3/exercise_3.pdf day3/solution_3.pdf
d4: day4/exercise_4.pdf day4/solution_4.pdf




day1/exercise_1.pdf: day1/*.Rnw
	Rscript --vanilla -e 'setwd("day1"); knitr::knit2pdf("exercise_1.Rnw")'
day1/solution_1.pdf: day1/*.Rnw
	Rscript --vanilla -e 'setwd("day1"); knitr::knit2pdf("solution_1.Rnw")'

day2/exercise_2.pdf: day2/*.Rnw
	Rscript --vanilla -e 'setwd("day2"); knitr::knit2pdf("exercise_2.Rnw")'
day2/solution_2.pdf: day2/*.Rnw
	Rscript --vanilla -e 'setwd("day2"); knitr::knit2pdf("solution_2.Rnw")'


day3/exercise_3.pdf: day3/*.Rnw
	Rscript --vanilla -e 'setwd("day3"); knitr::knit2pdf("exercise_3.Rnw")'
day3/solution_3.pdf: day3/*.Rnw
	Rscript --vanilla -e 'setwd("day3"); knitr::knit2pdf("solution_3.Rnw")'


day4/exercise_4.pdf: day4/*.Rnw
	Rscript --vanilla -e 'setwd("day4"); knitr::knit2pdf("exercise_4.Rnw")'
day4/solution_4.pdf: day4/*.Rnw
	Rscript --vanilla -e 'setwd("day4"); knitr::knit2pdf("solution_4.Rnw")'


