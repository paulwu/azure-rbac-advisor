#!/usr/bin/env bash
# setup.sh — Run once after cloning to create runtime directories for the Azure RBAC Advisor agent.
set -e
mkdir -p log answer
touch log/.gitkeep answer/.gitkeep
echo "✅ log/ and answer/ directories ready."
