Simple Server Stats Script

A lightweight Bash script to display key performance statistics for Linux-based systems, including CPU usage, memory, disk, top processes, logged-in users, failed login attempts, and more. Ideal for system administrators, enthusiasts and beginners to monitor server health.

Features

CPU Usage: Shows total CPU cores, current usage, user, and system percentages.
Memory Usage: Displays total, used, free, shared, and buffers/cache memory in MB with percentages.
Disk Usage: Reports total, used, and free disk space with percentages.
Top Processes: Lists top 5 processes by CPU and memory usage (PID, command, percentage).
OS Version: Displays the operating system details.
Uptime: Shows how long the system has been running.
Load Average: Reports system load over 1, 5, and 15 minutes.
Logged-in Users: Lists users with their terminals and login times.
Failed Login Attempts: Counts failed logins in /var/log/auth.log or /var/log/secure (case-insensitive), based on your system's log rotation policy (typically 1–7 days).
Last Reboot: Shows the date and time of the last system reboot.

Requirements

Linux-based system (e.g., Ubuntu, Linux Mint, Fedora, CentOS, Arch).
Bash shell (pre-installed on most Linux distributions).
Standard tools: top, free, df, ps, awk, grep, who, uptime, last.
Read access to /var/log/auth.log or /var/log/secure (may require sudo).

Installation and Usage

Download the Script:
wget https://raw.githubusercontent.com/Srinath04/devops-bytes/main/server-stats.sh

Or clone this repository:
git clone https://github.com/Srinath04/devops-bytes.git


Make it Executable:
chmod +x server-stats.sh


Run the Script:
./server-stats.sh


If you see Failed Logins: Cannot access log files or any permission issues, run with sudo: sudo ./simple_server-stats.sh



Sample Output
===== Server Stats =====
Time: Wed Jan 1 06:00:00 IST 2025

=== CPU Usage ===
Total CPU Capacity: 8 cores
Current CPU Usage: 4.5% (across all cores)
  User: 0.0% (user processes)
  System: 4.5% (system processes)

=== Failed Login Attempts (based on your current rotation policy file) ===
Failed Logins: 1

...
===== End of Stats =====

Notes
Failed Logins: Counts attempts in the current /var/log/auth.log (Debian-based) or /var/log/secure (Red Hat-based), typically covering 1–7 days, depending on your log rotation policy.
Permissions: Log files may require sudo due to restricted access (e.g., -rw-r----- root adm).
Compatibility: Tested on Linux Mint, Ubuntu, and similar Linux distributions. May not work with journalctl-only systems (e.g., some Arch setups).

Contributions: Please feel free to report issues or submit pull requests on GitHub!

Important
This script is optimized for Linux-based systems. 
Separate scripts for macOS and Windows based desktop systems will be added in future updates.