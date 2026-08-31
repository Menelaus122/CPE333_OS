#!/bin/bash
# CPE 333 PS03 - Q2, second situation
# Calls "sleep" with 1000 seconds, so the script stays alive long enough
# to be suspended with CTRL+Z and resumed again with fg / bg.

echo "[ss1_2] start  pid=$$  at $(date +%T)"

sleep 1000

echo "[ss1_2] done   pid=$$  at $(date +%T)"
