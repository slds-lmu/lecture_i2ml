.PHONY: all sol ex solhtml solpdf exhtml expdf clean copy-all

# The targets share ../.quarto (deleted by clean) and must run in the given order.
.NOTPARALLEL:

SHEETS := $(wildcard *.qmd)

# the committed outputs: <sheet>.html, <sheet>_ex.pdf, <sheet>_all.pdf
all: expdf solhtml solpdf clean copy-all

sol: solhtml solpdf clean

ex: exhtml expdf clean

# every loop stops at the first failed render (|| exit 1), so make reports it
solhtml:
	for file in $(SHEETS); do \
		quarto render $$file --profile=solution --to html || exit 1; \
	done

solpdf:
	for file in $(SHEETS); do \
		quarto render $$file --profile=solution --to pdf --output "$${file%.qmd}_all.pdf" || exit 1; \
	done

# exercise-only HTML (not committed, not part of all): make exhtml
exhtml:
	for file in $(SHEETS); do \
		quarto render $$file --to html --output "$${file%.qmd}_ex.html" || exit 1; \
	done

expdf:
	for file in $(SHEETS); do \
		quarto render $$file --to pdf --output "$${file%.qmd}_ex.pdf" || exit 1; \
	done

clean:
	rm -rf *_files
	rm -rf *preview.html
	rm -rf *out.ipynb
	rm -rf ../.quarto
	rm -rf *.rmarkdown

# only the PDFs of the sheets in this folder
copy-all:
	cp $(SHEETS:.qmd=_ex.pdf) $(SHEETS:.qmd=_all.pdf) ../../exercises-pdf/

# one solution HTML for a quick check, e.g. make classification_1
# (terminal rule: only for names with a .qmd file, so a typo is an error)
%:: %.qmd
	quarto render $< --profile=solution --to html
