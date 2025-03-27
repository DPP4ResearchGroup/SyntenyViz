run_diagnostics <- function(pkgname) {
    message("Running diagnostics...")
    source(system.file("R", "loading_funcs/diagnostics.R", package = pkgname))
}
