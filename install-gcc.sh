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

# Create activation script
print_status "Creating activation script..."
cat > "$GCC_ROOT/activate-gcc.sh" << 'EOD'
#!/bin/bash

# GCC Environment Activation Script
GCC_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PATH="$GCC_ROOT/bin:$PATH"
export LD_LIBRARY_PATH="$GCC_ROOT/lib64:$GCC_ROOT/lib:$LD_LIBRARY_PATH"
export LIBRARY_PATH="$GCC_ROOT/lib64:$GCC_ROOT/lib:$LIBRARY_PATH"
export C_INCLUDE_PATH="$GCC_ROOT/include:$C_INCLUDE_PATH"
export CPLUS_INCLUDE_PATH="$GCC_ROOT/include:$CPLUS_INCLUDE_PATH"

export CC="$GCC_ROOT/bin/gcc"
export CXX="$GCC_ROOT/bin/g++"

echo "GCC environment activated!"
echo "GCC: $(gcc --version 2>/dev/null | head -1 || echo 'gcc not found')"
EOD

chmod +x "$GCC_ROOT/activate-gcc.sh"

# Create convenience activation script in repo root
cp "$GCC_ROOT/activate-gcc.sh" "$SCRIPT_DIR/"

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
