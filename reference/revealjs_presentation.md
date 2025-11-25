# Convert to a reveal.js presentation

Format for converting from R Markdown to a reveal.js presentation.

## Usage

``` r
revealjs_presentation(
  incremental = FALSE,
  center = FALSE,
  width = NULL,
  height = NULL,
  margin = NULL,
  slide_level = 2,
  fig_width = 8,
  fig_height = 6,
  fig_retina = if (!fig_caption) 2,
  fig_caption = FALSE,
  self_contained = TRUE,
  smart = TRUE,
  theme = "simple",
  custom_theme = NULL,
  custom_theme_dark = FALSE,
  custom_asset_path = NULL,
  transition = "default",
  custom_transition = NULL,
  background_transition = "default",
  custom_background_transition = NULL,
  reveal_options = NULL,
  reveal_plugins = NULL,
  reveal_version = "5.2.1",
  reveal_location = "default",
  resource_location = "default",
  controls = FALSE,
  highlight = "default",
  mathjax = "default",
  mathjax_scale = NULL,
  tex_extensions = NULL,
  tex_defs = NULL,
  template = "default",
  css = NULL,
  includes = NULL,
  md_extensions = NULL,
  keep_md = FALSE,
  lib_dir = NULL,
  pandoc_args = NULL,
  extra_dependencies = NULL,
  custom_plugins = NULL,
  no_postprocess = FALSE,
  ...
)
```

## Arguments

- incremental:

  `TRUE` to render slide bullets incrementally. Note that if you want to
  reverse the default incremental behavior for an individual bullet you
  can precede it with `>`. For example: *`> - Bullet Text`*. See more in
  [Pandoc's Manual](https://pandoc.org/MANUAL.html#incremental-lists)

- center:

  `TRUE` to vertically center content on slides

- width:

  `NULL` to override default width (pixels)

- height:

  `NULL` to override default height (pixels)

- margin:

  `NULL` to override default margin around the slides.

- slide_level:

  Level of heading to denote individual slides. If `slide_level` is 2
  (the default), a two-dimensional layout will be produced, with level 1
  headers building horizontally and level 2 headers building vertically.
  It is not recommended that you use deeper nesting of section levels
  with reveal.js.

- fig_width:

  Default width (in inches) for figures

- fig_height:

  Default height (in inches) for figures

- fig_retina:

  Scaling to perform for retina displays (defaults to 2, which currently
  works for all widely used retina displays). Set to `NULL` to prevent
  retina scaling. Note that this will always be `NULL` when `keep_md` is
  specified (this is because `fig_retina` relies on outputting HTML
  directly into the markdown document).

- fig_caption:

  `TRUE` to render figures with captions

- self_contained:

  Whether to generate a full LaTeX document (`TRUE`) or just the body of
  a LaTeX document (`FALSE`). Note the LaTeX document is an intermediate
  file unless `keep_tex = TRUE`.

- smart:

  Use smartypants transformations for special characters and
  punctuation.

- theme:

  Visual theme ("simple", "sky", "beige", "moon", "night", "solarized",
  "league", "serif", "blood", "dracula", "black", "black-contrast",
  "white", or "white-contrast").

- custom_theme:

  Custom theme, not included in reveal.js distribution

- custom_theme_dark:

  Does the custom theme use a dark-mode?

- custom_asset_path:

  Path to custom theme css.

- transition:

  Slide transition ("default", "none", "fade", "slide", "convex",
  "concave" or "zoom")

- custom_transition:

  Custom slide transition, not included in reveal.js distribuion.

- background_transition:

  Slide background-transition ("default", "none", "fade", "slide",
  "convex", "concave" or "zoom")

- custom_background_transition:

  Custom background-transition, not included in reveal.js distribuion.

- reveal_options:

  Additional options to specify for reveal.js (see
  <https://github.com/hakimel/reveal.js#configuration> for details).

- reveal_plugins:

  Reveal plugins to include. Available plugins include "notes",
  "search", "zoom", "chalkboard", and "menu". Note that `self_contained`
  must be set to `FALSE` in order to use Reveal plugins.

- reveal_version:

  Version of reveal.js to use.

- reveal_location:

  Location to search for reveal.js (Expects to find reveal.js
  distribution at
  `file.path(reveal_location, paste0('revealjs-', reveal_version))`

- resource_location:

  Optional custom path to reveal.js templates and skeletons

- controls:

  `TRUE` to show navigation controls on slides

- highlight:

  Syntax highlighting style passed to Pandoc.

  Supported built-in styles include "default", "tango", "pygments",
  "kate", "monochrome", "espresso", "zenburn", "haddock", and
  "breezedark".

  Two custom styles are also included, "arrow", an accessible color
  scheme, and "rstudio", which mimics the default IDE theme.
  Alternatively, supply a path to a `.theme` file to use [a custom
  Pandoc style](https://pandoc.org/MANUAL.html#syntax-highlighting).
  Note that custom theme requires Pandoc 2.0+.

  Pass `NULL` to prevent syntax highlighting.

- mathjax:

  Include mathjax. The "default" option uses an https URL from a MathJax
  CDN. The "local" option uses a local version of MathJax (which is
  copied into the output directory). You can pass an alternate URL or
  pass `NULL` to exclude MathJax entirely.

- mathjax_scale:

  Scale (in percent) for MathJax. Default = 100

- tex_extensions:

  LaTeX extensions for MathJax

- tex_defs:

  LaTeX macro definitions for MathJax

- template:

  Pandoc template to use for rendering. Pass "default" to use the
  rmarkdown package default template; pass `NULL` to use pandoc's
  built-in template; pass a path to use a custom template that you've
  created. Note that if you don't use the "default" template then some
  features of `revealjs_presentation` won't be available (see the
  Templates section below for more details).

- css:

  CSS and/or Sass files to include. Files with an extension of .sass or
  .scss are compiled to CSS via
  [`sass::sass()`](https://rstudio.github.io/sass/reference/sass.html).
  Also, if `theme` is a
  [`bslib::bs_theme()`](https://rstudio.github.io/bslib/reference/bs_theme.html)
  object, Sass code may reference the relevant Bootstrap Sass variables,
  functions, mixins, etc.

- includes:

  Named list of additional content to include within the document
  (typically created using the
  [`includes`](https://pkgs.rstudio.com/rmarkdown/reference/includes.html)
  function).

- md_extensions:

  Pandoc markdown extensions

- keep_md:

  Keep the markdown file generated by knitting.

- lib_dir:

  Directory to copy dependent HTML libraries (e.g. jquery, bootstrap,
  etc.) into. By default this will be the name of the document with
  `_files` appended to it.

- pandoc_args:

  Additional command line options to pass to pandoc

- extra_dependencies:

  Additional function arguments to pass to the base R Markdown HTML
  output formatter
  [`rmarkdown::html_document_base()`](https://pkgs.rstudio.com/rmarkdown/reference/html_document_base.html).

- custom_plugins:

  Add custom plugins to the list of supported plugins.

- no_postprocess:

  Omit the post-processing step.

- ...:

  Ignored

## Value

R Markdown output format to pass to
[`render`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)

## Details

In reveal.js presentations you can use level 1 or level 2 headers for
slides. If you use a mix of level 1 and level 2 headers then a
two-dimensional layout will be produced, with level 1 headers building
horizontally and level 2 headers building vertically.

For additional documentation on using revealjs presentations see
<https://github.com/jonathan-g/revealjg>.

## Examples

``` r
if (FALSE) { # \dontrun{

library(rmarkdown)
library(revealjg)

# simple invocation
render("pres.Rmd", revealjs_presentation())

# specify an option for incremental rendering
render("pres.Rmd", revealjs_presentation(incremental = TRUE))
} # }

```
