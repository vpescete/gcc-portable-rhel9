#!/bin/bash

# GCC Portable Environment Activation Script for RHEL 9.2
# Source this script to activate the GCC environment

# Determine the GCC installation path
if [ -d "$HOME/.local/gcc" ]; then
    GCC_ROOT="$HOME/.local/gcc"
elif [ -d "$(dirname "${BASH_SOURCE[0]}")/../.local/gcc" ]; then
    GCC_ROOT="$(dirname "${BASH_SOURCE[0]}")/../.local/gcc"
else
    echo "Error: GCC installation not found!"
    echo "Expected location: $HOME/.local/gcc"
    return 1
fi

# Export GCC paths
export PATH="$GCC_ROOT/bin:$PATH"
export LD_LIBRARY_PATH="$GCC_ROOT/lib64:$GCC_ROOT/lib:$LD_LIBRARY_PATH"
export LIBRARY_PATH="$GCC_ROOT/lib64:$GCC_ROOT/lib:$LIBRARY_PATH"
export C_INCLUDE_PATH="$GCC_ROOT/include:$C_INCLUDE_PATH"
export CPLUS_INCLUDE_PATH="$GCC_ROOT/include:$CPLUS_INCLUDE_PATH"
export PKG_CONFIG_PATH="$GCC_ROOT/lib64/pkgconfig:$GCC_ROOT/lib/pkgconfig:$PKG_CONFIG_PATH"

# Set GCC specific environment variables
export CC="$GCC_ROOT/bin/gcc"
export CXX="$GCC_ROOT/bin/g++"
export CPP="$GCC_ROOT/bin/cpp"

# Set additional development tools
export AR="$GCC_ROOT/bin/ar"
export RANLIB="$GCC_ROOT/bin/ranlib"
export STRIP="$GCC_ROOT/bin/strip"
export NM="$GCC_ROOT/bin/nm"
export OBJDUMP="$GCC_ROOT/bin/objdump"
export OBJCOPY="$GCC_ROOT/bin/objcopy"
export READELF="$GCC_ROOT/bin/readelf"
export SIZE="$GCC_ROOT/bin/size"

# Set Make
export MAKE="$GCC_ROOT/bin/make"

# Print activation message
echo "🚀 GCC Portable Environment Activated!"
echo "📍 Installation: $GCC_ROOT"

# Display versions if tools are available
if command -v gcc &> /dev/null; then
    echo "🔧 GCC Version: $(gcc --version | head -1 | awk '{print $3}')"
fi

if command -v make &> /dev/null; then
    echo "🔨 Make Version: $(make --version | head -1 | awk '{print $3}')"
fi

echo "✅ Ready to compile C/C++ programs!"
echo
echo "Quick test:"
echo "  gcc --version"
echo "  g++ --version"
echo
echo "To run full tests:"
echo "  ~/.local/gcc/test-gcc.sh"