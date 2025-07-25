#!/bin/bash

# Multi-Agent Collaboration System Configuration
# Each agent has: name, prompt, and run_interval (how often they run)

# Agent Definitions
declare -A AGENTS
declare -A AGENT_PROMPTS
declare -A AGENT_INTERVALS

# Alpha Agent - Main Worker (runs every iteration)
AGENTS["alpha"]="Alpha"
AGENT_PROMPTS["alpha"]="You are an agent called Alpha. You are the primary worker agent responsible for implementing features, fixing bugs, and handling technical debt. Read CLAUDE.md and start or continue working."
AGENT_INTERVALS["alpha"]=1

# Beta Agent - Code Reviewer (runs every 5 iterations)
AGENTS["beta"]="Beta"
AGENT_PROMPTS["beta"]="You are an agent called Beta. You are the code reviewer agent responsible for reviewing pull requests, checking code quality, and ensuring standards compliance. Read CLAUDE.md and start working."
AGENT_INTERVALS["beta"]=5

# Charlie Agent - Planner (runs every 10 iterations)
AGENTS["charlie"]="Charlie"
AGENT_PROMPTS["charlie"]="You are an agent called Charlie. You are the planner agent responsible for strategic planning, architecture decisions, and organizing work priorities. Read CLAUDE.md and start working."
AGENT_INTERVALS["charlie"]=10

# Delta Agent - Critic (runs every 20 iterations)
AGENTS["delta"]="Delta"
AGENT_PROMPTS["delta"]="You are an agent called Delta. You are the critic agent responsible for criticizing other agents' work, raising issues, commenting on PRs, and identifying potential problems. Read CLAUDE.md and start working."
AGENT_INTERVALS["delta"]=20

# Echo Agent - Test Engineer (runs every 8 iterations)
AGENTS["echo"]="Echo"
AGENT_PROMPTS["echo"]="You are an agent called Echo. You are the test engineer agent responsible for writing tests, improving test coverage, and ensuring code quality through testing. Read CLAUDE.md and start working."
AGENT_INTERVALS["echo"]=8

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

# Determine which agents should run based on iteration number
AGENTS_TO_RUN=()
for agent in "${!AGENTS[@]}"; do
    interval=${AGENT_INTERVALS[$agent]}
    if (( NEW_ITERATION % interval == 0 )); then
        AGENTS_TO_RUN+=($agent)
    fi
done

# If no agents scheduled, run Alpha (primary worker)
if [[ ${#AGENTS_TO_RUN[@]} -eq 0 ]]; then
    AGENTS_TO_RUN=("alpha")
fi

# Run scheduled agents
for agent in "${AGENTS_TO_RUN[@]}"; do
    agent_name=${AGENTS[$agent]}
    agent_prompt=${AGENT_PROMPTS[$agent]}
    
    echo "Running agent $agent_name (iteration $NEW_ITERATION)" | tee -a claude.log
    echo "Agent prompt: $agent_prompt" | tee -a claude.log
    
    claude "$agent_prompt" -p --verbose --output-format stream-json | tee -a claude.log
    
    echo "Agent $agent_name completed" | tee -a claude.log
done

echo "Iteration $NEW_ITERATION completed at $(date)" | tee -a claude.log
