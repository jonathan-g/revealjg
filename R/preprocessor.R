# pre_processor
pre_processor <- function(metadata, input_file, runtime, knit_meta,
                          files_dir, output_dir) {

  args <- c()

  # use files_dir as lib_dir if not explicitly specified
  if (is.null(lib_dir))
    lib_dir <<- files_dir

  # copy supplied output_dir (for use in post-processor)
  output_dir <<- output_dir

  # handle theme
  if (!is.null(theme)) {
    theme <- match.arg(theme, themes())
    if (identical(theme, "default"))
      theme <- "bootstrap"
    args <- c(args, "--variable", paste0("theme:", theme))
  }

  # resolve and inject extras, including dependencies specified by the format
  # and dependencies specified by the user (via extra_dependencies)
  format_deps <- list()
  format_deps <- append(format_deps, rmarkdown::html_dependency_header_attrs())
  if (!is.null(theme)) {
    format_deps <- append(format_deps,
                          list(rmarkdown::html_dependency_jquery(),
                               rmarkdown::html_dependency_bootstrap(theme)))
  }
  else if (isTRUE(bootstrap_compatible) && rmarkdown::is_shiny(runtime)) {
    # If we can add bootstrap for Shiny, do it
    format_deps <- append(format_deps,
                          list(rmarkdown::html_dependency_bootstrap("bootstrap")))
  }
  format_deps <- append(format_deps, extra_dependencies)

  dependency_resolver <- rmarkdown:::html_dependency_resolver

  extras <- html_extras_for_document(knit_meta, runtime, dependency_resolver,
                                     format_deps)
  args <- c(args, pandoc_html_extras_args(extras, self_contained, lib_dir,
                                          output_dir))

  # mathjax
  args <- c(args, pandoc_mathjax_args(mathjax,
                                      template,
                                      self_contained,
                                      lib_dir,
                                      output_dir))

  preserved_chunks <<- rmarkdown::extract_preserve_chunks(input_file)

  # a lua filters added if pandoc2.0
  args <- c(args, pandoc_lua_filters(c("pagebreak.lua", "latex-div.lua")))

  args
}

# convert html extras to the pandoc args required to include them
pandoc_html_extras_args <- function(extras, self_contained, lib_dir,
                                    output_dir) {

  args <- c()

  # dependencies
  dependencies <- extras$dependencies
  if (length(dependencies) > 0) {
    if (self_contained)
      file <- as_tmpfile(html_dependencies_as_string(dependencies, NULL, NULL))
    else
      file <- as_tmpfile(html_dependencies_as_string(dependencies, lib_dir,
                                                     output_dir))
    args <- c(args, pandoc_include_args(in_header = file))
  }

  # extras
  args <- c(args, pandoc_include_args(
    in_header = as_tmpfile(extras$in_header),
    before_body = as_tmpfile(extras$before_body),
    after_body = as_tmpfile(extras$after_body)))

  args
}
