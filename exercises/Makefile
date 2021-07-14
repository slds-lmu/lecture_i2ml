all: ch1 ch2 ch3 ch4 ch5 ch6 ch7

ch1: ml-basics/ex_ml-basics.pdf ml-basics/sol_ml-basics.pdf ml-basics
ch2: supervised-regression/ex_regression.pdf supervised-regression/sol_regression.pdf 
ch3: supervised-classification/ex_classification_1.pdf supervised-classification/sol_classification_1.pdf supervised-classification/ex_classification_2.pdf supervised-classification/sol_classification_2.pdf 
ch4: evaluation/ex_eval_1.pdf evaluation/sol_eval_1.pdf evaluation/ex_eval_2.pdf evaluation/sol_eval_2.pdf
ch5: trees/ex_trees.pdf trees/sol_trees.pdf
ch6: forests/ex_forests.pdf forests/sol_forests.pdf
ch7: tuning-resampling/ex_tuning_resampling.pdf tuning-resampling/sol_tuning_resampling.pdf

ml-basics/ex_ml-basics.pdf: ml-basics/*.Rnw
		Rscript -e 'setwd("ml-basics"); knitr::knit2pdf("ex_ml-basics.Rnw")'
  
ml-basics/sol_ml-basics.pdf: ml-basics/*.Rnw
		Rscript -e 'setwd("ml-basics"); knitr::knit2pdf("sol_ml-basics.Rnw")' 
  
supervised-regression/ex_regression.pdf: supervised-regression/*.Rnw
		Rscript -e 'setwd("supervised-regression"); knitr::knit2pdf("ex_regression.Rnw")'
  
supervised-regression/sol_regression.pdf: supervised-regression/*.Rnw
		Rscript -e 'setwd("supervised-regression"); knitr::knit2pdf("sol_regression.Rnw")' 
  
supervised-classification/ex_classification_1.pdf: supervised-classification/*.Rnw
		Rscript -e 'setwd("supervised-classification"); knitr::knit2pdf("ex_classification_1.Rnw")'
  
supervised-classification/sol_classification_1.pdf: supervised-classification/*.Rnw
		Rscript -e 'setwd("supervised-classification"); knitr::knit2pdf("sol_classification_1.Rnw")' 
  
supervised-classification/ex_classification_2.pdf: supervised-classification/*.Rnw
		Rscript -e 'setwd("supervised-classification"); knitr::knit2pdf("ex_classification_2.Rnw")'
  
supervised-classification/sol_classification_2.pdf: supervised-classification/*.Rnw
		Rscript -e 'setwd("supervised-classification"); knitr::knit2pdf("sol_classification_2.Rnw")'   
  
evaluation/ex_eval_1.pdf: evaluation/*.Rnw
		Rscript -e 'setwd("evaluation"); knitr::knit2pdf("ex_eval_1.Rnw")'
  
evaluation/sol_eval_1.pdf: evaluation/*.Rnw
		Rscript -e 'setwd("evaluation"); knitr::knit2pdf("sol_eval_1.Rnw")'   
  
evaluation/ex_eval_2.pdf: evaluation/*.Rnw
		Rscript -e 'setwd("evaluation"); knitr::knit2pdf("ex_eval_2.Rnw")'
  
evaluation/sol_eval_2.pdf: evaluation/*.Rnw
		Rscript -e 'setwd("evaluation"); knitr::knit2pdf("sol_eval_2.Rnw")' 
  
trees/ex_trees.pdf: trees/*.Rnw
		Rscript -e 'setwd("trees"); knitr::knit2pdf("ex_trees.Rnw")'
  
trees/sol_trees.pdf: trees/*.Rnw
		Rscript -e 'setwd("trees"); knitr::knit2pdf("sol_trees.Rnw")' 
  
forests/ex_forests.pdf: forests/*.Rnw
		Rscript -e 'setwd("forests"); knitr::knit2pdf("ex_forests.Rnw")'
  
forests/sol_forests.pdf: forests/*.Rnw
		Rscript -e 'setwd("forests"); knitr::knit2pdf("sol_forests.Rnw")'   

tuning-resampling/ex_tuning_resampling.pdf: tuning-resampling/*.Rnw
		Rscript -e 'setwd("tuning-resampling"); knitr::knit2pdf("ex_tuning_resampling.Rnw")'
  
tuning-resampling/sol_tuning_resampling.pdf: tuning-resampling/*.Rnw
		Rscript -e 'setwd("tuning-resampling"); knitr::knit2pdf("sol_tuning_resampling.Rnw")'   