## revealjs.jg 0.9.9001

* Fix handling of markdown extensions to work with Pandoc 2.0.0.1

* Fixed problems with calculating markdown_extensions when user had not 
  specified any overrides with md_extensions.

* Added News.md

* Fixed problems with imports in revealjs.R
* Fixed imports in DESCRIPTION
* Fixed globalVariables so the package passes checks without any errors, 
  warnings, or notes.

## revealjs.jg 0.8.9003

* Merge rstudio-master version 0.9

## revealjs.jg 0.8.9002

* Fix calculation of path to reveal.js library
* Merge rstudio-master version 0.8


## revealjs.jg 0.8.9000

* Major merge with rstudio-master version
* Options for:
    * Setting reveal.js controls in YAML header
    * Setting md_extensions and mathjax_scale arguments in
      header revealjs_jg YAML options
    * Specifying margins, height, and width of slides in YAML
    * Handle YAML argument tex_defs to define macros for MathJax
    * Got rid of unnecessary "custom_transition_path"
* Added missing documentation for custom reveal.js themes