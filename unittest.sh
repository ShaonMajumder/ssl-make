#!/usr/bin/env bash

# Check if bats is installed, and install it if not
if ! command -v bats &> /dev/null; then
    echo "bats is not installed. Installing bats..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y bats
    elif command -v yum &> /dev/null; then
        sudo yum install -y bats
    else
        echo "Unsupported package manager. Please install bats manually."
        exit 1
    fi
fi

./test.bats