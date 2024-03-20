.PHONY: sol ex solhtml solpdf exhtml expdf clean

sol: solhtml solpdf clean

ex: exhtml expdf clean

solhtml:
	for file in *.qmd; do \
		quarto render $$file --profile=solution; \
	done

solpdf:
	for file in *.qmd; do \
		quarto render $$file --profile=solution --to pdf; \
	done

exhtml:
	for file in *.qmd; do \
		quarto render $$file \
	done

expdf:
	for file in *.qmd; do \
		quarto render $$file --to pdf; \
	done

clean:
	rm -rf *_files
	rm -rf *preview.html
	rm -rf *out.ipynb
	rm -rf ../.quarto
	rm -rf *.rmarkdown

# rule for creating html (profile=solution) for a single file for testing; e.g. make classification_1
%:
	quarto render $@.qmd --profile=solution
