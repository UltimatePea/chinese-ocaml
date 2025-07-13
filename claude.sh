#!/usr/bash

PROMPT="Read CLAUDE.md and start or continue working. You are the manager agent."

while true; do
    echo "Starting a new iteration..." $(date) | tee -a claude.log
    claude "$PROMPT" -p --verbose --output-format stream-json | tee -a claude.log
    echo "Waiting for 60 seconds before next iteration..." | tee -a claude.log
    sleep 60
    echo "Restarting the loop..." | tee -a claude.log
done