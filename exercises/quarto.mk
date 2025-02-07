.PHONY: all sol ex solhtml solpdf exhtml expdf clean copy copy-all

all: solhtml solpdf exhtml expdf clean copy-all

sol: solhtml solpdf clean

ex: exhtml expdf clean

solhtml:
	for file in *.qmd; do \
		quarto render $$file --profile=solution; \
	done

solpdf:
	for file in *.qmd; do \
		quarto render $$file --profile=solution --to pdf --output "$${file%.qmd}_all.pdf"; \
	done

exhtml:
	for file in *.qmd; do \
		quarto render $$file; \
	done

expdf:
	for file in *.qmd; do \
		quarto render $$file --to pdf --output "$${file%.qmd}_ex.pdf"; \
	done

clean:
	rm -rf *_files
	rm -rf *preview.html
	rm -rf *out.ipynb
	rm -rf ../.quarto
	rm -rf *.rmarkdown

copy: $(F)
	cp $(F) ../../exercises-pdf/

copy-all:
	cp  *.pdf ../../exercises-pdf/

# rule for creating html (profile=solution) for a single file for testing; e.g. make classification_1
%:
	quarto render $@.qmd --profile=solution
