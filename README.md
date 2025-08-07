# Grafana Dashboard for TrueNAS SCALE with Advanced ZFS & S.M.A.R.T. Stats

This project provides a comprehensive monitoring setup for TrueNAS SCALE using Prometheus and Grafana. Its unique feature is a small helper script that collects detailed ZFS pool and S.M.A.R.T. data, which is often not gathered by standard exporters.

![Dashboard Screenshot](URL_ZUM_SCREENSHOT_HIER_EINFUEGEN)
*(Hint: You can upload a screenshot of your dashboard to the repository and link to it here)*

## Dashboard Features
- **System Overview:** Uptime and System Load.
- **ZFS Pools:** Separate panels for capacity, usage, and health for each pool.
- **Disk Health:** Critical S.M.A.R.T. values (Reallocated, Pending, Uncorrectable Sectors) with an OK/FAIL warning status.
- **Disk Performance:** Temperature, IOPS, and throughput for each individual disk.
- **CPU & Memory:** Detailed usage (Total & per core), temperature, and available RAM.
- **Network:** Traffic for the main interfaces.
- **ZFS Cache:** Performance (ARC Hit Ratio) and size of the read cache.
- **Collapsible Rows:** All thematic groups can be collapsed for a better overview.

## Prerequisites
- A running TrueNAS SCALE system.
- Docker & Docker Compose are functional.
- The `smartmontools` package is installed on TrueNAS SCALE (usually by default).

---

## Setup Guide

### 1. Directory Structure
Create the following directory structure for your project. You can find all necessary configuration files within this repository.

```
/path/to/your/monitoring/
|-- compose.yaml
|-- prometheus.yml
|-- dashboard.json
|-- grafana-storage/
|-- graphite-mapping/
|   `-- mapping.yml
|-- scripts/
    `-- push_metrics.sh
```

### 2. Configuration
Before starting, you need to edit some of the configuration files:

* **`compose.yaml`**: Change the placeholder credentials (`CHANGE_ME`) for your Grafana admin user.
* **`prometheus.yml`**: Replace `YOUR_TRUENAS_IP` with the actual IP address of your TrueNAS server. Ensure the ports for the `graphite-exporter` (9108) and your system exporter (e.g., 9100) are correct.
* **`scripts/push_metrics.sh`**: Make the script executable by running `chmod +x scripts/push_metrics.sh`.

### 3. Set up the Script as a Cronjob

On your TrueNAS SCALE system, set up a cronjob to run the `push_metrics.sh` script regularly (e.g., every minute).
- **Command:** `/bin/bash /path/to/your/monitoring/scripts/push_metrics.sh`
- **Schedule:** Every minute (`* * * * *`)

### 4. Start the Stack
In the project's main directory, run the command to start all containers:
```bash
docker compose up -d
```

### 5. Set up Grafana
1.  Open Grafana in your browser (e.g., `http://YOUR_TRUENAS_IP:3100`).
2.  Log in with the credentials you set in `compose.yaml`.
3.  **Add the Data Source:**
    * Go to **Configuration** > **Data Sources** > **Add data source**.
    * Select **Prometheus**.
    * **URL**: `http://prometheus:9090`
    * Click **Save & test**.
4.  **Import the Dashboard:**
    * Go to the **+** icon > **Import dashboard**.
    * Click **Upload JSON file** and select the `dashboard.json` file from this repository.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
