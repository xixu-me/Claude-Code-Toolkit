#!/bin/bash

# Simple test to verify the safe_read function works
echo "Testing safe_read function..."

# Source the functions from cct.sh but don't run the main part
source <(sed -n '1,/^case.*\$1.*in$/p' cct.sh | head -n -1)

echo "Please test entering a value:"
safe_read test_var "Enter test value: "
echo "You entered: '$test_var'"
