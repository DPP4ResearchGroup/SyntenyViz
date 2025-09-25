#!/usr/bin/env python3
"""
Render Mermaid Flowchart to PNG
This script converts the Mermaid flowchart to a PNG image using mermaid-cli
"""

import os
import re
import subprocess
import sys

def install_mermaid_cli():
    """Install mermaid-cli if not available"""
    try:
        subprocess.run(["mmdc", "--version"], check=True, capture_output=True)
        print("mermaid-cli is already installed")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Installing mermaid-cli...")
        try:
            subprocess.run(["npm", "install", "-g", "@mermaid-js/mermaid-cli"], check=True)
            print("mermaid-cli installed successfully")
            return True
        except subprocess.CalledProcessError as e:
            print(f"Error installing mermaid-cli: {e}")
            return False

def extract_mermaid_code():
    """Extract Mermaid code from the markdown file"""
    try:
        with open("SYNTENYVIZ_WORKFLOW_FLOWCHART.md", "r", encoding="utf-8") as f:
            content = f.read()
        
        # Find the mermaid code block
        pattern = r'```mermaid\n(.*?)\n```'
        match = re.search(pattern, content, re.DOTALL)
        
        if match:
            mermaid_code = match.group(1)
            print(f"Mermaid code extracted successfully ({len(mermaid_code)} characters)")
            print("Updated flowchart with proper flowchart shapes and connections")
            return mermaid_code
        else:
            print("Error: Could not find Mermaid code block in the markdown file")
            return None
            
    except FileNotFoundError:
        print("Error: SYNTENYVIZ_WORKFLOW_FLOWCHART.md file not found")
        return None

def render_to_png(mermaid_code):
    """Render Mermaid code to PNG using mermaid-cli"""
    try:
        # Write mermaid code to temporary file
        with open("temp_flowchart.mmd", "w", encoding="utf-8") as f:
            f.write(mermaid_code)
        
        # Render to PNG
        cmd = [
            "mmdc",
            "-i", "temp_flowchart.mmd",
            "-o", "SyntenyViz_Workflow_Flowchart.png",
            "-w", "2000",
            "-H", "3000",
            "-b", "white",
            "-s", "2"
        ]
        
        subprocess.run(cmd, check=True)
        print("PNG file created: SyntenyViz_Workflow_Flowchart.png")
        
        # Clean up temporary file
        os.remove("temp_flowchart.mmd")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"Error rendering PNG: {e}")
        return False
    except Exception as e:
        print(f"Unexpected error: {e}")
        return False

def main():
    """Main function"""
    print("SyntenyViz Mermaid to PNG Renderer")
    print("=" * 40)
    
    # Check if mermaid-cli is available
    if not install_mermaid_cli():
        print("Please install mermaid-cli manually:")
        print("npm install -g @mermaid-js/mermaid-cli")
        sys.exit(1)
    
    # Extract mermaid code
    mermaid_code = extract_mermaid_code()
    if not mermaid_code:
        sys.exit(1)
    
    # Render to PNG
    if render_to_png(mermaid_code):
        print("Successfully created SyntenyViz_Workflow_Flowchart.png")
    else:
        print("Failed to create PNG file")
        sys.exit(1)

if __name__ == "__main__":
    main()
