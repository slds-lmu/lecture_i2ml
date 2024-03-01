.PHONY: html pdf qmdhtml qmdpdf clean

html: qmdhtml clean

pdf: qmdpdf clean


qmdhtml:
	for file in *.qmd; do \
		quarto render $$file --profile=solution; \
	done

qmdpdf:
	for file in *.qmd; do \
		quarto render $$file --profile=solution --to pdf; \
	done

clean:
	rm -rf *_files
	rm -rf *preview.html
	rm -rf *out.ipynb
	rm -rf ../.quarto

# rule for single file ; e.g. make classification_1
%:
	quarto render $@.qmd --profile=solution
