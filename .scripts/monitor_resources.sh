#!/bin/bash

# Consolidated resource monitoring function for GitHub Actions workflows
# Usage: source .scripts/monitor_resources.sh
# Then call: monitor_resources "STEP-NAME"

monitor_resources() {
  local step="$1"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  echo "=========================================="
  echo "📊 RESOURCE MONITOR - $step"
  echo "⏰ Time: $timestamp"
  echo "=========================================="
  
  # System Information
  echo "🖥️  System: $(hostname) | $(uname -r)"
  echo "⏱️  Uptime: $(uptime | cut -d',' -f1)"
  
  # CPU and Load
  local cpu_cores
  cpu_cores=$(nproc)
  local load_avg
  load_avg=$(cut -d' ' -f1-3 /proc/loadavg)
  echo "🔧 CPU: $cpu_cores cores | Load: $load_avg"
  
  # Memory Usage
  if command -v free >/dev/null 2>&1; then
    local mem_info
    mem_info=$(free -h | grep '^Mem:')
    local mem_used
    mem_used=$(echo "$mem_info" | awk '{print $3}')
    local mem_total
    mem_total=$(echo "$mem_info" | awk '{print $2}')
    local mem_percent
    mem_percent=$(free | grep '^Mem:' | awk '{printf "%.1f", ($3/$2)*100}')
    echo "💾 Memory: $mem_used used / $mem_total total ($mem_percent%)"
  else
    echo "💾 Memory: Information not available"
  fi
  
  # Disk Usage
  if command -v df >/dev/null 2>&1; then
    local disk_info
    disk_info=$(df -h / | tail -1)
    local disk_used
    disk_used=$(echo "$disk_info" | awk '{print $3}')
    local disk_total
    disk_total=$(echo "$disk_info" | awk '{print $2}')
    local disk_percent
    disk_percent=$(echo "$disk_info" | awk '{print $5}')
    echo "💿 Disk: $disk_used used / $disk_total total ($disk_percent)"
  else
    echo "💿 Disk: Information not available"
  fi
  
  # Process Information
  local total_processes
  total_processes=$(ps aux | wc -l)
  local r_processes
  r_processes=$(pgrep -c R 2>/dev/null || echo 0)
  echo "⚡ Processes: $total_processes total | $r_processes R processes"
  
  # Top resource consumers (if available)
  if command -v ps >/dev/null 2>&1; then
    local top_mem_process
    top_mem_process=$(ps -eo comm,%mem --sort=-%mem --no-headers | head -1 | awk '{printf "%s (%.1f%%)", $1, $2}' 2>/dev/null || echo "N/A")
    local top_cpu_process
    top_cpu_process=$(ps -eo comm,%cpu --sort=-%cpu --no-headers | head -1 | awk '{printf "%s (%.1f%%)", $1, $2}' 2>/dev/null || echo "N/A")
    echo "🔝 Top Memory: $top_mem_process"
    echo "🔝 Top CPU: $top_cpu_process"
  fi
  
  echo "=========================================="
}

# Function to monitor a command execution with before/after resource monitoring
monitor_command() {
  local step_name="$1"
  shift
  local command="$*"
  
  monitor_resources "${step_name}-START"
  
  echo "🚀 Executing: $command"
  if eval "$command"; then
    echo "✅ Command completed successfully"
    monitor_resources "${step_name}-END"
    return 0
  else
    local exit_code=$?
    echo "❌ Command failed with exit code: $exit_code"
    monitor_resources "${step_name}-FAILED"
    return $exit_code
  fi
}

# Enhanced monitoring with timing
monitor_resources_with_timing() {
  local step="$1"
  local start_time="$2"
  
  monitor_resources "$step"
  
  if [ -n "$start_time" ]; then
    local end_time
    end_time=$(date +%s)
    local duration
    duration=$((end_time - start_time))
    local hours=$((duration / 3600))
    local minutes=$(((duration % 3600) / 60))
    local seconds=$((duration % 60))
    
    if [ $hours -gt 0 ]; then
      echo "⏱️  Duration: ${hours}h ${minutes}m ${seconds}s"
    elif [ $minutes -gt 0 ]; then
      echo "⏱️  Duration: ${minutes}m ${seconds}s"
    else
      echo "⏱️  Duration: ${seconds}s"
    fi
  fi
}

# Export functions for use in workflows
export -f monitor_resources
export -f monitor_command
export -f monitor_resources_with_timing
