# Backend: R (ggplot2 / patchwork / ComplexHeatmap)

**R-only execution rule.** When the user has selected R, do all figure drawing, previewing, exporting, and visual QA in R. Do not call matplotlib/seaborn or any Python graphics device to create a temporary preview, fallback export, or layout approximation. If `Rscript`/R or required R packages are missing, pause rendering, continue independent script or data checks, and report the exact blocker. You may still write the R script, provide install commands (for example `install.packages(...)`), or ask permission to install dependencies, but do not cross-render the figure in Python.

## R quick-start

```r
library(ggplot2)
library(patchwork)
source("skills/nature-figure/scripts/panel_alignment.R")

theme_nature_quant <- function(base_size = 8) {
  # Standard Cartesian plots only: bars, scatterplots, lines, boxplots, etc.
  # Do not set base_family unless the user explicitly requests a typeface.
  theme_bw(base_size = base_size) +
    theme(
      axis.ticks = element_line(linewidth = 0.35, colour = "black"),
      axis.title = element_text(size = base_size, face = "bold"),
      legend.title = element_text(size = base_size - 0.3, face = "bold"),
      legend.text = element_text(size = base_size - 0.7),
      strip.text = element_text(size = base_size - 0.3, face = "bold"),
      plot.title = element_text(size = 7.5, face = "bold"),
      panel.grid.minor = element_blank()
    )
}

theme_nature_void <- function(base_size = 8) {
  # Axis-free plots only: networks, pie/donut charts, and image-led panels.
  theme_void(base_size = base_size) +
    theme(
      legend.title = element_text(size = base_size - 0.3, face = "bold"),
      legend.text = element_text(size = base_size - 0.7),
      plot.title = element_text(size = 7.5, face = "bold"),
      strip.text = element_text(size = base_size - 0.3, face = "bold")
    )
}

ggplot2::ggsave(
  filename = "figure.pdf", plot = fig, device = grDevices::pdf,
  width = 183, height = 120, units = "mm", bg = "white",
  useDingbats = FALSE
)
```

Do not call `theme_set()` here. Apply `theme_nature_quant()` explicitly to
standard Cartesian plots (bar, scatter, line, box/violin, volcano and similar
X/Y plots). Apply `theme_nature_void()` only to axis-free plots such as networks
and pie/donut charts, or use the specialized theme required by a map, tree,
heatmap, or image panel. Keep `plot.title` bold. Do not add `subtitle` to
`labs()` by default: use one only when the user explicitly requests a second
line of explanatory text. Axis titles and legend titles are bold by default;
tick labels and legend entries remain regular weight for legibility.

For standard Cartesian plots, keep both axis titles by default, including a
categorical X axis such as `Species` or `Treatment`. Omit an axis title only
when the user explicitly requests it or the plot is genuinely axis-free.

The default physical size follows layout complexity: a single standard plot is
`120 × 90 mm` so its title remains readable; a patchwork multi-panel figure is
`183 × 120 mm`. The default theme base size is `8 pt`; its bold panel title is
`7.5 pt`.
Override dimensions deliberately when the target journal or panel layout needs
a different final size.

The default export is one PDF only. Do not create a PNG preview, SVG, TIFF, or
alignment diagnostics unless the user explicitly requests strict QA, a
submission-ready audit, or another additional artifact. For a patchwork
alignment audit, call `require_patchwork_panel_alignment()` explicitly before
`ggsave()`; its JSON/SVG outputs are QA-only. Use the native R PDF device by default: it avoids
Cairo font matching and embedding, which can cause uneven spacing in macOS PDF
Preview. Use `cairo_pdf` only when the user explicitly needs it and has checked
the final PDF in their target viewer.

## Going deeper

- `references/r-workflow.md` — the R plotting workflow when the user provides R scripts, templates, or data.
- `references/r-template-index.md` — adapt a user-provided or private R template collection without exposing source paths.
- `references/design-theory.md` — typography, color theory, layout rationale, export policy (backend-agnostic).
- `references/nature-2026-observations.md` — real Nature page archetypes to match before choosing layout.
- `scripts/validate_figure.py` — dependency-free static R source preflight before running R and inspecting the rendered outputs.
- `scripts/audit_pdf_text.py` — inspect the final R-generated PDF's rendered glyph floor without redrawing it.
- `scripts/panel_alignment.R` plus `scripts/audit_panel_alignment.py` — opt-in render-time patchwork/gtable alignment gate for strict QA; declare comparable groups explicitly for asymmetric layouts.
- `scripts/audit_figure_collisions.py` — backend-neutral geometry audit for strict QA or submission-ready delivery; its optional marked PDF is QA-only and does not replace the R export.
