#!/bin/bash

# SyntenyViz Mermaid to PNG Renderer
# This script provides multiple methods to convert Mermaid flowcharts to PNG
# Usage: ./render_to_png.sh [input_file] [output_file]
#   input_file: Path to markdown file containing Mermaid code (default: SYNTENYVIZ_WORKFLOW_FLOWCHART.md)
#   output_file: Desired output PNG filename (default: based on input filename)

# Function to show usage
show_usage() {
    echo "Usage: $0 [input_file] [output_file]"
    echo ""
    echo "Arguments:"
    echo "  input_file   Path to markdown file containing Mermaid code"
    echo "               Default: SYNTENYVIZ_WORKFLOW_FLOWCHART.md"
    echo "  output_file  Desired output PNG filename"
    echo "               Default: [input_basename]_flowchart.png"
    echo ""
    echo "Examples:"
    echo "  $0                                          # Use defaults"
    echo "  $0 my_flowchart.md                         # Custom input, default output"
    echo "  $0 my_flowchart.md custom_output.png       # Custom input and output"
    echo ""
}

# Parse command line arguments
INPUT_FILE="${1:-SYNTENYVIZ_WORKFLOW_FLOWCHART.md}"
OUTPUT_FILE="${2:-}"

# Generate default output filename if not provided
if [ -z "$OUTPUT_FILE" ]; then
    # Extract basename without extension
    BASENAME=$(basename "$INPUT_FILE" .md)
    OUTPUT_FILE="${BASENAME}_flowchart.png"
fi

# Validate input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: Input file '$INPUT_FILE' not found!"
    echo ""
    show_usage
    exit 1
fi

echo "SyntenyViz Mermaid to PNG Renderer"
echo "=================================="
echo "Input file: $INPUT_FILE"
echo "Output file: $OUTPUT_FILE"
echo "Updated: Proper flowchart shapes and connections for better visualization"
echo ""

# Method 1: Using mermaid-cli (recommended)
echo "Method 1: Using mermaid-cli"
if command -v mmdc &> /dev/null; then
    echo "mermaid-cli found, extracting and rendering..."
    
    # Extract mermaid code from markdown
    sed -n '/```mermaid/,/```/p' "$INPUT_FILE" | sed '1d;$d' > temp_flowchart.mmd
    
    # Render to PNG
    if mmdc -i temp_flowchart.mmd -o "$OUTPUT_FILE" -w 2000 -H 3000 -b white -s 2; then
        echo "✓ PNG created successfully: $OUTPUT_FILE"
        rm temp_flowchart.mmd
    else
        echo "✗ Failed to create PNG with mermaid-cli"
        rm -f temp_flowchart.mmd
    fi
else
    echo "mermaid-cli not found. Install with: npm install -g @mermaid-js/mermaid-cli"
fi

echo ""

# Method 2: Using Puppeteer (if available)
echo "Method 2: Using Puppeteer"
if command -v node &> /dev/null; then
    echo "Node.js found, checking for Puppeteer..."
    
    # Create a simple Node.js script to render the HTML
    cat > render_puppeteer.js << 'EOF'
const puppeteer = require('puppeteer');
const fs = require('fs');

async function renderMermaid() {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    
    // Read the HTML file
    const html = fs.readFileSync('render_mermaid.html', 'utf8');
    await page.setContent(html);
    
    // Wait for mermaid to render
    await page.waitForTimeout(3000);
    
    // Take screenshot
    await page.screenshot({
        path: '$OUTPUT_FILE',
        fullPage: true,
        type: 'png'
    });
    
    await browser.close();
    console.log('PNG created with Puppeteer');
}

renderMermaid().catch(console.error);
EOF

    if npm list puppeteer &> /dev/null; then
        node render_puppeteer.js
        rm render_puppeteer.js
    else
        echo "Puppeteer not installed. Install with: npm install puppeteer"
        rm render_puppeteer.js
    fi
else
    echo "Node.js not found"
fi

echo ""

# Method 3: Instructions for manual rendering
echo "Method 3: Manual Rendering Instructions"
echo "1. Open render_mermaid.html in a web browser"
echo "2. Right-click on the diagram and select 'Save image as...'"
echo "3. Or use browser developer tools to take a screenshot"
echo "4. Or use a tool like wkhtmltopdf to convert HTML to PNG"

echo ""
echo "Summary:"
echo "========="
echo "Input file: $INPUT_FILE"
echo "Output file: $OUTPUT_FILE"
echo ""
echo "Available files:"
echo "- render_mermaid.html (for browser rendering)"
echo "- render_mermaid_to_png.py (Python script)"
echo "- render_mermaid_to_png.R (R script)"
echo ""
echo "Choose the method that works best for your system!"
echo ""
echo "Usage examples:"
echo "  $0                                          # Use defaults"
echo "  $0 my_flowchart.md                         # Custom input, default output"
echo "  $0 my_flowchart.md custom_output.png       # Custom input and output"
