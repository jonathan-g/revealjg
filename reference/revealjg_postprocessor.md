# Postprocess a reveal.js HTML file

Postprocesses a reveal.js HTML file to modify list items with
user-supplied classes.

## Usage

``` r
revealjg_postprocessor(metadata, input_file, output_file, clean, verbose)
```

## Arguments

- metadata:

  YAML metadata passed by
  [`rmarkdown::render`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)

- input_file:

  The RMarkdown source file

- output_file:

  The HTML file produced by Pandoc

- clean:

  A logical value indicating whether to delete the intermediate files
  after rendering.

- verbose:

  Issue verbose progress reports while rendering.

## Value

A character string with the name of the output file.

    * {+4} This has index 4, so it appears out of order
    * {+1:blue} This fragment uses the `highlight-blue` class.
    * {+3:cred} This fragment has index 3 and uses the `highlight-current-red`
      class
    * {+2:grow} This fragment grows when it's activated
    * {.fragment .grow data-fragment-index="1"} This fragment grows at the same
      time the first one appears.

Options for fragment style include:

- Colors: `red`, `green`, `blue`, `med-blue`, and `dark-green`

- Current colors: `cred`, `cgreen`, `cblue`, `cmed-blue`, and
  `cdark-green`

- Other: `grow`, `shrink`, `strike`, `semi-fade-out`, `fade-out`,
  `fade-up`, `fade-down`, `fade-left`, `fade-right`, `fade-in-then-out`,
  and `fade-in-then-semi-out`

## Details

This function is predominantly intended for giving finer-scale control
to fragments in lists. From the RMarkdown perspective, a list item can
be modified by adding metadata in curly braces immediately after the
`*`.

The contents of the braces are parsed for classes and fragment indices.
Examples include:

    * {.fragment} This is a simple fragment.
    * {+} This is another simple fragment.

You can also play with fragment indices to control the order in which
fragments appear, but if you do then you need to set the indices for
every fragment in the list. You can also add classes to control what the
fragments do when they're activated.
