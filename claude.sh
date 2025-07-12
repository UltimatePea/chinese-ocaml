#!/usr/bash


while true; do
    echo "Starting a new iteration..." $(date) | tee -a claude.log
    echo "Read AGENTS.md and start or continue working." | claude --verbose --continue | tee -a claude.log
    echo "Waiting for 1000 seconds before next iteration..." | tee -a claude.log
    sleep 1000
    echo "Restarting the loop..." | tee -a claude.log
done