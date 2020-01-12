# Functions in this file are adapted from html_dependency.R in htmltools

# Split a path into a vector of directory/file names.
# Reverse the process with do.call(file.path, res)
split_path <- function(p) {
  res <- character(0)
  repeat {
    d <- dirname(p)
    b <- basename(p)
    res <- c(b, res)
    if (d == p) break
    p <- d
  }
  res
}

# given a directory and a file, return a relative path from the directory to the
# file. This differs from htmltools::relativeTo because it does not require that
# `file`` be a descendant of `dir`: `file` and `dir` can be on different
# branches of a parent node.
relative_to <- function(dir, file) {
  val <- NA

  message('relativeTo("', dir, '", "', file, '")')
  ndir <- normalizePath(dir, mustWork = FALSE)
  nfile <- normalizePath(file, mustWork = FALSE)
  dir_parts <- split_path(ndir)
  file_parts <- split_path(nfile)
  ld <- length(dir_parts)
  lf <- length(file_parts)
  matches <- dir_parts == file_parts[seq(ld)]
  if (all(matches)) {
    val <- tail(file_parts, -ld)
  } else {
    match_len <- min(which(! matches)) - 1
    ddots <- rep("..", ld - match_len)
    parts <- c(ddots, file_parts[seq(match_len + 1, lf)])
    f <- expr(file.path(!!!parts))
    val <- eval(f)
  }
  if (is.na(val)) {
    stop('Could not resolve relative path from "', dir, '" to "', file, '".')
  }
  val
}

#' Make an absolute dependency relative
#'
#' Change a dependency's absolute path to be relative to one of its parent
#' directories.
#'
#' @param dependency A single HTML dependency with an absolute path.
#' @param basepath The path to the directory that \code{dependency} should be
#'   made relative to.
#' @param mustWork If \code{TRUE} and \code{dependency} does not point to a
#'   directory on disk (but rather a URL location), an error is raised. If
#'   \code{FALSE} then non-disk dependencies are returned without modification.
#'
#' @return The dependency with its \code{src} value updated to the new
#' location's relative path.
#'
#' If \code{baspath} did not appear to be a parent directory of the dependency's
#' directory, an error is raised (regardless of the value of \code{mustWork}).
#'
#' @export
makeDependencyRelative <- function(dependency, basepath, mustWork = TRUE) {
  basepath <- normalizePath(basepath, "/", TRUE)
  dir <- dependency$src$file
  if (is.null(dir)) {
    if (!mustWork)
      return(dependency)
    else
      stop("Could not make dependency ", dependency$name, " ",
           dependency$version, " relative; it is not file-based")
  }

  dependency$src <- c(file=relative_to(basepath, dir))

  dependency
}

#' Verify that files in a target directory match files in a reference directory
#'
#' Compare files from a reference (source) directory to those in a target
#' directory. Issue warnings or errors for mismatches or missing files.
#' Optionally fix missing or mismatched files by copying from the reference
#' directory.
#'
#' In order for disk-based dependencies to work with static HTML files, it's
#' generally necessary to copy them to either the directory of the referencing
#' HTML file, or to a subdirectory of that directory. This function makes it
#' easier to perform that copy.
#'
#' @param dependency A single HTML dependency object.
#' @param outputDir The directory in which a subdirectory should be created for
#'   this dependency.
#' @param mustWork If `TRUE`` and `dependency`` does not point to a
#'   directory on disk (but rather a URL location), an error is raised. If
#'   `FALSE`` then non-disk dependencies are returned without modification.
#' @param copyMissing Copy files from the source directory when the target file
#'   is either missing or does not match the file in the reference directory.
#'
#' @return The dependency with its \code{src} value updated to the new
#'   location's absolute path.
#'
#' @seealso \code{\link{makeDependencyRelative}} can be used with the returned
#'   value to make the path relative to a specific directory.
#'
#' @export
verifyDependencyFiles <- function(dependency, outputDir, mustWork = TRUE,
                                  copyMissing = FALSE) {

  dir <- dependency$src$file

  if (is.null(dir)) {
    if (mustWork) {
      stop("Dependency ", dependency$name, " ", dependency$version,
           " is not disk-based")
    } else {
      return(dependency)
    }
  }
  # resolve the relative file path to absolute path in package
  if (!is.null(dependency$package))
    dir <- system.file(dir, package = dependency$package)

  if (length(outputDir) != 1 || outputDir %in% c("", "/"))
    stop('outputDir must be of length 1 and cannot be "" or "/"')

  if (!dir.exists(outputDir))
    dir.create(outputDir)

  target_dir <- if (getOption('htmltools.dir.version', TRUE)) {
    paste(dependency$name, dependency$version, sep = "-")
  } else dependency$name
  target_dir <- file.path(outputDir, target_dir)

  if (copyMissing) {
    # completely remove the target dir because we don't want possible leftover
    # files in the target dir, e.g. we may have lib/foo.js last time, and it was
    # removed from the original library, then the next time we copy the library
    # over to the target dir, we want to remove this lib/foo.js as well;
    # unlink(recursive = TRUE) can be dangerous, e.g. we certainly do not want 'rm
    # -rf /' to happen; in htmlDependency() we have made sure dependency$name and
    # dependency$version are not "" or "/" or contains no / or \; we have also
    # made sure outputDir is not "" or "/" above, so target_dir here should be
    # relatively safe to be removed recursively
    if (dir.exists(target_dir)) unlink(target_dir, recursive = TRUE)
    dir.create(target_dir)
  } else {
    if (! dir.exists(target_dir)) {
      msg <- stringr::str_c('Missing target directory "', target_dir, '".')
      if (mustWork) stop(msg)
      else warning(msg)
      return()
    }
  }

  files <- if (dependency$all_files) list.files(dir) else {
    unlist(dependency[c('script', 'stylesheet', 'attachment')])
  }
  srcfiles <- file.path(dir, files)
  if (any(!file.exists(srcfiles))) {
    msg <- sprintf(
      "Sources for dependency files don't exist: '%s'",
      stringr::str_c(srcfiles, collapse = "', '")
    )
    if (mustWork) stop(msg)
    else warning(msg)
  }
  destfiles <- file.path(target_dir, files)
  isdir <- file.info(srcfiles)$isdir
  destfiles <- ifelse(isdir, dirname(destfiles), destfiles)

  res <- mapply(copy_if_necessary, srcfiles, destfiles, isdir,
                MoreArgs = list(copyMissing = copyMissing))
  missing <- unlist(res["missing",])
  mismatches <- unlist(res["mismatches",])
  if (length(missing) > 0) {
    missing_msg <- str_c("Missing files: [", str_c(missing,
                                                   collapse = ", "), "]")
  } else {
    missing_msg <- character(0)
  }
  if (length(mismatches) > 0) {
    mismatch_msg <- str_c("Mismatchedfiles: [", str_c(mismatches,
                                                      collapse = ", "), "]")
  } else {
    mismatch_msg <- character(0)
  }
  if (length(missing) > 0 || length(mismatches) > 0) {
    msg <- str_c(missing_msg, mismatch_msg)
    if (mustWork) {
      stop(msg)
    } else {
      warning(msg)
    }
  }

  # Is this what I want, or do I want a relative path?
  dependency$src$file <- normalizePath(target_dir, "/", TRUE)

  dependency
}



#' Compare source and target files and copy source to target if necessary
#'
#' Compare source and target files. By default, give a warning if a target is
#' either missing or different from the source. Optionally, fix mismatches by
#' copying source to target.
#'
#' @param from The source file or a directory of source files.
#' @param to The target file, or a target directory
#' @param isdir `TRUE`` if the source is a directory, `FALSE` if it's a file.
#' @param copyMissing Copy missing or mismatched files from `from` to `to`
#'
#' @return A list with a character vector of missing files and
#'   a character vector of mismatched files.
#'
copy_if_necessary <- function(from, to, isdir, copyMissing = FALSE) {
  missing <- character(0)
  mismatches <- character(0)
  if (!dir.exists(dirname(to))) {
    missing <- c(missing, str_c(to, "/"))
    if (copyMissing) {
      dir.create(dirname(to), recursive = TRUE)
    }
  }
  if (isdir && !dir.exists(to)) {
    missing <- c(missing, str_c(to, "/"))
    if (copyMissing) {
      dir.create(to)
    }
  }
  if (isdir) {
    f <- list.files(from, all.files = TRUE, recursive = TRUE,
                    include.dirs = FALSE)
    t <- file.path(to, f)
    to_exists <- file.exists(t)
    if (any(!to_exists)) {
      missing <- c(missing, t[!to_exists])
    }
    t <- t[to_exists]
    f <- f[to_exists]
    t_digest <- sapply(t, tools::md5sum)
    f_digest <- sapply(f, tools::md5sum)
    matches <- t_digest == f_digest
    if (! all(matches)) {
      mismatches <- c(mismatches, t[!matches])
      if (copyMissing) {
        file.copy(f[ !matches ], t[ !matches ])
      }
    }
  } else if (! file.exists(to)) {
    missing <- c(missing, to)
    if (copyMissing) {
      file.copy(from, to)
    }
  } else {
    match <- tools::md5sum(from) == tools::md5sum(to)
    if (! match) {
      mismatches <- c(mismatches, to)
      if (copyMissing) {
        file.copy(from, to, overwrite = TRUE)
      }
    }
  }
  list(missing = missing, mismatches = mismatches)
}
