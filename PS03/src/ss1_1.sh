#!/bin/bash
# CPE 333 PS03 - Q2, first situation
# Calls "sleep" for a total of 10 seconds, one second per iteration,
# so the progress can be watched while the script is running.

echo "[ss1_1] start  pid=$$  at $(date +%T)"

for i in $(seq 1 10); do
    sleep 1
    echo "[ss1_1] tick $i/10"
done

echo "[ss1_1] done   pid=$$  at $(date +%T)"
