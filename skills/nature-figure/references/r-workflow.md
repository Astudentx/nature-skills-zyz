# R Workflow

## Contents

- [R-only execution rule](#r-only-execution-rule)
- [Required packages by task](#required-packages-by-task)
- [Contract scaffold](#contract-scaffold)
- [Panel labels in R](#panel-labels-in-r)
- [Patchwork layout patterns](#patchwork-layout-patterns)
- [Patchwork panel-alignment gate](#patchwork-panel-alignment-gate)
- [ComplexHeatmap export](#complexheatmap-export)
- [Template reuse rule](#template-reuse-rule)


Use this when the user chooses R, brings R data/scripts, or asks to reuse the local
R plotting templates. The R track should still follow the same figure contract:
claim first, evidence hierarchy second, plotting code third.

For an R analysis project, also read [r-project-management.md](r-project-management.md)
for project layout, script naming, and input/output paths. Keep the figure
theme, export, and QA rules in this R figure workflow.

## R-only execution rule

When the user has selected R, do all figure drawing, previewing, exporting, and
visual QA in R. Do not call Python/matplotlib/seaborn/plotly to create a temporary
preview, fallback export, or layout approximation. If R, `Rscript`, or required R
packages are missing, pause rendering, continue independent script or data checks, and report the missing dependency. You
may still write the R script, provide `install.packages()` commands, or ask permission
to install dependencies, but do not cross-render the figure in another language.

Allowed non-R utilities are limited to non-visual tasks such as shell file inspection,
CSV line counts, checksums, archive extraction, or text search. They must not create
image/vector outputs or alter visual layout.

## Required packages by task

| Task | Preferred packages |
|---|---|
| Bars, boxplots, violins, dot plots, lines, volcano plots | `ggplot2`, `ggrepel`, `dplyr`, `tidyr` |
| Multi-panel assembly and alignment QA | `patchwork`, `grid`, `jsonlite`; use `cowplot` only when inset alignment requires it |
| Rich omics heatmaps | `ComplexHeatmap`, `circlize`, `grid` |
| Survival and clinical subgroup plots | `survival`, `survminer`, `forestplot`, `ggplot2` |
| Circular/genome plots | `circlize`, `ggtree`, `gggenes`, domain-specific packages |
| Export | `ggplot2::ggsave(..., device = grDevices::pdf, useDingbats = FALSE)`; add `svglite`, `ragg`, or Cairo only when the user explicitly requests a non-default output need |

## Contract scaffold

### R font policy

Unless the user explicitly requests a typeface, do not set `base_family`,
`family`, or a device-specific font option. Let the active R graphics device
select its default font. The default PDF export uses `grDevices::pdf()` with
`useDingbats = FALSE`, rather than Cairo: Cairo font matching and embedding can
cause uneven kerning or broken-looking words in macOS PDF Preview and
rasterization even when no font family is supplied. If the user requires a
named typeface or Cairo specifically, apply it deliberately and verify the
exported PDF on the target system.

```r
library(ggplot2)
library(patchwork)
source("skills/nature-figure/scripts/panel_alignment.R")

palette_contract <- c(
  neutral_dark = "#272727",
  neutral_mid = "#767676",
  neutral_light = "#D8D8D8",
  signal_blue = "#3182BD",
  signal_teal = "#33B5A5",
  accent_red = "#D24B40",
  accent_orange = "#E28E2C"
)

theme_nature_quant <- function(base_size = 8) {
  # Use only for standard Cartesian plots: bars, scatterplots, lines, and boxplots.
  theme_bw(base_size = base_size) +
    theme(
      axis.ticks = element_line(linewidth = 0.35, colour = "black"),
      axis.title = element_text(size = base_size, face = "bold"),
      axis.text = element_text(size = base_size - 0.5),
      legend.title = element_text(size = base_size - 0.3, face = "bold"),
      legend.text = element_text(size = base_size - 0.7),
      strip.text = element_text(size = base_size - 0.3, face = "bold"),
      plot.title = element_text(size = 7.5, face = "bold"),
      panel.grid.minor = element_blank()
    )
}

theme_nature_void <- function(base_size = 8) {
  # Use only for axis-free plots: networks, pie/donut charts, and image-led panels.
  theme_void(base_size = base_size) +
    theme(
      legend.title = element_text(size = base_size - 0.3, face = "bold"),
      legend.text = element_text(size = base_size - 0.7),
      strip.text = element_text(size = base_size - 0.3, face = "bold"),
      plot.title = element_text(size = 7.5, face = "bold")
    )
}

ggplot2::ggsave(
  filename = "figure.pdf", plot = fig, device = grDevices::pdf,
  width = 183, height = 120, units = "mm", bg = "white",
  useDingbats = FALSE
)
```

Write one PDF by default with an explicit `ggplot2::ggsave()` call. Generate
PNG, TIFF, SVG, or alignment QA files only when the user explicitly requests
that format or a strict submission-ready audit. For strict patchwork QA, call
`require_patchwork_panel_alignment()` immediately before `ggsave()`; its
JSON/SVG outputs are QA diagnostics, not delivery figures.

Do not use `theme_set()`: it would apply one coordinate-plot theme to every
subsequent ggplot. Apply `theme_nature_quant()` explicitly to standard X/Y
Cartesian plots (bars, scatterplots, lines, boxplots, violins, volcano plots
and similar rectangular panels). Apply `theme_nature_void()` only to axis-free
network and pie/donut plots. Maps, trees, heatmaps and image-led panels retain
their specialized themes. Use a bold `plot.title`, axis titles, and legend
titles by default. Do not add a `labs(subtitle = ...)` line unless the user
explicitly asks for explanatory text below the title; it is not a default
manuscript-figure element.

For standard Cartesian plots, retain both X and Y axis titles by default. A
categorical X axis should still name its variable (for example, `Species` or
`Treatment`); use `x = NULL` only when the user explicitly requests it or the
plot is truly axis-free.

### Default physical size and text hierarchy

Choose `120 × 90 mm` for one standard plot and `183 × 120 mm` for a patchwork
multi-panel figure unless the journal or layout requires another size. The theme
starts at `8 pt`, and uses `7.5 pt` for a bold plot title. This makes the title
legible without enlarging the plot into a double-column canvas unnecessarily.
Set `width_mm` and `height_mm` explicitly when a journal specification or a
particular panel layout requires another final size.

## Panel labels in R

Use patchwork tags for most multi-panel figures:

```r
fig <- (p_a | p_b) / (p_c | p_d) +
  plot_annotation(tag_levels = "a") &
  theme(plot.tag = element_text(size = 8, face = "bold"))
```

Do not add an overall plotted title with `plot_annotation(title = ...)` by
default. The manuscript figure legend—not a redundant title inside the figure—
should provide that framing. Keep the lowercase panel tags (`a`, `b`, `c`, …)
bold; use a manual label only when dark image plates or inset geometry make
patchwork tags misalign.

Use manual labels only when dark image plates or inset geometry make patchwork tags
misalign.

## Patchwork layout patterns

### Quantitative grid

```r
fig <- (p_a | p_b | guide_area()) /
       (p_c | p_d | p_e) +
  plot_layout(guides = "collect", widths = c(1, 1, 0.45)) &
  theme(legend.position = "right")
```

### Schematic-led composite

```r
design <- "
AAAA
BBCD
"
fig <- p_schematic + p_b + p_c + p_d +
  plot_layout(design = design, heights = c(1.8, 1))
```

### Image plate plus quant

Keep black backgrounds inside image panels only. Put scale bars on the image, then
place quantification next to or below the representative image.

```r
p_img <- ggplot(img_df, aes(x, y, fill = intensity)) +
  geom_raster() +
  scale_fill_gradient(low = "black", high = "white") +
  coord_fixed(expand = FALSE) +
  annotate("segment", x = 10, xend = 40, y = 10, yend = 10,
           linewidth = 0.6, colour = "white") +
  theme_void() +
  theme(legend.position = "none", plot.background = element_rect(fill = "black", colour = NA))
```

## Patchwork panel-alignment gate

`panel_alignment.R` converts the final patchwork gtable cells to physical-point
rectangles on a temporary R graphics device with the same dimensions as the
real export. It then invokes the backend-neutral
`audit_panel_alignment.py` JSON auditor. Python does not render or modify the R
figure.

Simple patchwork grids infer row/column groups from gtable cells. Structured
unequal-span designs are also automatic: two stacked panels in the left column
beside one two-row panel in the right column, and the mirrored arrangement,
receive shared top/bottom boundary checks without an invalid equal-height
comparison. Horizontal groups of three or four equal gtable spans must also
have equal final widths; intentional unequal widths require a reasoned
`panel-width` exemption. For nested or manually composed figures, declare the intended
comparisons explicitly:

```r
require_patchwork_panel_alignment(
  fig,
  manifest_path = "figures/fig2.alignment-layout.json",
  report_path = "figures/fig2.alignment.json",
  overlay_svg = "figures/fig2.alignment.svg",
  width_in = 183 / 25.4,
  height_in = 120 / 25.4,
  panel_ids = c("a", "b", "c", "d"),
  row_groups = list(c("a", "b"), c("c", "d")),
  column_groups = list(c("a", "c"), c("b", "d")),
  exemptions = list(
    list(
      panels = c("a"),
      checks = c("column", "panel-width"),
      reason = "hero panel intentionally spans the evidence columns"
    )
  ),
  tolerance_pt = 1.5,
  gutter_tolerance_pt = 1.5,
  strict = TRUE
)
```

Every exemption must name the panel, the exact check and the reason. Do not
increase the global tolerance to hide an inset, colorbar, legend-only cell or
hero panel. When strict QA is requested, a non-zero audit status stops the R
delivery script. Preserve the measured layout manifest and audit JSON only for
that QA run; the alignment SVG is QA-only.

## ComplexHeatmap export

`ComplexHeatmap` objects are grid objects, not ggplot objects. Export them by opening
the graphics device, drawing, then closing it.

```r
library(ComplexHeatmap)
library(circlize)

pdf("heatmap.pdf", width = 7.2, height = 4.8)
draw(ht, heatmap_legend_side = "right", annotation_legend_side = "right")
dev.off()

svglite::svglite("heatmap.svg", width = 7.2, height = 4.8)
draw(ht, heatmap_legend_side = "right", annotation_legend_side = "right")
dev.off()
```

## Template reuse rule

The local R materials are examples, not final style. When reusing them:

1. Inspect only the nearest template folder.
2. Keep useful data wrangling, statistics, and geoms.
3. Replace ad hoc colors, oversized fonts, dense legends, and PNG-only export.
4. Rebuild standard Cartesian plots around `theme_nature_quant()` and an explicit `ggplot2::ggsave()` call; retain a specialized theme for non-Cartesian plots.
5. Add source-data output if the figure is manuscript-facing.

Open `references/r-template-index.md` for the local template atlas.
