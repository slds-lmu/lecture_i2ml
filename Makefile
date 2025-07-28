.PHONY: help update-service update-latex-math clean

help:
	@echo "Available targets:"
	@echo "  update-service    : Update service components from lecture_service repository"
	@echo "  update-latex-math : Update latex-math from slds-lmu/latex-math repository"
	@echo "  clean             : Clean LaTeX auxiliary files in all slide directories"
	@echo "  help              : Show this help message"

update-service:
	@echo "Updating service components from lecture_service repository..."
	@bash scripts/update-service.sh

update-latex-math:
	@bash scripts/update-latex-math.sh

clean:
	@echo "Cleaning LaTeX auxiliary files and PDFs in all slide directories..."
	@for dir in slides/*/; do \
		if [ -f "$$dir/Makefile" ]; then \
			echo "Cleaning $$dir"; \
			$(MAKE) -C "$$dir" clean; \
		fi \
	done
	@echo "Cleanup complete"
