.onLoad <- function(libname, pkgname) {
    show_message <- getOption("SyntenyViz.debug", default = FALSE)
    if (show_message == TRUE) {
        message("Debug messages enabled.")
        run_diagnostics(pkgname)
        message("Diagnostics complete.")  # Existing message
        message("To suppress debug messages and load diagnostics, set options(SyntenyViz.debug = FALSE).")
    } else {
        message("To enable debug messages and load diagnostics, set options(SyntenyViz.debug = TRUE).")
    }
}