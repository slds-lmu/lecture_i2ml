help:
	@echo ""
	@echo "╔═════════════════════════════════════╗"
	@echo "║       Rendering Slides              ║"
	@echo "╚═════════════════════════════════════╝"
	@echo "slides             : Renders slides to PDF (basic compilation)"
	@echo "slides-nomargin    : Renders 4:3 slides with -nomargin.pdf suffix"
	@echo ""
	@echo "  ════ Docker options (for all compilation targets) ════"
	@echo "  DOCKER=true      : Use Docker for LaTeX compilation instead of local installation"
	@echo "  TLYEAR=<year>    : Specify TeXLive year (default: 2024, or use 'latest')"
	@echo "                     Example: make slides DOCKER=true TLYEAR=2023"
	@echo ""
	@echo "╔═════════════════════════════════════╗"
	@echo "║       Copying to /slides-pdf/       ║"
	@echo "╚═════════════════════════════════════╝"
	@echo "release            : Runs texclean, renders slides and literature, copies to /slides-pdf/, and texclean again"
	@echo "copy               : Copies PDF files to /slides-pdf/"
	@echo ""
	@echo "╔═════════════════════════════════════╗"
	@echo "║       Utilities                     ║"
	@echo "╚═════════════════════════════════════╝"
	@echo "texclean           : Deletes all LaTeX build artifacts (.log, .aux, .nav, .synctex, ...) but keeps PDFs"
	@echo "clean              : Runs texclean and *also* deletes all compiled PDFs"
	@echo "pax                : Runs pdfannotextractor.pl (pax) to store hyperlinks etc. in .pax files for later use"
	@echo "literature         : Generates chapter-literature-CHAPTERNAME.pdf from references.bib"
	@echo ""
	@echo "╔═════════════════════════════════════╗"
	@echo "║       File Checking                 ║"
	@echo "╚═════════════════════════════════════╝"
	@echo "check-files-used   : List files (figures, .tex) that are included is slide .tex files"
	@echo "check-files-unused : List files that are NOT included in .tex files"
	@echo "check-files-missing: List files that the slides expect but cannot find"
	@echo "                     Optional: folder=<path> (default: figure)"
	@echo "                     Note: Requires 'make slides' to be run first so .fls files exist!"

# ============================================================================
# VARIABLES
# ============================================================================

# TeXLive version configuration: use 2024 as default, can be overruled with TLYEAR env var
# See also
# - Source repo with description: https://gitlab.com/islandoftex/images/texlive
# - Registry: https://gitlab.com/islandoftex/images/texlive/container_registry/573747
TLYEAR ?= 2024

# Get current working directory name and lecture root path
CWD := $(notdir $(CURDIR))
LECTURE := $(shell cd ../.. && pwd)

# Normalize Docker environment variable (accept true, TRUE, 1, or docker/DOCKER env vars)
DOCKER_ENABLED := $(shell \
	if [ "$(DOCKER)" = "true" ] || [ "$(DOCKER)" = "TRUE" ] || [ "$(DOCKER)" = "1" ] || \
	   [ "$(docker)" = "true" ] || [ "$(docker)" = "TRUE" ] || [ "$(docker)" = "1" ]; then \
		echo "true"; \
	else \
		echo "false"; \
	fi)

# Set Docker image tag
ifeq ($(TLYEAR),latest)
DOCKER_TAG := latest
else
DOCKER_TAG := TL$(TLYEAR)-historic
endif

# Configure latexmk command based on normalized Docker setting
ifeq ($(DOCKER_ENABLED),true)
DOCKER_IMAGE := registry.gitlab.com/islandoftex/images/texlive:$(DOCKER_TAG)
LATEXMK = docker run -i --rm --user $$(id -u) --name latex \
  -v "$(LECTURE)":/usr/src/app:z \
  -w "/usr/src/app/slides/$(CWD)" \
  $(DOCKER_IMAGE) \
  latexmk -halt-on-error -pdf
else
LATEXMK = latexmk -halt-on-error -pdf
endif

# Slide .tex files, relative paths
SLIDE_TEX_FILES = $(shell find . -maxdepth 1 -iname "slides*.tex")
# Substitute file extension tex -> pdf for output pdf filenames
SLIDE_PDF_FILES = $(SLIDE_TEX_FILES:%.tex=%.pdf)
# Substitute file extension tex -> pax for annotation files
SLIDE_PAX_FILES = $(SLIDE_TEX_FILES:%.tex=%.pax)
# output pdf filenames for slides without margin (old 4:3 layout)
SLIDE_NOMARGIN_PDFS = $(SLIDE_TEX_FILES:%.tex=%-nomargin.pdf)

# fls files contain the full filesystem paths of all included files, used for unused figure detection script
SLIDE_FLS_FILES = $(SLIDE_TEX_FILES:%.tex=%.fls)

# Generate literature list from references.bib, appending the current chapter name to the file name
CHAPTER_NAME := $(notdir $(CURDIR))
LITERATURE_PDF := chapter-literature-$(CHAPTER_NAME).pdf

.PHONY: slides slides-nomargin release copy texclean clean help pax literature check-files-used check-files-unused check-files-missing

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Docker availability check and image pull function
# Verifies Docker is installed and daemon is running before attempting compilation
# Only pulls the image if it's not already available locally to avoid redundant pull attempts
# But we need to explicitly pull because otherwise it might be pulling an image (slowly) in the background
# without the user being informed that this is happening.
define check_docker
	@if [ "$(DOCKER_ENABLED)" = "true" ]; then \
		if ! command -v docker >/dev/null 2>&1; then \
			echo "Error: Docker is not installed. Please install Docker to use DOCKER=true mode."; \
			exit 1; \
		fi; \
		if ! docker info >/dev/null 2>&1; then \
			echo "Error: Docker daemon is not running. Please:"; \
			echo "  a) Check if Docker is installed"; \
			echo "  b) Start the Docker daemon/service"; \
			exit 1; \
		fi; \
		if ! docker image inspect $(DOCKER_IMAGE) >/dev/null 2>&1; then \
			echo "Pulling Docker image $(DOCKER_IMAGE)..."; \
			docker pull $(DOCKER_IMAGE); \
		fi; \
	fi
endef

# Check if latex-math directory exists in the expected location
define check_latex_math
	@if [ ! -d "../../latex-math" ]; then \
		echo "Cannot find 'latex-math' in root directory"; \
		exit 1; \
	fi
endef

# Check LaTeX log file for common errors and display relevant messages
define check_latex_log
if [ -f "$(1).log" ]; then \
	errors=$$(grep -n -B1 -A2 -E "(^! Undefined control sequence|^LaTeX Warning: File.*not found|^! Missing \\$$|Runaway argument|^! Extra \\}, or forgotten \\$$|! TeX capacity exceeded|! Incomplete|^! LaTeX Error:)" "$(1).log" 2>/dev/null || true); \
	if [ -n "$$errors" ]; then \
		echo "LaTeX compilation errors found in $(1).log:"; \
		printf '%s\n' "$$errors"; \
		echo ""; \
		echo "Full log available at: $(1).log"; \
		exit 1; \
	fi; \
fi
endef

# Clean LaTeX build artifacts silently
define clean_latex_artifacts
	@echo "Cleaning LaTeX build artifacts (.log, .aux, .nav, .synctex, etc.)..."
	@rm -f *.out *.dvi *.log *.aux *.bbl *.bbl-SAVE-ERROR *.blg *.ind *.idx *.ilg *.lof *.lot *.toc *.nav *.snm *.vrb *.fls *.pax *.bcf-SAVE-ERROR *.bcf *.run.xml *.fdb_latexmk *.synctex.gz *-concordance.tex nospeakermargin.tex
endef

# Print compilation message with Docker/local info
define print_compile_message
	@if [ "$(DOCKER_ENABLED)" = "true" ]; then \
		echo "Compiling $(1) using Docker ($(DOCKER_TAG))..."; \
	else \
		echo "Compiling $(1) using local LaTeX..."; \
	fi
endef

# Find and run pdfannotextractor
define run_pdfannotextractor
	@pax_cmd=""; \
	if command -v pdfannotextractor &> /dev/null; then \
		pax_cmd="pdfannotextractor"; \
	elif command -v pdfannotextractor.pl &> /dev/null; then \
		pax_cmd="pdfannotextractor.pl"; \
	fi; \
	if [ -n "$$pax_cmd" ]; then \
		echo "Found $$pax_cmd - extracting annotations..."; \
		$$pax_cmd *.pdf 2>/dev/null || echo "Warning: Some PDFs may not have been processed"; \
	else \
		echo "Note: pdfannotextractor not found!"; \
		echo "Please install 'pax' package using: tlmgr install pax"; \
		echo "This is required to preserve clickable URLs and annotations in slides-pdf/"; \
	fi
endef

# ============================================================================
# TARGETS
# ============================================================================

# Basic slide compilation
slides: $(SLIDE_PDF_FILES)
slides-nomargin: $(SLIDE_NOMARGIN_PDFS)

release:
	$(call check_latex_math)
	$(MAKE) texclean
	$(MAKE) $(SLIDE_PDF_FILES)
	$(MAKE) pax
	$(MAKE) literature
	$(MAKE) copy
	$(MAKE) texclean

# Conditionally remove or create empty nospeakermargin.tex file to decide which layout to use
# See /style/lmu-lecture.sty -- it's a whole thing but does the job.
# The -g flag forces latexmk to always run and generates .fls files for dependency tracking
$(SLIDE_PDF_FILES): %.pdf: %.tex
	$(call check_docker)
	@rm -f nospeakermargin.tex
	$(call print_compile_message,$< to $@)
	@start_time=$$(date +%s); \
	$(LATEXMK) -g $< > /dev/null 2>&1 || ($(call check_latex_log,$*); exit 1); \
	end_time=$$(date +%s); \
	duration=$$((end_time - start_time)); \
	echo "✓ Successfully compiled $@ (took $${duration}s)"

$(SLIDE_NOMARGIN_PDFS): %-nomargin.pdf: %.tex
	$(call check_docker)
	@touch nospeakermargin.tex
	$(call print_compile_message,$< to $@ (no margin))
	@start_time=$$(date +%s); \
	$(LATEXMK) -jobname=$*-nomargin $< > /dev/null 2>&1 || ($(call check_latex_log,$*-nomargin); exit 1); \
	end_time=$$(date +%s); \
	duration=$$((end_time - start_time)); \
	echo "✓ Successfully compiled $@ (took $${duration}s)"


copy:
	@echo "Copying PDFs and PAX files to slides-pdf/..."
	@rsync -u *.pdf ../../slides-pdf/ 2>/dev/null || cp *.pdf ../../slides-pdf/
	@rsync -u *.pax ../../slides-pdf/ 2>/dev/null || true

# Extract pdf annotations, i.e. hyperlinks, for later reinsertion
# When combining multiple PDFs into one (for slides/all/)
# https://ctan.org/tex-archive/macros/latex/contrib/pax?lang=en
pax:
	$(call run_pdfannotextractor)

texclean:
	$(call clean_latex_artifacts)

clean: texclean
	-rm -f $(SLIDE_PDF_FILES) $(SLIDE_NOMARGIN_PDFS) $(SLIDE_PAX_FILES) $(LITERATURE_PDF)

literature: $(LITERATURE_PDF)

$(LITERATURE_PDF): references.bib
	$(call check_docker)
	$(call print_compile_message,literature list for chapter $(CHAPTER_NAME))
	@start_time=$$(date +%s); \
	$(LATEXMK) -jobname=chapter-literature-$(CHAPTER_NAME) ../../style/chapter-literature-template.tex > /dev/null 2>&1 || ($(call check_latex_log,chapter-literature-$(CHAPTER_NAME)); exit 1); \
	end_time=$$(date +%s); \
	duration=$$((end_time - start_time)); \
	echo "✓ Literature list generated: $(LITERATURE_PDF) (took $${duration}s)"
	@echo "Cleaning up detritus..."
	@$(LATEXMK) -c -jobname=chapter-literature-$(CHAPTER_NAME) ../../style/chapter-literature-template.tex > /dev/null 2>&1

# ============================================================================
# FILE CHECKING TARGETS
# ============================================================================

# Default folder to check (can be overridden with folder=<path>)
folder ?= figure

check-files-used:
	@if [ ! -f "$(word 1,$(SLIDE_FLS_FILES))" ]; then \
		echo "Error: No .fls files found. Please run 'make slides' first to generate them."; \
		exit 1; \
	fi
	@echo "Checking used files in ./$(folder)..."
	@../../scripts/check_files_used.sh $(folder) used $(SLIDE_TEX_FILES) || true

check-files-unused:
	@if [ ! -f "$(word 1,$(SLIDE_FLS_FILES))" ]; then \
		echo "Error: No .fls files found. Please run 'make slides' first to generate them."; \
		exit 1; \
	fi
	@echo "Checking unused files in ./$(folder)..."
	@../../scripts/check_files_used.sh $(folder) unused $(SLIDE_TEX_FILES) || true

check-files-missing:
	@if [ ! -f "$(word 1,$(SLIDE_FLS_FILES))" ]; then \
		echo "Error: No .fls files found. Please run 'make slides' first to generate them."; \
		exit 1; \
	fi
	@echo "Checking missing files referenced in LaTeX..."
	@../../scripts/check_files_used.sh $(folder) missing $(SLIDE_TEX_FILES) || true
