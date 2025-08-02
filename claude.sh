#!/bin/bash

# Custom Agent Runner

ITERATION_FILE="../ITERATION.txt"

if [[ "$(basename "$PWD")" != *chinese-ocaml ]]; then
    echo "Error: Current directory's base name must end with 'chinese-ocaml'." >&2
    exit 1
fi

# Initialize iteration file if it doesn't exist
if [[ ! -f "$ITERATION_FILE" ]]; then
    echo "0" > "$ITERATION_FILE"
fi

# Read current iteration count
ITERATION=$(cat "$ITERATION_FILE")
echo "Current iteration: $ITERATION" | tee -a claude.log

# Increment iteration count
NEW_ITERATION=$((ITERATION + 1))
echo "$NEW_ITERATION" > "$ITERATION_FILE"

echo "Starting iteration $NEW_ITERATION..." $(date) | tee -a claude.log

# Run claude with the assessment prompt
claude "Assess the project state and repeatedly running the entry-coordination-echo custom agent" -p --verbose --output-format stream-json | tee -a claude.log

echo "Iteration $NEW_ITERATION completed at $(date)" | tee -a claude.log
