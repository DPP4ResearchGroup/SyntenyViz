#!/usr/bin/env python3
"""
Render SyntenyViz Function Logic Flowchart to PNG
"""

import subprocess
import sys
import os

def render_mermaid_to_png():
    """Render the function logic flowchart from markdown to PNG"""
    
    # Read the markdown file
    with open('SYNTENYVIZ_FUNCTION_LOGIC_FLOWCHART.md', 'r') as f:
        content = f.read()
    
    # Extract the mermaid code block
    start_marker = '```mermaid'
    end_marker = '```'
    
    start_idx = content.find(start_marker)
    if start_idx == -1:
        print("Error: Could not find mermaid code block start marker")
        return False
    
    start_idx += len(start_marker)
    end_idx = content.find(end_marker, start_idx)
    if end_idx == -1:
        print("Error: Could not find mermaid code block end marker")
        return False
    
    mermaid_code = content[start_idx:end_idx].strip()
    
    # Write mermaid code to temporary file
    with open('function_logic_flowchart.mmd', 'w') as f:
        f.write(mermaid_code)
    
    try:
        # Use mermaid-cli to render to PNG
        cmd = ['mmdc', '-i', 'function_logic_flowchart.mmd', '-o', 'SYNTENYVIZ_FUNCTION_LOGIC_FLOWCHART.png', '-t', 'neutral', '-b', 'white']
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print("Successfully rendered function logic flowchart to PNG")
            print("Output file: SYNTENYVIZ_FUNCTION_LOGIC_FLOWCHART.png")
            return True
        else:
            print(f"Error rendering flowchart: {result.stderr}")
            return False
            
    except FileNotFoundError:
        print("Error: mermaid-cli not found. Please install with: npm install -g @mermaid-js/mermaid-cli")
        return False
    except Exception as e:
        print(f"Error: {e}")
        return False
    finally:
        # Clean up temporary file
        if os.path.exists('function_logic_flowchart.mmd'):
            os.remove('function_logic_flowchart.mmd')

if __name__ == "__main__":
    success = render_mermaid_to_png()
    sys.exit(0 if success else 1)
