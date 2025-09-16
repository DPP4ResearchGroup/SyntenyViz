#!/bin/bash
set -euxo pipefail

# Centralized APT installation script for SyntenyViz CI/CD
# This script handles all system dependencies, R installation, and documentation tools

# Function to install R and R development tools
install_r() {
    local r_version="${1:-latest}"
    
    echo "🚀 Installing R version: $r_version"
    
    # Update package lists
    sudo apt-get update
    
    # Install software-properties-common for add-apt-repository
    sudo apt-get install -y software-properties-common
    
    # Add CRAN repository key
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
    
    # Add CRAN repository
    sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
    
    # Update package lists again
    sudo apt-get update
    
    # Install R based on version
    if [ "$r_version" = "latest" ]; then
        sudo apt-get install -y r-base r-base-dev
    else
        sudo apt-get install -y r-base=$r_version* r-base-dev=$r_version*
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

# Function to install system dependencies
install_system_deps() {
    echo "📦 Installing system dependencies..."
    sudo apt-get update
    sudo apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev libnlopt-dev
    echo "✅ System dependencies installed"
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

# Main script logic
case "${1:-all}" in
    "r")
        install_r "${2:-latest}"
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
    *)
        echo "Usage: $0 {r|system|texlive|pandoc|all} [r_version]"
        echo "  r        - Install R and R development tools"
        echo "  system   - Install system dependencies"
        echo "  texlive  - Install TeX Live (LaTeX)"
        echo "  pandoc   - Install Pandoc"
        echo "  all      - Install all dependencies (default)"
        echo ""
        echo "Examples:"
        echo "  $0 all latest"
        echo "  $0 r 4.3.0"
        echo "  $0 system"
        exit 1
        ;;
esac

