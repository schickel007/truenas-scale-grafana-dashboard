#!/bin/bash

GRAPHITE_HOST="127.0.0.1"
GRAPHITE_PORT=2003
TS=$(date +%s)

# --- ZFS POOL STATS ---
unit_to_bytes() {
    num=$(echo "$1" | grep -oE '[0-9.]+')
    unit=$(echo "$1" | grep -oE '[A-Za-z]+')
    case "$unit" in
        B)    echo "$num" | awk '{printf "%.0f", $1}' ;;
        K|KB) echo "$num" | awk '{printf "%.0f", $1 * 1024}' ;;
        M|MB) echo "$num" | awk '{printf "%.0f", $1 * 1024^2}' ;;
        G|GB) echo "$num" | awk '{printf "%.0f", $1 * 1024^3}' ;;
        T|TB) echo "$num" | awk '{printf "%.0f", $1 * 1024^4}' ;;
        P|PB) echo "$num" | awk '{printf "%.0f", $1 * 1024^5}' ;;
        *) echo "0" ;;
    esac
}
for pool in $(zpool list -H -o name); do
    used_raw=$(zpool list -H -o allocated "$pool")
    free_raw=$(zpool list -H -o free "$pool")
    size_raw=$(zpool list -H -o size "$pool")
    capacity_percent=$(zpool list -H -o capacity "$pool" | tr -d '%')
    health=$(zpool list -H -o health "$pool")
    used=$(unit_to_bytes "$used_raw")
    free=$(unit_to_bytes "$free_raw")
    size=$(unit_to_bytes "$size_raw")
    case "$health" in
        ONLINE) health_value=1 ;;
        DEGRADED) health_value=0.5 ;;
        *) health_value=0 ;;
    esac
    echo "truenas.scale.zfs.pool.${pool}.used_bytes $used $TS" | nc -w 1 $GRAPHITE_HOST $GRAPHITE_PORT
    echo "truenas.scale.zfs.pool.${pool}.free_bytes $free $TS" | nc -w 1 $GRAPHITE_HOST $GRAPHITE_PORT
    echo "truenas.scale.zfs.pool.${pool}.size_bytes $size $TS" | nc -w 1 $GRAPHITE_HOST $GRAPHITE_PORT
    echo "truenas.scale.zfs.pool.${pool}.capacity_percent $capacity_percent $TS" | nc -w 1 $GRAPHITE_HOST $GRAPHITE_PORT
    echo "truenas.scale.zfs.pool.${pool}.health_status $health_value $TS" | nc -w 1 $GRAPHITE_HOST $GRAPHITE_PORT
done

# --- S.M.A.R.T. STATS ---
for disk_path in $(ls /dev/sd* | grep -v '[0-9]'); do
    disk=$(basename "$disk_path")
    reallocated=$(smartctl -A "/dev/$disk" | awk '/Reallocated_Sector_Ct/ {print $10}')
    pending=$(smartctl -A "/dev/$disk" | awk '/Current_Pending_Sector/ {print $10}')
    uncorrectable=$(smartctl -A "/dev/$disk" | awk '/Offline_Uncorrectable/ {print $10}')
    if [ -n "$reallocated" ]; then
        echo "truenas.scale.smart.disk.${disk}.reallocated_sectors $reallocated $TS" | nc -w 1 $GRAPHITE_HOST $GRAPHITE_PORT
    fi
    if [ -n "$pending" ]; then
        echo "truenas.scale.smart.disk.${disk}.pending_sectors $pending $TS" | nc -w 1 $GRAPHITE_HOST $GRAPHITE_PORT
    fi
    if [ -n "$uncorrectable" ]; then
        echo "truenas.scale.smart.disk.${disk}.uncorrectable_sectors $uncorrectable $TS" | nc -w 1 $GRAPHITE_HOST $GRAPHITE_PORT
    fi
done
