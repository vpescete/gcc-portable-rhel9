#!/bin/bash

# GCC Portable Installation Script for RHEL 9.2
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check system
print_status "Checking system compatibility..."

if [ ! -f /etc/redhat-release ]; then
    print_error "This script is designed for Red Hat Enterprise Linux"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Setup installation directory
GCC_ROOT="$HOME/.local/gcc"
print_status "Installing to: $GCC_ROOT"

# Remove existing installation
if [ -d "$GCC_ROOT" ]; then
    print_warning "Removing existing installation..."
    rm -rf "$GCC_ROOT"
fi

# Create directories
mkdir -p "$GCC_ROOT"

# Extract main GCC archive
print_status "Extracting GCC installation..."
if [ -f "$SCRIPT_DIR/binaries/gcc-13.2.0-rhel9.tar.xz" ]; then
    cd "$GCC_ROOT"
    tar -xf "$SCRIPT_DIR/binaries/gcc-13.2.0-rhel9.tar.xz"
    print_success "GCC extracted successfully"
else
    print_error "GCC archive not found!"
    exit 1
fi

# Set permissions
print_status "Setting permissions..."
find "$GCC_ROOT/bin" -type f -exec chmod +x {} \; 2>/dev/null || true

# Detect GCC version directory
GCC_VERSION_DIR=$(find "$GCC_ROOT/lib/gcc" -name "x86_64-*-linux" -type d | head -n1)
if [ -n "$GCC_VERSION_DIR" ]; then
    GCC_LIB_DIR="$GCC_VERSION_DIR/$(ls "$GCC_VERSION_DIR" | head -n1)"
    print_status "Found GCC lib directory: $GCC_LIB_DIR"
else
    print_warning "Could not detect GCC lib directory, using default"
    GCC_LIB_DIR="$GCC_ROOT/lib/gcc/x86_64-redhat-linux/11"
fi

# Create activation script
print_status "Creating activation script..."
cat > "$GCC_ROOT/activate-gcc.sh" << EOD
#!/bin/bash

# GCC Environment Activation Script
GCC_ROOT="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"

# Detect GCC lib directory dynamically
GCC_LIB_DIR=\$(find "\$GCC_ROOT/lib/gcc" -name "x86_64-*-linux" -type d | head -n1)
if [ -n "\$GCC_LIB_DIR" ]; then
    GCC_LIB_DIR="\$GCC_LIB_DIR/\$(ls "\$GCC_LIB_DIR" | head -n1)"
fi

# Set environment variables
export GCC_HOME="\$GCC_ROOT"
export PATH="\$GCC_ROOT/bin:\$PATH"

# Set LD_LIBRARY_PATH with all necessary paths
export LD_LIBRARY_PATH="\$GCC_ROOT/lib64:\$GCC_ROOT/lib:\$GCC_LIB_DIR:\$LD_LIBRARY_PATH"

# Other library and include paths
export LIBRARY_PATH="\$GCC_ROOT/lib64:\$GCC_ROOT/lib:\$GCC_LIB_DIR:\$LIBRARY_PATH"
export C_INCLUDE_PATH="\$GCC_ROOT/include:\$C_INCLUDE_PATH"
export CPLUS_INCLUDE_PATH="\$GCC_ROOT/include:\$CPLUS_INCLUDE_PATH"

# Set compiler variables
export CC="\$GCC_ROOT/bin/gcc"
export CXX="\$GCC_ROOT/bin/g++"

# Remove empty entries from paths
export LD_LIBRARY_PATH=\$(echo "\$LD_LIBRARY_PATH" | tr ':' '\n' | grep -v '^$' | tr '\n' ':' | sed 's/:$//')
export LIBRARY_PATH=\$(echo "\$LIBRARY_PATH" | tr ':' '\n' | grep -v '^$' | tr '\n' ':' | sed 's/:$//')

echo "=== GCC Environment Activated ==="
echo "GCC Version: \$(gcc --version 2>/dev/null | head -1 || echo 'gcc not found')"
echo "GCC Home: \$GCC_HOME"
echo "LD_LIBRARY_PATH includes:"
echo "\$LD_LIBRARY_PATH" | tr ':' '\n' | grep gcc

# Quick verification
if [ -f "\$GCC_ROOT/bin/as" ]; then
    echo "✓ Assembler (as) found"
    # Check assembler dependencies
    if ldd "\$GCC_ROOT/bin/as" 2>/dev/null | grep -q "not found"; then
        echo "⚠ Warning: Assembler has missing dependencies"
        ldd "\$GCC_ROOT/bin/as" | grep "not found"
    fi
fi
EOD

chmod +x "$GCC_ROOT/activate-gcc.sh"

# Create convenience activation script in repo root  
cat > "$SCRIPT_DIR/activate-gcc.sh" << 'EOS'
#!/bin/bash

# Quick activation script
if [ -f "$HOME/.local/gcc/activate-gcc.sh" ]; then
    source "$HOME/.local/gcc/activate-gcc.sh"
else
    echo "GCC not installed. Run ./install-gcc.sh first"
    exit 1
fi
EOS

chmod +x "$SCRIPT_DIR/activate-gcc.sh"

# Verify installation
print_status "Verifying installation..."
cd "$GCC_ROOT"

# Check binaries
if [ -f "bin/gcc" ] && [ -f "bin/as" ]; then
    print_success "Core binaries installed"
else
    print_error "Missing core binaries!"
fi

# Check libraries
if ls lib64/*opcodes* 2>/dev/null || ls lib/gcc/*/libopcodes* 2>/dev/null; then
    print_success "Binutils libraries found"
else
    print_warning "Binutils libraries might be missing"
fi

print_success "Installation completed!"
echo
echo "To use GCC:"
echo "  source activate-gcc.sh"
echo "  gcc --version"
echo
echo "To compile examples:"
echo "  source activate-gcc.sh"
echo "  gcc examples/hello.c -o hello"
echo "  ./hello"
echo
echo "If you get library errors, you may need to rebuild the archive"
echo "using the updated create script that includes all binutils libraries."