
context("Themes")

test_theme <- function(theme) {
  new_themes <- c("black-contrast", "dracula", "white-contrast")
  if (theme %in% new_themes) {
    return(NULL)
  }
  if(identical(theme, "custom"))
    return(NULL)
  test_that(paste(theme, "theme"), {
    # don't run on cran because pandoc is required
    skip_on_cran()

    # work in a temp directory
    tmpdir <- tempdir(check = TRUE)
    tstdir <- tempfile("revealjg-test", tmpdir)
    dir.create(tstdir)
    oldwd <- setwd(tstdir)
    on.exit(setwd(oldwd), add = TRUE)
    message("Set directory to temporary directory ", tstdir)

    # create a draft of a presentation
    testdoc <- "testdoc.Rmd"
    rmd_file <- rmarkdown::draft(
      testdoc,
      system.file("rmarkdown", "templates", "revealjs_presentation",
                  package = "revealjg"),
      create_dir = FALSE,
      edit = FALSE
      )

    # render it with the specified theme
    capture.output({
      output_file <- tempfile(fileext = ".html", tstdir)
      output_format <- revealjs_presentation(theme = theme)
      rmarkdown::render(rmd_file,
                        output_format = output_format,
                        output_file = output_file)
      expect_true(file.exists(output_file))
    })
  })
}

# test all themes
sapply(revealjg:::revealjs_themes(), test_theme)
