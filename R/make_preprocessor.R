# pre_processor
make_preprocessor <- function(self_contained,
                              lib_dir,
                              mathjax,
                              pandoc_args,
                              template,
                              dependency_resolver,
                              copy_resources,
                              extra_dependencies,
                              bootstrap_compatible) {
  preserved_chunks <<- list()
  pre_processor <- function(metadata, input_file, runtime, knit_meta,
                            files_dir, output_dir) {
    args <- c()

    # use files_dir as lib_dir if not explicitly specified
    if (is.null(lib_dir))
      lib_dir <<- files_dir

    # copy supplied output_dir (for use in post-processor)
    output_dir <<- output_dir

    # resolve and inject extras, including dependencies specified by the format
    # and dependencies specified by the user (via extra_dependencies)
    format_deps <- list()
    format_deps <- append(format_deps, html_dependency_header_attrs())
    format_deps <- append(format_deps, extra_dependencies)

    dependency_resolver <- rmarkdown:::html_dependency_resolver

    extras <- rmarkdown:::html_extras_for_document(knit_meta, runtime, dependency_resolver,
                                       format_deps)
    args <- c(args, rmarkdown:::pandoc_html_extras_args(extras, self_contained, lib_dir,
                                            output_dir))

    # mathjax
    args <- c(args, rmarkdown:::pandoc_mathjax_args(mathjax,
                                        template,
                                        self_contained,
                                        lib_dir,
                                        output_dir))

    preserved_chunks <<- rmarkdown:::extract_preserve_chunks(input_file)

    # a lua filters added if pandoc2.0
    args <- c(args, rmarkdown:::pandoc_lua_filters(c("pagebreak.lua",
                                                     "latex-div.lua")))

    args
  }
  invisible(pre_processor)
}

# # convert html extras to the pandoc args required to include them
# pandoc_html_extras_args <- function(extras, self_contained, lib_dir,
#                                     output_dir) {
#
#   args <- c()
#
#   # dependencies
#   dependencies <- extras$dependencies
#   if (length(dependencies) > 0) {
#     if (self_contained)
#       file <- rmarkdown:::as_tmpfile(
#         html_dependencies_as_string(dependencies, NULL, NULL))
#     else
#       file <- rmarkdown:::as_tmpfile(
#         html_dependencies_as_string(dependencies, lib_dir, output_dir))
#     args <- c(args, pandoc_include_args(in_header = file))
#   }
#
#   # extras
#   args <- c(args, pandoc_include_args(
#     in_header = rmarkdown:::as_tmpfile(extras$in_header),
#     before_body = rmarkdown:::as_tmpfile(extras$before_body),
#     after_body = rmarkdown:::as_tmpfile(extras$after_body)))
#
#   args
# }
#
# # resolve the html extras for a document (dependencies and arbitrary html to
# # inject into the document)
# html_extras_for_document <- function(knit_meta, runtime, dependency_resolver,
#                                      format_deps = NULL) {
#
#   extras <- list()
#
#   # merge the dependencies discovered with the dependencies of this format and
#   # dependencies discovered in knit_meta
#   all_dependencies <- if (is.null(format_deps)) list() else format_deps
#   all_dependencies <- append(all_dependencies,
#                              rmarkdown:::flatten_html_dependencies(knit_meta))
#   extras$dependencies <- dependency_resolver(all_dependencies)
#
#   # return extras
#   extras
# }

# Pandoc 2.9 adds attributes on both headers and their parent divs. We remove
# the ones on headers since they are unnecessary (#1723).
html_dependency_header_attrs <- function() {
  if (pandoc_available('2.9')) list(
    htmlDependency(
      "header-attrs",
      version = packageVersion("revealjg"),
      src = system.file("rmd/h/pandoc", package="revealjg"),
      script = "header-attrs.js"
    )
  )
}
