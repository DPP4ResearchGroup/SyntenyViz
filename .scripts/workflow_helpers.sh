#!/bin/bash

# Streamlined workflow helper functions for SyntenyViz CI/CD
# This script consolidates common functions used across GitHub Actions workflows

set -euo pipefail

# Simple resource monitoring (reduced verbosity)
monitor_step() {
  local step="$1"
  local timestamp
  timestamp=$(date '+%H:%M:%S')
  echo "🔄 [$timestamp] $step"
  
  # Basic system info (only when requested)
  if [ "${VERBOSE_MONITORING:-false}" = "true" ]; then
    local mem_percent
    local disk_percent
    mem_percent=$(free | grep '^Mem:' | awk '{printf "%.0f", ($3/$2)*100}' 2>/dev/null || echo "N/A")
    disk_percent=$(df -h / | tail -1 | awk '{print $5}' 2>/dev/null || echo "N/A")
    echo "   💾 Memory: ${mem_percent}% | 💿 Disk: ${disk_percent}"
  fi
}

# Streamlined package checking
check_r_package() {
  local pkg="$1"
  R --slave -e ".libPaths(c('${R_LIBS_USER:-$HOME/Rlibs}', '${R_LIBS_SITE:-$HOME/Rlibs-site}', .libPaths())); requireNamespace('$pkg', quietly=TRUE)" 2>/dev/null
}

# Optimized package installation with minimal retry logic
install_r_package() {
  local pkg="$1"
  local type="${2:-cran}"
  local lib="${3:-$R_LIBS_USER}"
  
  echo "📦 Installing $pkg ($type)"
  
  if [ "$type" = "cran" ]; then
    R --slave -e "
      .libPaths(c('${R_LIBS_USER:-$HOME/Rlibs}', '${R_LIBS_SITE:-$HOME/Rlibs-site}', .libPaths()))
      install.packages('$pkg', repos='${R_REPOS:-https://cloud.r-project.org}', lib='$lib', dependencies=TRUE)
    " 2>/dev/null
  else
    R --slave -e "
      .libPaths(c('${R_LIBS_USER:-$HOME/Rlibs}', '${R_LIBS_SITE:-$HOME/Rlibs-site}', .libPaths()))
      if(!requireNamespace('BiocManager', quietly=TRUE)) install.packages('BiocManager')
      BiocManager::install('$pkg', ask=FALSE, lib='$lib', dependencies=TRUE)
    " 2>/dev/null
  fi
}

# Batch package installation
install_package_batch() {
  local packages=("$@")
  local failed=()
  
  for pkg_info in "${packages[@]}"; do
    IFS=':' read -r pkg type <<< "$pkg_info"
    type="${type:-cran}"
    
    if check_r_package "$pkg"; then
      echo "✅ $pkg (cached)"
    elif install_r_package "$pkg" "$type"; then
      echo "✅ $pkg (installed)"
    else
      echo "❌ $pkg (failed)"
      failed+=("$pkg")
    fi
  done
  
  # Check critical packages
  local critical=(devtools knitr rmarkdown)
  local missing_critical=()
  
  for pkg in "${critical[@]}"; do
    if ! check_r_package "$pkg"; then
      missing_critical+=("$pkg")
    fi
  done
  
  if [ ${#missing_critical[@]} -gt 0 ]; then
    echo "❌ CRITICAL: Missing essential packages: ${missing_critical[*]}"
    return 1
  fi
  
  if [ ${#failed[@]} -gt 0 ]; then
    echo "⚠️ Non-critical packages failed: ${failed[*]}"
  fi
  
  return 0
}

# Setup R library paths
setup_r_environment() {
  monitor_step "Setting up R environment"
  
  # Create directories
  mkdir -p "${R_LIBS_USER:-$HOME/Rlibs}" "${R_LIBS_SITE:-$HOME/Rlibs-site}"
  
  # Verify R installation
  if ! command -v R >/dev/null 2>&1; then
    echo "❌ R not found in PATH"
    return 1
  fi
  
  echo "✅ R environment ready: $(R --version | head -1 | cut -d' ' -f1-3)"
  return 0
}

# Install system dependencies in one go
install_system_deps() {
  monitor_step "Installing system dependencies"
  
  # Check if we're on macOS (no sudo apt-get)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 macOS detected - skipping apt-get system dependencies"
    echo "   Note: Some vignette dependencies may need manual installation"
    return 0
  fi
  
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends \
    build-essential \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    pandoc \
    texlive-latex-base \
    texlive-fonts-recommended \
    texlive-latex-extra \
    2>/dev/null
    
  echo "✅ System dependencies installed"
}

# Build package with all steps
build_package() {
  monitor_step "Building SyntenyViz package"
  
  # Set library paths for all R commands
  local r_cmd_prefix
  r_cmd_prefix=".libPaths(c('${R_LIBS_USER:-$HOME/Rlibs}', '${R_LIBS_SITE:-$HOME/Rlibs-site}', .libPaths()))"
  
  # Install package
  echo "📦 Installing package..."
  Rscript -e "${r_cmd_prefix}; devtools::install()"
  
  # Build documentation
  echo "📖 Building documentation..."
  Rscript -e "${r_cmd_prefix}; devtools::document()"
  
  # Build tarball
  echo "📦 Creating tarball..."
  Rscript -e "${r_cmd_prefix}; devtools::build()"
  
  # Build vignettes (with error handling)
  echo "📖 Building vignettes..."
  if Rscript -e "${r_cmd_prefix}; devtools::build_vignettes()" 2>/dev/null; then
    echo "✅ Vignettes built successfully"
  else
    echo "⚠️ Vignette building failed - continuing without vignettes"
    echo "   This is often due to missing system dependencies or compilation issues"
  fi
  
  echo "✅ Package build completed"
}

# Verify package installation
verify_package() {
  local pkg="${1:-SyntenyViz}"
  
  monitor_step "Verifying $pkg installation"
  
  if Rscript -e ".libPaths(c('${R_LIBS_USER:-$HOME/Rlibs}', '${R_LIBS_SITE:-$HOME/Rlibs-site}', .libPaths())); library($pkg)" 2>/dev/null; then
    echo "✅ $pkg package verified"
    return 0
  else
    echo "❌ $pkg package verification failed"
    return 1
  fi
}

# Validate DESCRIPTION file format
validate_description() {
  monitor_step "Validating DESCRIPTION file"
  
  if [ ! -f "DESCRIPTION" ]; then
    echo "❌ DESCRIPTION file not found"
    return 1
  fi
  
  # Check for common version format issues
  if grep -q "Version:.*-" DESCRIPTION; then
    echo "⚠️ WARNING: Version contains hyphens which may cause issues"
    echo "   Consider using dots (.) instead of hyphens (-) for version numbers"
  fi
  
  # Test if R can parse the DESCRIPTION
  if R --slave -e "read.dcf('DESCRIPTION')" 2>/dev/null; then
    echo "✅ DESCRIPTION file format is valid"
    return 0
  else
    echo "❌ DESCRIPTION file has format errors"
    return 1
  fi
}

# Export functions for workflow use
export -f monitor_step
export -f check_r_package
export -f install_r_package
export -f install_package_batch
export -f setup_r_environment
export -f install_system_deps
export -f build_package
export -f verify_package
export -f validate_description
