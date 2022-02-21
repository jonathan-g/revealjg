#' Postprocess a reveal.js HTML file
#'
#' Postprocesses a reveal.js HTML file to modify list items with user-supplied
#' classes.
#'
#' This function is predominantly intended for giving finer-scale control to
#' fragments in lists. From the RMarkdown perspective, a list item can be
#' modified by adding metadata in curly braces immediately after the `*`.
#'
#' The contents of the braces are parsed for classes and fragment indices.
#' Examples include:
#'
#' ```
#' * {.fragment} This is a simple fragment.
#' * {+} This is another simple fragment.
#' ```
#'
#' You can also play with fragment indices to control the order in which
#' fragments appear, but if you do then you need to set the indices for every
#' fragment in the list. You can also add classes to control what the fragments
#' do when they're activated.
#'
#' @param metadata YAML metadata passed by \code{rmarkdown::render}
#' @param input_file The RMarkdown source file
#' @param output_file The HTML file produced by Pandoc
#' @param clean A logical value indicating whether to delete the intermediate
#'   files after rendering.
#' @param verbose Issue verbose progress reports while rendering.
#'
#' @return A character string with the name of the output file.
#'
#' ```
#' * {+4} This has index 4, so it appears out of order
#' * {+1:blue} This fragment uses the `highlight-blue` class.
#' * {+3:cred} This fragment has index 3 and uses the `highlight-current-red`
#'   class
#' * {+2:grow} This fragment grows when it's activated
#' * {.fragment .grow data-fragment-index="1"} This fragment grows at the same
#'   time the first one appears.
#' ```
#'
#' Options for fragment style include:
#' * Colors:  `red`, `green`, `blue`, `med-blue`, and `dark-green`
#' * Current colors:  `cred`, `cgreen`, `cblue`, `cmed-blue`, and `cdark-green`
#' * Other: `grow`, `shrink`, `strike`, `semi-fade-out`, `fade-out`,
#'   `fade-up`, `fade-down`, `fade-left`, `fade-right`, `fade-in-then-out`,
#'   and `fade-in-then-semi-out`
#'
revealjg_postprocessor <- function(metadata, input_file, output_file, clean, verbose) {
  if (verbose) {
    message("Revealjg postprocessor starting...")
  }

  color_list = c("red", "green", "blue", "med-blue", "dark-green")

  ht <- xml2::read_html(output_file)
  nodes <- xml2::xml_find_all(ht, xpath = "//*/li[starts-with(normalize-space(text()), '{')]")
  alt_nodes <- xml2::xml_find_all(ht, xpath = "//*/li[normalize-space(text()) = '']/p[(position() = 1) and starts-with(normalize-space(text()), '{')]")
  li_nodes <- nodes %>% purrr::keep(~xml2::xml_name(xml2::xml_contents(.x)[1]) == "text" &&
                                      stringr::str_detect(xml2::xml_text(xml2::xml_contents(.x)[1]), "^ *\\{[^{]"))
  alt_li_nodes <- alt_nodes %>% purrr::keep(~xml2::xml_name(xml2::xml_contents(.x)[1]) == "text" &&
                                              stringr::str_detect(xml2::xml_text(xml2::xml_contents(.x)[1]), "^ *\\{[^{]"))
  if (verbose) {
    message("Found ", length(li_nodes), " regular nodes and ", length(alt_li_nodes), " alt nodes.")
  }
  index <- 0
  for (n in c(li_nodes, alt_li_nodes)) {
    index <- index + 1
    if (verbose) {
      message("Node ", index, ": ", n)
    }
    head_text <- xml2::xml_contents(n)[1]
    if (xml2::xml_name(head_text) != "text") {
      warning("head_text has type \"", xml2::xml_name(head_text), "\"")
    }
    parts <- stringr::str_match(xml2::xml_text(head_text),
                                stringr::regex("^ *\\{(?<meta>[^}]+)\\} *(?<rest>.*)$",
                                               dotall=TRUE))[1,]
    meta <- stringr::str_trim(parts[2])
    rest <- parts[3]

    # If the string begins with "+", it's a fragment.
    frag <- stringr::str_starts(meta, stringr::fixed("+"))

    # Multiple ways of specifying a fragment index:
    # Start with a "+" and then a digit with optional intervening spaces or
    # non-digit characters followed by a space.
    idx  <- stringr::str_match(meta, "^\\+([^[:digit:]]* )?([[:digit:]]+)")[1,3]
    if (is.na(idx)) {
      # An alternate way is to specify a digit separated by spaces before and after from
      # anything else.
      idx <- stringr::str_match(meta, "(?<![^[:space:]])([[:digit:]]+)(?![^[:space:]])")[1,2]
    }
    if (is.na(idx)) {
      # A final way is to use the "data-fragment-index" attribute.
      idx <- stringr::str_match(meta, "(?<!^[:space:]])data-fragment-index *= *['\"]([[:digit:]]+)['\"](?![^[:space:]])")[1,2]
    }
    if (! is.na(idx)) {
      idx <- as.integer(idx)
    }

    # Classes specified by initial period.
    classes <- stringr::str_match_all(meta, "(?<![^[:space:]])\\.([a-zA-Z-]+(?![^[:space:]]))")[[1]][,2]
    if ("fragment" %in% classes) {
      frag <- TRUE
    } else if (frag) {
      classes <- c(classes, "fragment")
    }

    # Classes specified by initial colon.
    x_class <- stringr::str_match_all(meta, ":([a-z-]+)")[[1]][,2]
    if (verbose) {
      message("Found ", length(x_class), " x-classes")
    }
    if (length(x_class) > 0) {
      if (verbose) {
        message("x_class = [", stringr::str_c(x_class, collapse = ", "), "]")
      }

      color_pat <- stringr::str_c("^(",
                                  stringr::str_c(color_list, collapse = "|"),
                                  ")")
      cur_color_pat <- stringr::str_c("^c(",
                                      stringr::str_c(color_list, collapse = "|"),
                                      ")")

      c_class <- x_class %>%
        purrr::keep(~stringr::str_detect(.x, color_pat))
      x_class <- x_class %>% setdiff(c_class)
      cc_class <- x_class %>%
        purrr::keep(~stringr::str_detect(.x, cur_color_pat))
      x_class <- x_class %>% setdiff(cc_class)
      if (verbose) {
        message("x_class = [", stringr::str_c(x_class, collapse = ", "), "]")
        message("c_class = [", stringr::str_c(c_class, collapse = ", "), "]")
        message("cc_class = [", stringr::str_c(cc_class, collapse = ", "), "]")
      }
      if (length(c_class) > 0) {
        c_class <- stringr::str_c("highlight", c_class, sep = "-")
      }
      if (length(cc_class) > 0) {
        cc_class <- cc_class %>%
          stringr::str_replace(cur_color_pat, "\\1") %>%
          stringr::str_c("highlight", "current", ., sep = "-")
      }
      if (verbose) {
        message("x_class = [", stringr::str_c(x_class, collapse = ", "), "]")
        message("c_class = [", stringr::str_c(c_class, collapse = ", "), "]")
        message("cc_class = [", stringr::str_c(cc_class, collapse = ", "), "]")
      }
      classes <- c(classes, x_class, c_class, cc_class)
    }
    classes <- unique(classes)

    if (verbose) {
      message("Classes = [", stringr::str_c(classes, collapse = ", "), "]")
    }

    if (frag) {
      n_name <- xml2::xml_name(n)
      if (n_name == "li") {
        np <- n
      } else {
        if (n_name != "p") {
          warning("node isn't li or p: it's ", n_name)
        }
        np <- xml2::xml_parent(n)
        p_name <- xml2::xml_name(np)
        if (p_name != "li") {
          warning("parent of ", n_name, " is a ", p_name)
        }
      }
      node_classes <- xml2::xml_attr(np, "class")
      if (!is.na(node_classes)) {
        node_classes <- stringr::str_split(node_classes, " ")[[1]]
        classes <- c(classes, node_classes)
      }
      classes <- classes %>% unique() %>% stringr::str_c(collapse = " ") %>%
        stringr::str_trim()
      xml2::xml_set_attr(np, "class", classes)
      if (! is.na(idx)) {
        xml2::xml_set_attr(np, "data-fragment-index", idx)
      }
      xml2::xml_set_text(n, rest)
    }
  }

  if (verbose) {
    message("Getting ready to write file to disk.")
  }
  if (!clean) {
    temp_file <- file.path(dirname(output_file),
                           stringr::str_c("tmp_", basename(output_file)))
    if (file.exists(temp_file)) {
      file.remove(temp_file)
    }
    file.rename(output_file, temp_file)
  }
  xml2::write_html(ht, file = output_file)
  output_file
}
