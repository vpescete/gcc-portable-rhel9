#!/bin/bash

# Fix LD_LIBRARY_PATH for GCC if needed

# Check if GCC is activated
if [ -z "$GCC_HOME" ]; then
    echo "GCC_HOME not set. Run ./activate-gcc.sh first"
    exit 1
fi

# Add all possible library paths
export LD_LIBRARY_PATH="$GCC_HOME/lib64:$GCC_HOME/lib:$GCC_HOME/lib/gcc/x86_64-redhat-linux/11:$LD_LIBRARY_PATH"

# Remove duplicate entries
export LD_LIBRARY_PATH=$(echo "$LD_LIBRARY_PATH" | tr ':' '\n' | awk '!x[$0]++' | tr '\n' ':' | sed 's/:$//')

echo "Updated LD_LIBRARY_PATH:"
echo "$LD_LIBRARY_PATH" | tr ':' '\n'

# Test if the fix worked
echo "Testing GCC compilation..."
cd /tmp
echo '#include <stdio.h>' > gcc_test.c
echo 'int main(){printf("GCC works!\n");return 0;}' >> gcc_test.c

if gcc gcc_test.c -o gcc_test 2>&1; then
    echo "✓ Compilation successful!"
    if ./gcc_test; then
        echo "✓ Execution successful!"
    else
        echo "✗ Execution failed"
    fi
else
    echo "✗ Compilation failed"
    echo "Try running the updated script to create a complete archive"
fi

rm -f gcc_test.c gcc_test