#!/bin/bash
set -euxo pipefail

# Centralized APT installation script for SyntenyViz CI/CD
# This script handles all system dependencies, R installation, and documentation tools

# Helper function to try installing R with version patterns
try_install_r_version() {
    local version="$1"
    local version_patterns=("$version*")
    
    # Add minor version patterns (0-9)
    for minor in {0..9}; do
        version_patterns+=("$version.$minor*")
    done
    
    # Try each version pattern until one succeeds
    for pattern in "${version_patterns[@]}"; do
        echo "🎯 Trying R version pattern: $pattern"
        if sudo apt-get install -y "r-base=$pattern" "r-base-dev=$pattern" 2>/dev/null; then
            echo "✅ R $pattern installed successfully"
            return 0
        fi
    done
    
    # If no specific version found, show available versions and install latest
    echo "⚠️  R $version not found in repositories"
    echo "🔍 Available R versions:"
    apt-cache madison r-base | head -10 || true
    echo "⚠️  Installing latest R version instead..."
    sudo apt-get install -y r-base r-base-dev
    return 1
}

# Function to install R and R development tools
install_r() {
    local r_version="${1:-latest}"
    
    echo "🚀 Installing R version: $r_version"
    
    # Update package lists
    sudo apt-get update
    
    # Install software-properties-common for add-apt-repository
    sudo apt-get install -y software-properties-common
    
    # Add CRAN repository key (only if not already added)
    if ! apt-key list 2>/dev/null | grep -q "E298A3A825C0D65DFD57CBB651716619E084DAB9"; then
        echo "🔑 Adding CRAN repository key..."
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
    else
        echo "✅ CRAN repository key already exists"
    fi
    
    # Add CRAN repository (only if not already added)
    if ! grep -q "cloud.r-project.org" /etc/apt/sources.list.d/* 2>/dev/null; then
        echo "📦 Adding CRAN repository..."
        sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
    else
        echo "✅ CRAN repository already exists"
    fi
    
    # Update package lists again
    sudo apt-get update
    
    # Install R based on version
    if [ "$r_version" = "latest" ]; then
        echo "📦 Installing latest R version..."
        sudo apt-get install -y r-base r-base-dev
    else
        echo "📦 Installing R version: $r_version"
        try_install_r_version "$r_version"
    fi
    
    # Verify R installation
    echo "🔍 Verifying R installation..."
    if command -v R >/dev/null 2>&1; then
        echo "✅ R is installed and available"
        R --version | head -1
    else
        echo "❌ ERROR: R is not installed or not in PATH"
        exit 1
    fi
}

# Function to install multiple R versions
install_multiple_r() {
    local r_versions="${1:-latest}"
    
    echo "🚀 Installing multiple R versions: $r_versions"
    
    # Update package lists
    sudo apt-get update
    
    # Install software-properties-common for add-apt-repository
    sudo apt-get install -y software-properties-common
    
    # Add CRAN repository key (only if not already added)
    if ! apt-key list 2>/dev/null | grep -q "E298A3A825C0D65DFD57CBB651716619E084DAB9"; then
        echo "🔑 Adding CRAN repository key..."
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
    else
        echo "✅ CRAN repository key already exists"
    fi
    
    # Add CRAN repository (only if not already added)
    if ! grep -q "cloud.r-project.org" /etc/apt/sources.list.d/* 2>/dev/null; then
        echo "📦 Adding CRAN repository..."
        sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
    else
        echo "✅ CRAN repository already exists"
    fi
    
    # Update package lists again
    sudo apt-get update
    
    # Install R versions
    IFS=',' read -ra VERSIONS <<< "$r_versions"
    for version in "${VERSIONS[@]}"; do
        version=$(echo "$version" | xargs) # trim whitespace
        echo "📦 Installing R version: $version"
        
        if [ "$version" = "latest" ]; then
            sudo apt-get install -y r-base r-base-dev
        else
            try_install_r_version "$version"
        fi
    done
    
    # Verify R installation
    echo "🔍 Verifying R installation..."
    if command -v R >/dev/null 2>&1; then
        echo "✅ R is installed and available"
        R --version | head -1
    else
        echo "❌ ERROR: R is not installed or not in PATH"
        exit 1
    fi
    
    # List all available R versions
    echo "📋 Available R versions:"
    ls /usr/bin/R* 2>/dev/null || echo "No R versions found in /usr/bin/"
    dpkg -l | grep r-base || echo "No R packages found"
}

# Function to manage R versions
manage_r_versions() {
    local action="${1:-list}"
    
    case "$action" in
        "list")
            echo "📋 Available R versions:"
            ls /usr/bin/R* 2>/dev/null || echo "No R versions found in /usr/bin/"
            echo ""
            echo "📦 Installed R packages:"
            dpkg -l | grep r-base || echo "No R packages found"
            echo ""
            echo "🔍 Current R version:"
            if command -v R >/dev/null 2>&1; then
                R --version | head -1
            else
                echo "R not found in PATH"
            fi
            ;;
        "switch")
            local target_version="${2:-latest}"
            echo "🔄 Switching to R version: $target_version"
            
            # In Ubuntu, R is typically installed as /usr/bin/R regardless of version
            # The version is determined by the package version, not the binary name
            if [ "$target_version" = "latest" ]; then
                sudo ln -sf /usr/bin/R /usr/local/bin/R
                sudo ln -sf /usr/bin/Rscript /usr/local/bin/Rscript
                echo "✅ Switched to latest R version"
            else
                # For specific versions, we assume the correct version is already installed
                # and just create symlinks to the standard R binaries
                if [ -f "/usr/bin/R" ] && [ -f "/usr/bin/Rscript" ]; then
                    sudo ln -sf /usr/bin/R /usr/local/bin/R
                    sudo ln -sf /usr/bin/Rscript /usr/local/bin/Rscript
                    echo "✅ Switched to R version: $target_version"
                    
                    # Verify the actual version matches what we expect
                    local current_version
                    current_version=$(R --version | head -1 | grep -o '[0-9]\+\.[0-9]\+' | head -1)
                    if [[ "$current_version" == "$target_version"* ]]; then
                        echo "✅ Version confirmed: $current_version (target: $target_version)"
                    else
                        echo "⚠️  Version mismatch: current=$current_version, target=$target_version"
                        echo "   This may indicate the requested version is not available"
                    fi
                else
                    echo "❌ R binaries not found in /usr/bin/"
                    echo "   Available R binaries:"
                    ls -la /usr/bin/R* 2>/dev/null || echo "   No R binaries found"
                    exit 1
                fi
            fi
            
            # Verify switch
            echo "🔍 Current R version after switch:"
            R --version | head -1
            ;;
        "clean")
            echo "🧹 Cleaning up R installations..."
            sudo apt-get remove --purge -y r-base* r-recommended* r-cran-* 2>/dev/null || true
            sudo apt-get autoremove -y
            sudo apt-get autoclean
            echo "✅ R installations cleaned up"
            ;;
        *)
            echo "Usage: manage_r_versions {list|switch|clean} [version]"
            echo "  list   - List available R versions"
            echo "  switch - Switch to specific R version"
            echo "  clean  - Clean up R installations"
            ;;
    esac
}

# Function to install system dependencies
install_system_deps() {
    echo "📦 Installing system dependencies..."
    sudo apt-get update
    sudo apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev libnlopt-dev bc
    echo "✅ Basic system dependencies installed"
    
    echo "📦 Installing graphics and text rendering dependencies..."
    sudo apt-get install -y libfribidi-dev libharfbuzz-dev libfreetype6-dev libpng-dev libjpeg-dev libtiff-dev libcairo2-dev libxt-dev
    echo "✅ Graphics dependencies installed"
}

# Function to install TeX Live (LaTeX)
install_texlive() {
    echo "📝 Installing TeX Live (LaTeX) for documentation generation..."
    sudo apt-get install -y texlive-latex-base texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra texlive-latex-recommended
    echo "✅ TeX Live installed"
}

# Function to install Pandoc
install_pandoc() {
    echo "📄 Installing Pandoc for R Markdown vignette compilation..."
    sudo apt-get install -y pandoc
    
    # Verify Pandoc installation
    echo "🔍 Verifying Pandoc installation..."
    if command -v pandoc >/dev/null 2>&1; then
        echo "✅ Pandoc is installed and available"
        pandoc --version | head -1
    else
        echo "❌ ERROR: Pandoc is not installed or not in PATH"
        exit 1
    fi
}

# Function to install all dependencies
install_all() {
    local r_version="${1:-latest}"
    
    echo "🎯 Installing all dependencies..."
    install_r "$r_version"
    install_system_deps
    install_texlive
    install_pandoc
    echo "🎉 All dependencies installed successfully!"
}

# Function to install all dependencies with multiple R versions
install_all_multiple() {
    local r_versions="${1:-latest}"
    
    echo "🎯 Installing all dependencies with multiple R versions..."
    install_multiple_r "$r_versions"
    install_system_deps
    install_texlive
    install_pandoc
    echo "🎉 All dependencies with multiple R versions installed successfully!"
}

# Function to install all dependencies except R (for CI environments where R is pre-installed)
install_all_except_r() {
    echo "🎯 Installing all dependencies except R (assuming R is pre-installed)..."
    install_system_deps
    install_texlive
    install_pandoc
    echo "🎉 All dependencies (except R) installed successfully!"
}

# Main script logic
case "${1:-all}" in
    "r")
        install_r "${2:-latest}"
        ;;
    "r-multiple")
        install_multiple_r "${2:-latest}"
        ;;
    "r-manage")
        manage_r_versions "${2:-list}" "${3:-}"
        ;;
    "system")
        install_system_deps
        ;;
    "texlive")
        install_texlive
        ;;
    "pandoc")
        install_pandoc
        ;;
    "all")
        install_all "${2:-latest}"
        ;;
    "all-multiple")
        install_all_multiple "${2:-latest}"
        ;;
    "all-except-r")
        install_all_except_r
        ;;
    *)
        echo "Usage: $0 {r|r-multiple|r-manage|system|texlive|pandoc|all|all-multiple|all-except-r} [options]"
        echo ""
        echo "R Installation:"
        echo "  r            - Install single R version and R development tools"
        echo "  r-multiple   - Install multiple R versions (comma-separated)"
        echo "  r-manage     - Manage R versions (list|switch|clean)"
        echo ""
        echo "System Dependencies:"
        echo "  system       - Install system dependencies"
        echo "  texlive      - Install TeX Live (LaTeX)"
        echo "  pandoc       - Install Pandoc"
        echo ""
        echo "Complete Installation:"
        echo "  all          - Install all dependencies with single R version (default)"
        echo "  all-multiple - Install all dependencies with multiple R versions"
        echo "  all-except-r - Install all dependencies except R (for CI environments)"
        echo ""
        echo "Examples:"
        echo "  # Single R version"
        echo "  $0 all latest"
        echo "  $0 r 4.4.0"
        echo ""
        echo "  # Multiple R versions"
        echo "  $0 r-multiple '4.4.0,latest'"
        echo "  $0 all-multiple '4.3.0,4.4.0,latest'"
        echo ""
        echo "  # R version management"
        echo "  $0 r-manage list"
        echo "  $0 r-manage switch 4.4.0"
        echo "  $0 r-manage clean"
        echo ""
        echo "  # System dependencies only"
        echo "  $0 system"
        echo ""
        echo "R Version Formats:"
        echo "  latest       - Latest available R version"
        echo "  4.4.0        - Specific R version"
        echo "  4.4.0,latest - Multiple versions (comma-separated)"
        exit 1
        ;;
esac

