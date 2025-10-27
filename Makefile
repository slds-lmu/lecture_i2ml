.PHONY: help update-service update-latex-math clean slides

help:
	@echo "Available targets:"
	@echo "  update-service    : Update service components from lecture_service repository"
	@echo "                      Optional: branch=<name> to use a specific branch (default: main)"
	@echo "  update-latex-math : Update latex-math from slds-lmu/latex-math repository"
	@echo "                      Optional: branch=<name> to use a specific branch (default: master)"
	@echo "  slides            : Compile slides in all slides/ folders"
	@echo "  clean             : Clean LaTeX auxiliary files in all slide directories"
	@echo "  help              : Show this help message"

update-service:
	@bash scripts/update-service.sh $(branch)

update-latex-math:
	@bash scripts/update-latex-math.sh $(branch)

slides:
	@echo "Compiling slides in all slide directories..."
	@for dir in slides/*/; do \
		if [ -f "$$dir/Makefile" ]; then \
			echo "Compiling $$dir"; \
			$(MAKE) -C "$$dir" slides; \
		fi \
	done
	@echo "Done"

clean:
	@echo "Cleaning LaTeX auxiliary files and PDFs in all slide directories..."
	@for dir in slides/*/; do \
		if [ -f "$$dir/Makefile" ]; then \
			echo "Cleaning $$dir"; \
			$(MAKE) -C "$$dir" clean; \
		fi \
	done
	@echo "Cleanup complete"
