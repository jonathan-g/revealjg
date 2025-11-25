#
# These functions are taken from html_dependencies.R in
# rmarkdown.
#

# return the html dependencies as an HTML string suitable for inclusion
# in the head of a document
html_dependencies_as_string <- function(dependencies, lib_dir, output_dir) {

  if (!is.null(lib_dir)) {
    message("From revealjg: Dependencies = [", paste0(
      lapply(dependencies, function(x) {
        paste0("(", paste(class(x), collapse = ", "), ")")
      }), collapse = ", "), "]")
    for (i in seq_along(dependencies)) {
      message("Dependency: (", paste0(class(dependencies[[i]]), collapse = ", "), ")")
      message(utils::str(dependencies[[i]]))
    }
    message("Copying dependencies ...")
    dependencies <- lapply(dependencies, copyDependencyToDir, lib_dir)
    message("Making dependencies relative...")
    dependencies <- lapply(dependencies, makeDependencyRelative, output_dir)
    message("Done.")
  }
  return(renderDependencies(dependencies, "file", encodeFunc = identity,
                            hrefFilter = function(path) {
                              html_reference_path(path, lib_dir, output_dir)
                            })
  )
}

# check class of passed list for 'html_dependency'
is_html_dependency <- function(list) {
  inherits(list, "html_dependency")
}

# validate that the passed list is a correctly formed html_dependency
validate_html_dependency <- function(list) {

  # ensure it's the right class
  if (!is_html_dependency(list))
    stop("passed object is not of class html_dependency", call. = FALSE)

  # validate required fields
  if (is.null(list$name))
    stop("name for html_dependency not provided", call. = FALSE)
  if (is.null(list$version))
    stop("version for html_dependency not provided", call. = FALSE)
  list <- fix_html_dependency(list)
  if (is.null(list$src$file))
    stop("path for html_dependency not provided", call. = FALSE)
  file <- list$src$file
  if (!is.null(list$package))
    file <- system.file(file, package = list$package)
  if (!file.exists(file)) {
    utils::str(list)
    stop("path for html_dependency not found: ", file, call. = FALSE)
  }

  list
}

# monkey patch HTML dependencies; currently only supports highlight.js
fix_html_dependency <- function(list) {
  if (!identical(list$name, 'highlightjs') || !identical(list$version, '1.1'))
    return(list)
  if (!identical(list$src$file, '')) return(list)
  rmarkdown::html_dependency_highlightjs(gsub('[.]css$', '', list$stylesheet))
}

# consolidate dependencies (use latest versions and remove duplicates). this
# routine is the default implementation for version dependency resolution;
# formats may specify their own.
html_dependency_resolver <- function(all_dependencies) {

  dependencies <- htmltools::resolveDependencies(all_dependencies)

  # validate each surviving dependency
  dependencies <- lapply(dependencies, validate_html_dependency)

  # return the consolidated dependencies
  dependencies
}

