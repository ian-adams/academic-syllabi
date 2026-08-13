# ---------------------------------------------------------------------------
# Build CRJU 314 Fall 2026 syllabus.
#
#   Rscript build.R          # PDF, HTML, and Word
#   Rscript build.R pdf
#   Rscript build.R html
#   Rscript build.R docx
#
# WHICH FILE TO UPLOAD
#
# Blackboard here blocks .html uploads at the server policy level, so the Word
# file is the accessible copy to post; the PDF is the printable one. The HTML
# is still built because it is the most accessible of the three if the policy
# ever changes, or if you paste its content into a Blackboard Item.
#
# WHY THIS FILE EXISTS
#
# The HTML build is post-processed to remove every <script> block. Blackboard's
# content scanner refuses an uploaded HTML file containing inline JavaScript,
# treating it as a possible cross-site-scripting vector -- which is a fair call
# on their part, not oversensitivity.
#
# Nothing in this syllabus needs scripting. Setting theme/highlight/toc_float
# to null removes the big offenders (Bootstrap, jQuery, jQuery UI), but two
# small blocks still slip in from rmarkdown and kableExtra: a pandoc header-
# attribute tidy-up, and a Bootstrap tooltip initializer that calls jQuery,
# which is not loaded in this build and would error if it ever ran.
#
# Stripping them here rather than chasing the option that produces them means
# any future dependency that injects a script is also caught. The check at the
# end is a hard failure: if a script survives, the build stops rather than
# handing you a file Blackboard will bounce.
# ---------------------------------------------------------------------------

suppressMessages({
  library(rmarkdown)
  library(readr)
})

rmd      <- "CRJU 314 Fall 2026.Rmd"
html_out <- "CRJU-314-Fall-2026.html"

args <- commandArgs(trailingOnly = TRUE)
what <- if (length(args)) tolower(args[1]) else "both"
stopifnot(what %in% c("both", "pdf", "html", "docx"))

count_scripts <- function(s) {
  m <- gregexpr("<script", s, fixed = TRUE)[[1]]
  if (length(m) == 1 && m[1] == -1) 0L else length(m)
}

sanitize_html <- function(path) {
  s <- read_file(path)
  before <- count_scripts(s)

  s <- gsub("(?s)<script.*?</script>", "", s, perl = TRUE)   # (?s) = dot matches newline
  s <- gsub("(?s)<noscript.*?</noscript>", "", s, perl = TRUE)

  after <- count_scripts(s)
  write_file(s, path)

  message(sprintf("  sanitize: removed %d <script> block(s); %d remain (%.0f KB)",
                  before - after, after, file.size(path) / 1024))

  if (after > 0) {
    stop("Script tags survived sanitizing -- Blackboard will reject this file.",
         call. = FALSE)
  }
  invisible(TRUE)
}

if (what %in% c("both", "pdf")) {
  message("== PDF ==")
  render(rmd, output_format = "stevetemplates::syllabus", quiet = TRUE)
  message("  wrote CRJU-314-Fall-2026.pdf")
}

if (what %in% c("both", "html")) {
  message("== HTML ==")
  render(rmd, output_format = "html_document", quiet = TRUE)
  sanitize_html(html_out)
  message("  wrote ", html_out, " -- most accessible, but blocked by upload policy")
}

# knitr's fig.alt option is not supported for docx, so pandoc falls back to
# using the figure CAPTION as the image description -- "Calendar for CRJU 314",
# which tells a screen-reader user nothing about what the calendar shows.
# Rewrite the descr attribute in word/document.xml with the real alt text.
# (Word exposes the same field as right-click > View Alt Text.)
CALENDAR_ALT <- paste(
  "Month grid of the Fall 2026 semester, August through December.",
  "Weekly assignment deadlines fall on Sundays from August 23 through",
  "November 22, plus a final deadline on Friday December 4. University breaks",
  "with no classes are Labor Day September 7, Fall Break October 15 and 16,",
  "Election Day November 3, and Thanksgiving Recess November 22 through 29.",
  "Nothing is due during Thanksgiving Recess. The final exam is the morning of",
  "Monday December 7. All of this information is also stated in the",
  "week-by-week schedule that follows.")

fix_docx_alt <- function(path, alt) {
  # Resolve to an absolute path NOW. Below we setwd() into the unpacked
  # directory so the rezipped paths stay relative to the package root, and a
  # relative output path would then silently resolve against the temp dir --
  # writing a new .docx in there and leaving the real one untouched.
  out <- normalizePath(path, mustWork = TRUE)

  tmp <- file.path(tempdir(), "docx-alt")
  unlink(tmp, recursive = TRUE); dir.create(tmp, recursive = TRUE)
  zip::unzip(path, exdir = tmp)

  doc <- file.path(tmp, "word", "document.xml")
  s <- read_file(doc)
  esc <- function(x) {
    x <- gsub("&", "&amp;", x, fixed = TRUE)
    x <- gsub("<", "&lt;",  x, fixed = TRUE)
    gsub('"', "&quot;", x, fixed = TRUE)
  }
  n <- length(gregexpr('<wp:docPr[^>]*descr="', s, perl = TRUE)[[1]])
  s2 <- sub('(<wp:docPr[^>]*\\bdescr=")[^"]*(")',
            paste0("\\1", esc(alt), "\\2"), s, perl = TRUE)
  if (identical(s, s2)) {
    warning("docx alt text: no descr attribute matched; left unchanged.",
            call. = FALSE)
    return(invisible(FALSE))
  }
  write_file(s2, doc)

  # Rezip. mode = "mirror" with root = tmp preserves the internal directory
  # structure (word/, _rels/, docProps/). Do NOT use "cherry-pick": it stores
  # every file at the archive root, which produces a .docx Word cannot open.
  unlink(out)
  zip::zip(out,
           files = list.files(tmp, all.files = TRUE, no.. = TRUE),
           root = tmp,
           mode = "mirror")
  message("  alt text: rewrote image description (", n, " image[s])")
  invisible(TRUE)
}

if (what %in% c("both", "docx")) {
  message("== Word ==")
  render(rmd, output_format = "word_document", quiet = TRUE)
  fix_docx_alt("CRJU-314-Fall-2026.docx", CALENDAR_ALT)
  message("  wrote CRJU-314-Fall-2026.docx -- upload this one to Blackboard")
}

message("done.")
