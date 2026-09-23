# R-ZYZ project management

Use these conventions for R analysis projects and R figure scripts. Inspect the
current project, its local instructions, scripts, and inputs before applying
them. An existing project's explicit rules take precedence; do not reorganize
it merely to match this layout. Keep source data and existing analysis choices
intact unless the user requests a change.

## New project layout

For a genuinely new analysis project, use only the directories needed by the
work:

```text
project/
├── 00.libs/             ordered R scripts
│   └── functions/       helpers reused by multiple scripts
├── 01.rawdata/          immutable inputs
├── 02.processed/        regenerable cleaned and intermediate data
├── 03.figure/           routine analysis figures
├── 04.datasave/         durable tables, statistics, and figure source data
│   └── Rdata/           .RData and .rds objects
└── 05.mainfigure/       curated manuscript figures
```

Do not create unused directories or placeholder files. `05.mainfigure/` is a
curated destination, not an automatic output of an analysis script. If the new
project has no `.Rproj`, use [create_rproj.R](../scripts/create_rproj.R) to
create `Visualization.Rproj`; retain any existing `.Rproj` and its settings.

## Script naming and directory mapping

Place ordered scripts under `00.libs/` with names like
`01.data_preparation.R`, `02.alpha_diversity.R`, and
`03.statistical_analysis.R`. The two-digit prefix indicates execution order;
the short purpose identifies the analysis. Existing `.Rmd` scripts may use
the same stem convention. Put a helper in `00.libs/functions/` only if more
than one script uses it.

Use the complete script stem, including the number and dot, for related
directories. For `00.libs/02.alpha_diversity.R`:

```text
01.rawdata/02.alpha_diversity/    only if this analysis has its own inputs
02.processed/02.alpha_diversity/  intermediate data from this analysis
03.figure/02.alpha_diversity/     routine figures from this analysis
```

Do not renumber existing scripts merely to insert a new step: the stem may
already be used by input paths and downstream outputs. Inspect callers and
existing files before renaming any script or mapped directory.

## Inputs and durable outputs

- Treat `01.rawdata/` as read-only. Resolve actual input files before running
  a script; do not infer that every input belongs in a script-specific folder.
- Write cleaned data and other regenerable intermediates to `02.processed/`.
- Put durable result tables, final statistics, supplementary tables, and
  figure source data in `04.datasave/`. Keep `.RData` and `.rds` in
  `04.datasave/Rdata/`; prefer `.rds` for a single object and provide a
  readable table for important results.
- Use concise, descriptive, space-free result names. Preserve the existing
  `M_` convention for core results or main-figure candidates and `S_` for
  exploratory or supplementary results. When importance is unclear, use `S_`.
- Use paths resolved from the project root and the actual script file, not
  from the current working directory alone. The optional
  [r_project_paths.R](../scripts/r_project_paths.R) helper implements this
  mapping. It computes paths only; it does not create directories or save
  results.
