cat("Checking system configuration...\n")

cat("FCFLAGS:\n")
fcflags <- system("R CMD config FCFLAGS", intern = TRUE)
if (length(fcflags) > 0) {
    cat(fcflags, "\n")
} else {
    cat("No output for FCFLAGS.\n")
}

cat("\nCC (C Compiler):\n")
cc <- system("R CMD config CC", intern = TRUE)
if (length(cc) > 0) {
    cat(cc, "\n")
} else {
    cat("No output for CC.\n")
}

cat("\nCXX (C++ Compiler):\n")
cxx <- system("R CMD config CXX", intern = TRUE)
if (length(cxx) > 0) {
    cat(cxx, "\n")
} else {
    cat("No output for CXX.\n")
}

cat("\nInstalled packages:\n")
installed <- installed.packages()
if (nrow(installed) > 0) {
    cat(paste(installed[, "Package"], collapse = "\n"), "\n")
} else {
    cat("No installed packages found.\n")
}