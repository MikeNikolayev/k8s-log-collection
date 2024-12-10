# K8s Log Collection and Monitoring Scripts

This repository contains a set of scripts and configuration files designed to assist with logging, monitoring, and troubleshooting Kubernetes clusters and related services. The tools address common debugging scenarios such as DNS resolution issues, k3s errors, service restarts, network connectivity, and Linkerd outbound TCP error analysis.

## Contents

- [debug-pod.yml](#debug-podyml)
- [k3s_error_monitor.sh](#k3s_error_monitorsh)
- [k3s_restart_monitor.sh](#k3s_restart_monitorsh)
- [linkerd_test.sh](#linkerd_testsh)
- [ping_monitor.sh](#ping_monitorsh)

---

### debug-pod.yml

**Purpose:**  
Creates a simple "dns-debug" Pod on your cluster. It runs a `busybox` container that remains alive indefinitely, allowing you to exec into it for DNS checks and other low-level network diagnostics. The pod mounts a host directory to store logs and other data.

**Key Features:**
- Uses the `busybox` image for a minimalistic troubleshooting environment.
- Persistent volume mount from the host at `/var/tmp/dns-monitor`.
- Ideal for on-the-fly DNS lookups (`nslookup`, `dig`, etc.) and network queries.

**Usage:**
```bash
kubectl apply -f debug-pod.yml
kubectl exec -it dns-debug -- sh
# Perform DNS checks, ping, etc.

# Monitoring Scripts for k3s and Linkerd

---

### **k3s_error_monitor.sh**
**Purpose**:  
Monitors k3s logs (via `journalctl`) for errors, logs new occurrences, and keeps a cumulative count.

**Key Features**:
- Continuously polls the last 100 lines of k3s logs.
- Searches for errors matching a specific timestamp pattern: `E[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}`.
- Maintains a cumulative error count in `/var/tmp/k3s_error_count.log`.
- Writes detailed logs to `/var/tmp/k3s_error_monitor.log`.

**Usage**:
```bash
chmod +x k3s_error_monitor.sh
./k3s_error_monitor.sh &

### **k3s_restart_monitor.sh**
**Purpose**:  
Monitors the k3s service for restarts and logs each occurrence, while maintaining a total restart count.

**Key Features**:
- Periodically checks the k3s systemd service status.
- Updates a cumulative restart count in `/var/tmp/k3s_restart_count.log`.
- Logs restart events and totals to `/var/tmp/k3s_restart_monitor.log`.

**Usage**:
```bash
chmod +x k3s_restart_monitor.sh
./k3s_restart_monitor.sh &

### **linkerd_test.sh**
**Purpose**:  
Generates a report of outbound TCP errors collected by Linkerd from pods in a specified namespace (default: `default`). The script maps target IPs from Linkerd metrics back to their corresponding pods to pinpoint sources of errors.

**Key Features**:
- Fetches metrics using `linkerd diagnostics proxy-metrics`.
- Filters metrics for `outbound_tcp_errors_total`.
- Maps target IPs to pods.
- Outputs a detailed report to `linkerd_outbound_errors_report.txt`.

**Usage**:
```bash
chmod +x linkerd_test.sh
./linkerd_test.sh
cat linkerd_outbound_errors_report.txt

# ping_monitor.sh

## Purpose
Pings a predefined list of nodes and logs the results to assess network health and detect connectivity issues.

---

## Key Features
- Allows customization of target nodes via the `NODES` array in the script.
- Logs timestamped ping results to `/var/tmp/ping_monitor.log`.
- Runs indefinitely with a default interval of 15 seconds.

---

## Usage
1. **Edit the `NODES` array** in `ping_monitor.sh` to specify the nodes to monitor.
2. **Run the script**:
   ```bash
   chmod +x ping_monitor.sh
   ./ping_monitor.sh &
