#!/bin/bash

# Simple loop runner for claude.sh

while true; do
    echo "=== Running agent ===" | tee -a claude.log
    ./claude.sh
    echo "Waiting 60 seconds..." | tee -a claude.log  
    sleep 60
done