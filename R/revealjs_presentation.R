#' Convert to a reveal.js presentation
#' 
#' Format for converting from R Markdown to a reveal.js presentation.
#' 
#' @inheritParams rmarkdown::beamer_presentation
#' @inheritParams rmarkdown::pdf_document
#' @inheritParams rmarkdown::html_document
#'   
#' @param center \code{TRUE} to vertically center content on slides
#' @param slide_level Level of heading to denote individual slides. If
#'   \code{slide_level} is 2 (the default), a two-dimensional layout will be
#'   produced, with level 1 headers building horizontally and level 2 headers
#'   building vertically. It is not recommended that you use deeper nesting of
#'   section levels with reveal.js.
#' @param theme Visual theme ("simple", "sky", "beige", "serif", "solarized",
#'   "blood", "moon", "night", "black", "league" or "white").
#' @param custom_theme Custom theme, not included in reveal.js distribution
#' @param custom_theme_dark Does the custom theme use a dark-mode?
#' @param transition Slide transition ("default", "none", "fade", "slide", 
#'   "convex", "concave" or "zoom")
#' @param custom_transition Custom slide transition, not included in reveal.js
#'   distribuion.
#' @param background_transition Slide background-transition ("default", "none",
#'   "fade", "slide", "convex", "concave" or "zoom")
#' @param custom_background_transition Custom background-transition, not 
#'   included in reveal.js distribuion.
#' @param reveal_options Additional options to specify for reveal.js (see 
#'   \href{https://github.com/hakimel/reveal.js#configuration}{https://github.com/hakimel/reveal.js#configuration}
#'   for details).
#' @param reveal_plugins Reveal plugins to include. Available plugins include "notes", 
#'   "search", and "zoom". Note that \code{self_contained} must be set to 
#'   \code{FALSE} in order to use Reveal plugins.
#' @param reveal_version Version of reveal.js to use.
#' @param reveal_location Location to search for reveal.js (Expects to find 
#' reveal.js distribution at 
#' \code{file.path(reveal_location, paste0('revealjs-', reveal_version))}
#' @param template Pandoc template to use for rendering. Pass "default" to use
#'   the rmarkdown package default template; pass \code{NULL} to use pandoc's
#'   built-in template; pass a path to use a custom template that you've
#'   created. Note that if you don't use the "default" template then some
#'   features of \code{revealjs_presentation} won't be available (see the
#'   Templates section below for more details).
#' @param custom_theme_path Path to custom theme css.
#' @param custom_transition_path Path to custom transition css.
#' @param resource_location Optional custom path to reveal.js templates and skeletons
#' @param ... Ignored
#'   
#' @return R Markdown output format to pass to \code{\link{render}}
#'   
#' @details
#' 
#' In reveal.js presentations you can use level 1 or level 2 headers for slides.
#' If you use a mix of level 1 and level 2 headers then a two-dimensional layout
#' will be produced, with level 1 headers building horizontally and level 2
#' headers building vertically.
#' 
#' For additional documentation on using revealjs presentations see
#' \href{https://github.com/jonathan-g/revealjs.jg}{https://github.com/jonathan-g/revealjs.jg}.
#'   
#' @examples
#' \dontrun{
#' 
#' library(rmarkdown)
#' library(revealjs.jg)
#' 
#' # simple invocation
#' render("pres.Rmd", revealjs_presentation())
#' 
#' # specify an option for incremental rendering
#' render("pres.Rmd", revealjs_presentation(incremental = TRUE))
#' }
#' 
#' 
#' @export
revealjs_presentation <- function(incremental = FALSE,
                                  center = FALSE,
                                  slide_level = 2,
                                  fig_width = 8,
                                  fig_height = 6,
                                  fig_retina = if (!fig_caption) 2,
                                  fig_caption = FALSE,
                                  smart = TRUE,
                                  self_contained = TRUE,
                                  theme = "simple",
                                  custom_theme = NULL,
                                  custom_theme_dark=FALSE,
                                  custom_theme_path=NULL,
                                  transition = "default",
                                  custom_transition = NULL,
                                  custom_transition_path = NULL,
                                  background_transition = "default",
                                  custom_background_transition = NULL,
                                  reveal_options = NULL,
                                  reveal_plugins = NULL,
                                  reveal_version = "3.3.0",
                                  reveal_location = "default",
                                  resource_location = "default",
                                  highlight = "default",
                                  mathjax = "default",
                                  template = "default",
                                  css = NULL,
                                  includes = NULL,
                                  keep_md = FALSE,
                                  lib_dir = NULL,
                                  pandoc_args = NULL,
                                  ...) {
  
  # function to lookup reveal resource
  reveal_resources <- function() {
    if(identical(resource_location, "default")) {
    system.file("rmarkdown/templates/revealjs_presentation/resources",
                package = "revealjs.jg")
    } else {
      resource_location
    }
  }
  
  # base pandoc options for all reveal.js output
  args <- c()
  
  # template path and assets
  if (identical(template, "default")) {
    default_template <- file.path(reveal_resources(), "default.html")
    args <- c(args, "--template", pandoc_path_arg(default_template))
  } else {
    args <- c(args, "--template",
              pandoc_path_arg(file.path(reveal_resources(), template)))
  }
  
  # incremental
  if (incremental)
    args <- c(args, "--incremental")
  
  # centering
  jsbool <- function(value) ifelse(value, "true", "false")
  args <- c(args, pandoc_variable_arg("center", jsbool(center)))
  
  # slide level
  args <- c(args, "--slide-level", as.character(slide_level))
  
  # theme
  theme <- match.arg(theme, revealjs_themes())
  theme_dark <- FALSE
  if (identical(theme, "custom")) {
    if (is.null(custom_theme)) 
    {
      stop("Missing custom_theme in YAML header")
    } else {
      theme <- custom_theme
      theme_dark <- custom_theme_dark
    }
  } else {
    if (identical(theme, "default"))
      theme <- "simple"
    else if (identical(theme, "dark"))
      theme <- "black"
    if (theme %in% c("black", "blood", "moon", "night"))
      theme_dark <- TRUE
  }
  if (theme_dark) {
    args <- c(args, "--variable", "theme-dark")
  }
  args <- c(args, "--variable", paste("theme=", theme, sep=""))
  
  
  # transition
  transition <- match.arg(transition, revealjs_transitions())
  if (identical(transition, "custom")) {
    if (is.null(custom_transition)) {
      stop("Missing custom_transition in YAML header")
    }
    else {
      transition <- custom_transition
    }
  }
  args <- c(args, "--variable", paste("transition=", transition, sep=""))
  
  # background_transition
  background_transition <- match.arg(background_transition, revealjs_transitions())
  args <- c(args, "--variable", paste("backgroundTransition=", background_transition, sep=""))
  
  # use history
  args <- c(args, pandoc_variable_arg("history", "true"))
  
  # additional reveal options
  if (is.list(reveal_options)) {
    for (option in names(reveal_options)) {
      value <- reveal_options[[option]]
      if (is.logical(value))
        value <- jsbool(value)
      else if (is.character(value))
        value <- paste0("'", value, "'")
      args <- c(args, pandoc_variable_arg(option, value))
    }
  }
  
  # reveal plugins
  if (is.character(reveal_plugins)) {
    
    # validate that we need to use self_contained for plugins
    if (self_contained)
      stop("Using reveal_plugins requires self_contained: false")
    
    # validate specified plugins are supported
    supported_plugins <- c("notes", "search", "zoom")
    invalid_plugins <- setdiff(reveal_plugins, supported_plugins)
    if (length(invalid_plugins) > 0)
      stop("The following plugin(s) are not supported: ",
           paste(invalid_plugins, collapse = ", "), call. = FALSE)
    
    # add plugins
    sapply(reveal_plugins, function(plugin) {
      args <<- c(args, pandoc_variable_arg(paste0("plugin-", plugin), "1"))
    })    
  }
  
  # content includes
  args <- c(args, includes_to_pandoc_args(includes))
  
  # additional css
  for (css_file in css)
    args <- c(args, "--css", pandoc_path_arg(css_file))
  
  # pre-processor for arguments that may depend on the name of the
  # the input file (e.g. ones that need to copy supporting files)
  pre_processor <- function(metadata, input_file, runtime, knit_meta, files_dir,
                            output_dir) {
    
    # we don't work with runtime shiny
    if (identical(runtime, "shiny")) {
      stop("revealjs_presentation is not compatible with runtime 'shiny'", 
           call. = FALSE)
    }
    
    # use files_dir as lib_dir if not explicitly specified
    if (is.null(lib_dir))
      lib_dir <- files_dir
    
    # extra args
    args <- c()
    
    # reveal.js
    reveal_home <- paste0("reveal.js-", reveal_version)
    if (identical(reveal_location, "default")) {
    revealjs_path <- system.file(reveal_home, package = "revealjs.jg")
    } else {
      revealjs_path <- file.path(reveal_location, reveal_home)
    }
    if (! identical(custom_theme_path, "default")) {
      custom_theme_path <-  revealjs_path
    }
    if (! identical(custom_transition_path, "default")) {
      custom_transition_path <- revealjs_path
    }
    if (!self_contained || identical(.Platform$OS.type, "windows")) {
      revealjs_path <- relative_to(
        output_dir, render_supporting_files(revealjs_path, lib_dir))
      custom_theme_path <- relative_to(
        output_dir, render_supporting_files(custom_theme_path, lib_dir))
      custom_transition_path <- relative_to(
        output_dir, render_supporting_files(custom_transition_path, lib_dir))
    }else  {
      revealjs_path <- pandoc_path_arg(revealjs_path)
      custom_theme_path <- pandoc_path_arg(custom_theme_path)
      custom_transition_path <- pandoc_path_arg(custom_transition_path)
    }
    args <- c(args, "--variable", paste0("revealjs-url=", revealjs_path),
              "--variable", paste0("local-theme-url=", custom_theme_path),
              "--variable", paste0("local-transition-url=", custom_transition_path))

    # highlight
    args <- c(args, pandoc_highlight_args(highlight, default = "pygments"))
    
    # return additional args
    args
  }
  
  # return format
  output_format(
    knitr = knitr_options_html(fig_width, fig_height, fig_retina, keep_md),
    pandoc = pandoc_options(to = "revealjs",
                            from = rmarkdown_format(ifelse(fig_caption, 
                                                           "", 
                                                           "-implicit_figures")),
                            args = args),
    keep_md = keep_md,
    clean_supporting = self_contained,
    pre_processor = pre_processor,
    base_format = html_document_base(smart = smart, lib_dir = lib_dir,
                                     self_contained = self_contained,
                                     mathjax = mathjax,
                                     pandoc_args = pandoc_args, ...))
}

revealjs_themes <- function() {
  c("default",
    "dark",
    "beige",
    "black",
    "blood",
    "league",
    "moon",
    "night",
    "serif",
    "simple",
    "sky",
    "solarized",
    "white",
    "custom")
}


revealjs_transitions <- function() {
  c(
    "default",
    "none",
    "fade",
    "slide",
    "convex",
    "concave",
    "zoom",
    "custom"
    )
}


