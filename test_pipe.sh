#!/bin/bash

# Test script to simulate the curl pipe behavior
echo "Testing piped execution..."

# Create a test file that contains the cct.sh content
cat cct.sh | bash -s install
