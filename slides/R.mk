.PHONY: help all deps install-deps

help:
	@echo ""
	@echo "╔═════════════════════════════════════╗"
	@echo "║       R Scripts                     ║"
	@echo "╚═════════════════════════════════════╝"
	@echo "all    : Run all .R scripts in isolated subprocesses (requires lese R package)"
	@echo "         Optional: timeout=<seconds> (default: 300)"
	@echo "deps         : Check R package dependencies and report what's missing"
	@echo "install-deps : Install missing R package dependencies via pak"
	@echo "help   : Show this help message"

# Chapter name and lecture root, derived from rsrc/ location
# rsrc/ is at: <lecture_root>/slides/<chapter>/rsrc/
CHAPTER := $(notdir $(abspath ..))
LECTURE := $(abspath ../../..)

# Default timeout for script execution (seconds)
timeout ?= 300

all:
	@Rscript --quiet -e 'lese::run_chapter_scripts("$(CHAPTER)", lecture_dir = "$(LECTURE)", timeout = $(timeout))'

deps:
	@Rscript --quiet -e 'lese::check_script_deps("$(CHAPTER)", lecture_dir = "$(LECTURE)", install = FALSE)'

install-deps:
	@Rscript --quiet -e 'lese::check_script_deps("$(CHAPTER)", lecture_dir = "$(LECTURE)", install = TRUE)'
