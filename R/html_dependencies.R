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
      message("Dependency: (", paste0(class(dependencies[[i]]),
                                      collapse = ", "), ")")
      message(str(dependencies[[i]]))
    }
    message("Copying dependencies ...")
    dependencies <- lapply(dependencies, verifyDependencyFiles, lib_dir,
                           )
    message("Making dependencies relative...")
    dependencies <- lapply(dependencies, makeDependencyRelative, output_dir)
    message("Done.")
  }
  return(renderDependencies(dependencies, "file", encodeFunc = identity,
                            hrefFilter = function(path) {
                              rmarkdown:::html_reference_path(path, lib_dir,
                                                              output_dir)
                            })
  )
}
