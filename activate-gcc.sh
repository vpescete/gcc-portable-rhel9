#!/bin/bash

# Quick activation script
if [ -f "$HOME/.local/gcc/activate-gcc.sh" ]; then
    source "$HOME/.local/gcc/activate-gcc.sh"
else
    echo "GCC not installed. Run ./install-gcc.sh first"
    exit 1
fi
