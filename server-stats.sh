#!/bin/bash

# Simple script to show server performance stats for Linux-based systems
# Compatible with Debian-based (e.g., Ubuntu, Mint), Red Hat-based (e.g., Fedora, CentOS), and others
# Note: Some sections (e.g., Failed Logins) may require sudo for log file access

# Show a header
echo "===== Server Stats ====="
echo "Time: $(date)"
echo ""

# 1. CPU Capacity and Usage
echo "=== CPU Usage ==="
# Get total CPU capacity (number of cores)
CPU_CORES=$(nproc)
echo "Total CPU Capacity: $CPU_CORES cores"
# Get current CPU usage (percentage across all cores)
CPU_OUTPUT=$(top -bn1 | grep "Cpu(s)" | awk '{print $2, $4}')
CPU_USER=$(echo "$CPU_OUTPUT" | awk '{print $1}')
CPU_SYSTEM=$(echo "$CPU_OUTPUT" | awk '{print $2}')
# Calculate total, ensure non-zero if user or system is non-zero
CPU_TOTAL=$(awk "BEGIN {printf \"%.1f\", $CPU_USER + $CPU_SYSTEM}")
# Fallback: if CPU_TOTAL is 0 but components are not, use sum
if [ $(echo "$CPU_TOTAL == 0 && ($CPU_USER > 0 || $CPU_SYSTEM > 0)" | bc) -eq 1 ]; then
    CPU_TOTAL=$(awk "BEGIN {printf \"%.1f\", $CPU_USER + $CPU_SYSTEM}")
fi
echo "Current CPU Usage: $CPU_TOTAL% (across all cores)"
echo "  User: $CPU_USER% (user processes)"
echo "  System: $CPU_SYSTEM% (system processes)"
echo ""

# 2. Top 5 Processes by CPU
echo "=== Top 5 CPU Processes ==="
# Show process ID, command, and CPU usage, skip header, right-align CPU in narrow column
ps -eo pid,cmd,%cpu --sort=-%cpu | head -n 6 | tail -n +2 | awk '{printf "PID: %-6s CMD: %-35s CPU: %4.1f%%\n", $1, substr($0, index($0,$2), index($0,$3)-index($0,$2)), $NF}'
echo ""

# 3. Memory Usage
echo "=== Memory Usage ==="
# Get memory info in MB (total, used, free, shared, buffers/cache)
TOTAL_MEM=$(free -m | grep Mem | awk '{print $2}')
USED_MEM=$(free -m | grep Mem | awk '{print $3}')
FREE_MEM=$(free -m | grep Mem | awk '{print $4}')
SHARED_MEM=$(free -m | grep Mem | awk '{print $5}')
BUFF_CACHE=$(free -m | grep Mem | awk '{print $6}')
# Calculate percentages
USED_PERCENT=$(awk "BEGIN {printf \"%.2f\", ($USED_MEM/$TOTAL_MEM)*100}")
FREE_PERCENT=$(awk "BEGIN {printf \"%.2f\", ($FREE_MEM/$TOTAL_MEM)*100}")
SHARED_PERCENT=$(awk "BEGIN {printf \"%.2f\", ($SHARED_MEM/$TOTAL_MEM)*100}")
BUFF_CACHE_PERCENT=$(awk "BEGIN {printf \"%.2f\", ($BUFF_CACHE/$TOTAL_MEM)*100}")
echo "Total Memory: $TOTAL_MEM MB"
echo "Used Memory: $USED_MEM MB ($USED_PERCENT%) – active processes"
echo "Free Memory: $FREE_MEM MB ($FREE_PERCENT%) – unallocated"
echo "Shared Memory: $SHARED_MEM MB ($SHARED_PERCENT%) – shared libraries"
echo "Buffers/Cache: $BUFF_CACHE MB ($BUFF_CACHE_PERCENT%) – disk caching"
echo ""

# 4. Top 5 Processes by Memory
echo "=== Top 5 Memory Processes ==="
# Show process ID, command, and memory usage, skip header, right-align Memory in narrow column
ps -eo pid,cmd,%mem --sort=-%mem | head -n 6 | tail -n +2 | awk '{printf "PID: %-6s CMD: %-35s Memory: %4.1f%%\n", $1, substr($0, index($0,$2), index($0,$3)-index($0,$2)), $NF}'
echo ""

# 5. Disk Usage
echo "=== Disk Usage ==="
# Get disk info
TOTAL_DISK=$(df -h --total | grep total | awk '{print $2}')
USED_DISK=$(df -h --total | grep total | awk '{print $3}')
FREE_DISK=$(df -h --total | grep total | awk '{print $4}')
USED_PERCENT=$(df -h --total | grep total | awk '{print $5}' | tr -d '%')
FREE_PERCENT=$(awk "BEGIN {print 100 - $USED_PERCENT}")
echo "Total Disk: $TOTAL_DISK"
echo "Used Disk: $USED_DISK ($USED_PERCENT%)"
echo "Free Disk: $FREE_DISK ($FREE_PERCENT%)"
echo ""

# 6. OS Version
echo "=== OS Version ==="
# Show OS info
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "OS: $PRETTY_NAME"
else
    echo "OS: $(uname -a)"
fi
echo ""

# 7. Uptime
echo "=== Uptime ==="
# Show how long system has been running
UPTIME=$(uptime -p)
echo "Uptime: $UPTIME"
echo ""

# 8. Load Average
echo "=== Load Average ==="
# Show system load for 1, 5, 15 minutes
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}')
echo "Load (1,5,15 min): $LOAD_AVG"
echo ""

# 9. Logged-in Users
echo "=== Logged-in Users ==="
# Show who is logged in
who | awk '{print "User: " $1 " (Terminal: " $2 ", Login: " $3 " " $4 ")"}'
echo ""

# 10. Failed Login Attempts
echo "=== Failed Login Attempts (based on your current log rotation policy) ==="
# Check for failed login attempts in logs, case-insensitive
# Note: May require sudo to read /var/log/auth.log or /var/log/secure
if [ -r /var/log/auth.log ]; then
    FAILED=$(grep -i 'failed' /var/log/auth.log | wc -l)
    echo "Failed Logins: $FAILED"
elif [ -r /var/log/secure ]; then
    FAILED=$(grep -i 'failed' /var/log/secure | wc -l)
    echo "Failed Logins: $FAILED"
else
    echo "Failed Logins: Cannot access log files (try running with sudo)"
fi
echo ""

# 11. Last Reboot
echo "=== Last Reboot ==="
# Show when system last rebooted
LAST_REBOOT=$(last -x | grep reboot | head -n 1 | awk '{print $5 " " $6 " " $7 " " $8}')
echo "Last Reboot: $LAST_REBOOT"
echo ""

echo ""
echo "Time: $(date)"
echo "===== End of Stats ====="