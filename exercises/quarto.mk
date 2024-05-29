.PHONY: sol ex solhtml solpdf exhtml expdf clean

EXERCISES = $(wildcard *.qmd)

sol: solhtml solpdf clean

ex: exhtml expdf clean

$(EXPDFS): %.pdf: %.qmd 
foo: $(EXPDFS)
	quarto render $(EXPDFS) --profile=solution --to=pdf --output="$(EXPDFS)_all.pdf"

solhtml:
	for file in *.qmd; do \
		quarto render $$file --profile=solution; \
	done

solpdf:
	for file in $(wildcard *.qmd); do \
		bname=$$(basename $$file); \
		echo ">>> $$bname"; \
		filename="$$bname-all.pdf"; \
		quarto render $$file --profile=solution --to pdf --output=$$filename; \
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
