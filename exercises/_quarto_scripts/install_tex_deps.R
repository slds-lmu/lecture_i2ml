#! /usr/bin/env Rscript

if (!("tinytex" %in% installed.packages())) install.packages("tinytex")
if (!tinytex::is_tinytex()) {
  warning("Please install tinytex: tinytex::install_tinytex()")
}
# Script to extract packages didn't work on GH so I ran tinytex::latexmk()
# interactively via tmate and just.. wrote down the pkg it installed.
# ...if it works it works. I guess.
manually_selected_deps <- c(
  "beamer",
  "fp",
  "ms",
  "pgf",
  "translator",
  "colortbl",
  "babel-english",
  "doublestroke",
  "csquotes",
  "multirow",
  "textpos",
  "psfrag",
  "algorithms",
  "algorithmicx",
  "eqnarray",
  "arydshln",
  "placeins",
  "setspace",
  "mathtools",
  "wrapfig",
  "subfig",
  "caption",
  "bbm-macros",
  "transparent", # lecture_sl/slides/boosting/slides-boosting-cwb-basics2.tex
  "adjustbox",   # optim and iml, lecture_optimization/slides/01-mathematical-concepts/slides-concepts-3-convexity.tex and cheatsheets
  "verbatimbox", # optim, 07-derivative-free/slides-optim-derivative-free-4-multistart-optimization
  "tcolorbox",   # iml, 01_intro/slides05-intro-interaction.tex
  "siunitx",      # iml, 04_shapley/slides04-shap.tex, but used in latex-math anyway
  "pdfpages",   # iml, but why? 
  # All of the following were iml-specific dependencies I have not investigated specifically
  # Ideally we'd be able to identify which dependency is included for which purposes/feature
  # to avoid having to install a bag of mystery packages just to keep the latex demon happy.
  "xifthen",
  "footmisc",
  "tikzmark",
  "ifmtarg",
  "textcase",
  "pdflscape",
  "makecell",
  "environ", 
  "trimspaces",
  "tikzfill",
  "pdfcol",
  "listings",
  "listingsutf8", 
  "readarray"
)

cli::cli_alert_info("Attempting to install manually selected LaTeX dependencies via {.fun tinytex::tlmgr_install}")
tinytex::tlmgr_install(manually_selected_deps)


# Unused but maybe useful in the future ---------------------------------------------------------------------------

if (FALSE) {
  # List of installed packages in a fresh TinyTex installation on GitHub actions using default settings:
  default_installed <- "amscls
amsfonts
amsmath
atbegshi
atveryend
auxhook
babel
bibtex
bibtex.universal-darwin
bigintcalc
bitset
booktabs
cm
ctablestack
dehyph
dvipdfmx
dvipdfmx.universal-darwin
dvips
dvips.universal-darwin
ec
epstopdf-pkg
etex
etexcmds
etoolbox
euenc
everyshi
fancyvrb
filehook
firstaid
float
fontspec
framed
geometry
gettitlestring
glyphlist
graphics
graphics-cfg
graphics-def
helvetic
hycolor
hyperref
hyph-utf8
hyphen-base
iftex
inconsolata
infwarerr
intcalc
knuth-lib
kpathsea
kpathsea.universal-darwin
kvdefinekeys
kvoptions
kvsetkeys
l3backend
l3kernel
l3packages
latex
latex-amsmath-dev
latex-bin
latex-bin.universal-darwin
latex-fonts
latex-tools-dev
latexconfig
latexmk
latexmk.universal-darwin
letltxmacro
lm
lm-math
ltxcmds
lua-alt-getopt
lua-uni-algos
luahbtex
luahbtex.universal-darwin
lualatex-math
lualibs
luaotfload
luaotfload.universal-darwin
luatex
luatex.universal-darwin
luatexbase
mdwtools
metafont
metafont.universal-darwin
mfware
mfware.universal-darwin
modes
natbib
pdfescape
pdftex
pdftex.universal-darwin
pdftexcmds
plain
psnfss
refcount
rerunfilecheck
scheme-infraonly
selnolig
stringenc
symbol
tex
tex-ini-files
tex.universal-darwin
texlive-scripts
texlive-scripts.universal-darwin
texlive.infra
texlive.infra.universal-darwin
times
tipa
tools
unicode-data
unicode-math
uniquecounter
url
xcolor
xetex
xetex.universal-darwin
xetexconfig
xkeyval
xunicode
zapfding"

  default_installed <- unlist(strsplit(default_installed, "\n"))

  latex_packages <- list.files("lecture_sl/style", pattern = "*.tex", recursive = TRUE, full.names = TRUE) |>
    lapply(\(x) grep("^\\\\usepackage", readLines(x), value = TRUE)) |>
    unlist() |>
    stringr::str_subset("lmu-lecture", negate = TRUE) |>
    stringr::str_extract_all("\\{\\w*\\}") |>
    unlist() |>
    stringr::str_remove_all("\\{|\\}") |>
    stringr::str_split(",") |>
    unlist()

  # This has a different name on CTAN, unhelpfully, is required for latex-math though
  if ("dsfont" %in% latex_packages) {
    latex_packages[latex_packages == "dsfont"] <- "doublestroke"
  }

  # Kind of important.
  latex_packages <- union("beamer", latex_packages)

  # Unfortunately some pkgs are preinstalled everywhere but not listed by tlmgr list --only-installed (inputenc, babel...)
  missing <- setdiff(latex_packages, default_installed)
  missing <- latex_packages[which(tinytex::check_installed(missing))]

  cli::cli_inform("Found the following possibly missing LaTeX packages: {missing}")
  cli::cli_alert_info("Attemtping to install them via {.fun tinytex::tlmgr_install}")
  tinytex::tlmgr_install(missing)
}
