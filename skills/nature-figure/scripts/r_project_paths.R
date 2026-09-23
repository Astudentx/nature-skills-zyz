# R-ZYZ project path helpers. Sourcing this file makes no filesystem changes.

script_stem <- function(script_file) {
  if (length(script_file) != 1L || is.na(script_file) || !file.exists(script_file)) {
    stop("script_file must name one existing R or Rmd script.", call. = FALSE)
  }
  if (!grepl("\\.(R|Rmd)$", basename(script_file), ignore.case = TRUE)) {
    stop("script_file must have a .R or .Rmd extension.", call. = FALSE)
  }
  sub("\\.(R|Rmd)$", "", basename(script_file), ignore.case = TRUE)
}

resolve_project_root <- function(script_file, project_root = NULL) {
  if (!is.null(project_root)) {
    if (length(project_root) != 1L || is.na(project_root)) {
      stop("project_root must name one existing project directory.", call. = FALSE)
    }
    project_root <- normalizePath(project_root, mustWork = TRUE)
    if (!dir.exists(file.path(project_root, "00.libs"))) {
      stop("project_root must contain 00.libs/.", call. = FALSE)
    }
    return(project_root)
  }

  if (length(script_file) != 1L || is.na(script_file) || !file.exists(script_file)) {
    stop("script_file must name one existing R or Rmd script.", call. = FALSE)
  }
  current <- normalizePath(dirname(script_file), mustWork = TRUE)
  repeat {
    if (dir.exists(file.path(current, "00.libs"))) return(current)
    parent <- dirname(current)
    if (identical(parent, current)) break
    current <- parent
  }
  stop("Cannot find a project root containing 00.libs/. Supply project_root explicitly.", call. = FALSE)
}

script_output_paths <- function(script_file, project_root = NULL) {
  root <- resolve_project_root(script_file, project_root)
  stem <- script_stem(script_file)
  list(
    root = root,
    rawdata = file.path(root, "01.rawdata", stem),
    processed = file.path(root, "02.processed", stem),
    figure = file.path(root, "03.figure", stem),
    datasave = file.path(root, "04.datasave"),
    rdata = file.path(root, "04.datasave", "Rdata"),
    mainfigure = file.path(root, "05.mainfigure")
  )
}
