# Interactive plotly figures in the exercise sheets (HTML only).
#
# In the sheet's hidden chunk, source("../_quarto/plotly.R") and print a figure
# as small_plotly(p) instead of p. This keeps the self-contained HTML small:
#   - drops plotly's R-side copy of the data and writes numbers with `digits`
#     significant digits
#   - loads plotly.js from plotly's CDN when the page opens, like MathJax,
#     instead of embedding it; the figure then needs internet, like the formulas
# plotly.js comes in bundles for different kinds of figures (e.g. "gl3d" for 3D
# plots), and a page can load only one. The sheet's first figure picks it: the
# smallest one that fits ("auto"), or the one given as `bundle`. Later figures
# must fit the same bundle. bundle = "main" embeds the full library instead.

.plotly_cdn <- new.env() # the bundle this sheet loads

small_plotly <- function(p, digits = 4, bundle = "auto") {
  if (!is.null(.plotly_cdn$bundle)) bundle <- .plotly_cdn$bundle
  # plotly builds the figure and points the bundle at its CDN (src$href)
  p <- tryCatch(
    plotly::partial_bundle(p, type = bundle, local = FALSE),
    error = function(e) stop(
      "small_plotly(): ", conditionMessage(e), "\nAll plotly figures of a sheet share one ",
      "plotly.js bundle: give the first figure one that fits all of them ",
      "(e.g. bundle = \"gl3d\"), or bundle = \"main\".",
      call. = FALSE
    )
  )
  p$x[c("attrs", "visdat", "cur_data")] <- NULL
  attr(p$x, "TOJSON_FUNC") <- function(x, ...) jsonlite::toJSON(
    x, digits = I(digits), auto_unbox = TRUE, force = TRUE, null = "null", na = "null", ...)
  # already built; a rebuild at print time would add back what is removed here
  p$preRenderHook <- NULL

  is_cdn <- vapply(p$dependencies, function(d) !is.null(d$src$href), logical(1))
  if (!any(is_cdn)) {
    # "main", or no bundle fits: the full library is embedded
    .plotly_cdn$bundle <- "main"
    return(p)
  }
  # Quarto only handles dependencies stored on disk, so the bundle is loaded with
  # a script tag instead; data-external keeps pandoc from embedding it
  dep <- p$dependencies[is_cdn][[1]]
  p$dependencies <- p$dependencies[!is_cdn]
  if (is.null(.plotly_cdn$bundle)) {
    .plotly_cdn$bundle <- sub("^plotly-", "", dep$name)
    p <- htmlwidgets::prependContent(p, htmltools::tags$script(
      src = paste0(dep$src$href, "/", dep$script), `data-external` = "1"))
  }
  p
}
