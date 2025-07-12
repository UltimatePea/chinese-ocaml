#!/bin/bash

fifo=$(mktemp -u)
mkfifo "$fifo"

# Start Claude, reading stdin from the FIFO
claude --verbose --continue < "$fifo" &

# In the background, write into the FIFO every 30 minutes
while true; do
    echo "Read AGENTS.md and start working" > "$fifo"
    sleep 1800
done
