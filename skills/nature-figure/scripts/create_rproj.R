# Create a new RStudio project file while preserving an existing one.

create_rproj <- function(project_dir, project_name = "Visualization") {
  if (length(project_dir) != 1L || is.na(project_dir) || !dir.exists(project_dir)) {
    stop("project_dir must name one existing project directory.", call. = FALSE)
  }
  if (length(project_name) != 1L || is.na(project_name) ||
      !grepl("^[A-Za-z0-9][A-Za-z0-9._-]*$", project_name)) {
    stop("project_name must be a concise, space-free filename stem.", call. = FALSE)
  }

  project_dir <- normalizePath(project_dir, mustWork = TRUE)
  existing <- list.files(project_dir, pattern = "\\.Rproj$", full.names = TRUE, ignore.case = TRUE)
  if (length(existing) > 0L) {
    message("Existing RStudio project preserved: ", existing[[1]])
    return(invisible(existing[[1]]))
  }

  target <- file.path(project_dir, paste0(project_name, ".Rproj"))
  settings <- c(
    "Version: 1.0",
    "",
    "RestoreWorkspace: No",
    "SaveWorkspace: No",
    "AlwaysSaveHistory: Default",
    "",
    "EnableCodeIndexing: Yes",
    "UseSpacesForTab: Yes",
    "NumSpacesForTab: 2",
    "Encoding: UTF-8",
    "RnwWeave: Sweave",
    "LaTeX: pdfLaTeX"
  )
  writeLines(settings, target, useBytes = TRUE)
  invisible(normalizePath(target, mustWork = TRUE))
}
