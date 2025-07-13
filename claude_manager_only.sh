#!/usr/bash

PROMPT="Read CLAUDE.md and start or continue working. You are the manager agent."

if [[ "$(basename "$PWD")" != *chinese-ocaml ]]; then
    echo "Error: Current directory's base name must end with 'chinese-ocaml'." >&2
    exit 1
fi

while true; do
    echo "Starting a new iteration..." $(date) | tee -a claude.log
    claude "$PROMPT" -p --verbose --output-format stream-json | tee -a claude.log
    echo "Waiting for 60 seconds before next iteration..." | tee -a claude.log
    sleep 60
    echo "Restarting the loop..." | tee -a claude.log
done