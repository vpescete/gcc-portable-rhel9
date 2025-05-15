#!/bin/bash

# Quick activation script with debug information
if [ -f "$HOME/.local/gcc/activate-gcc.sh" ]; then
    # Source the actual activation script
    source "$HOME/.local/gcc/activate-gcc.sh"
    
    # Debug: Show current environment
    echo "=== GCC Environment Activated ==="
    echo "GCC_HOME: $GCC_HOME"
    echo "PATH: $PATH" | tr ':' '\n' | grep gcc || echo "No GCC in PATH"
    echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH" | tr ':' '\n' | grep gcc || echo "No GCC libs in LD_LIBRARY_PATH"
    
    # Check critical files
    echo "=== Checking Critical Files ==="
    if [ -f "$GCC_HOME/bin/gcc" ]; then
        echo "✓ GCC binary found"
    else
        echo "✗ GCC binary NOT found"
    fi
    
    if [ -f "$GCC_HOME/bin/as" ]; then
        echo "✓ Assembler (as) found"
        # Check if as can find its libraries
        if ldd "$GCC_HOME/bin/as" 2>/dev/null | grep -q "not found"; then
            echo "✗ Assembler has missing libraries:"
            ldd "$GCC_HOME/bin/as" | grep "not found"
        else
            echo "✓ Assembler libraries OK"
        fi
    else
        echo "✗ Assembler (as) NOT found"
    fi
    
    # Check for libopcodes specifically
    if find "$GCC_HOME" -name "*libopcodes*" 2>/dev/null | head -1; then
        echo "✓ libopcodes found"
    else
        echo "✗ libopcodes NOT found"
    fi
    
    # Quick test
    echo "=== Quick Test ==="
    if gcc --version &>/dev/null; then
        echo "✓ GCC responds to --version"
    else
        echo "✗ GCC does not respond"
    fi
    
else
    echo "[ERROR] GCC not installed in $HOME/.local/gcc/"
    echo "Expected file: $HOME/.local/gcc/activate-gcc.sh"
    echo "Run ./install-gcc.sh first"
    exit 1
fi