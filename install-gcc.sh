#!/bin/bash

# GCC Portable Installation Script for RHEL 9.2
# Installs GCC and dependencies without internet access

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
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

# Check if running on RHEL 9
check_system() {
    print_status "Checking system compatibility..."
    
    if [ ! -f /etc/redhat-release ]; then
        print_error "This script is designed for Red Hat Enterprise Linux"
        exit 1
    fi
    
    RHEL_VERSION=$(cat /etc/redhat-release | grep -o '[0-9]\+\.[0-9]\+' | head -1)
    MAJOR_VERSION=$(echo $RHEL_VERSION | cut -d. -f1)
    
    if [ "$MAJOR_VERSION" != "9" ]; then
        print_warning "This script is optimized for RHEL 9.x, you're running $RHEL_VERSION"
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    print_success "System check passed"
}

# Create installation directory
setup_directories() {
    print_status "Setting up installation directories..."
    
    export GCC_ROOT="$HOME/.local/gcc"
    export GCC_BIN="$GCC_ROOT/bin"
    export GCC_LIB="$GCC_ROOT/lib"
    export GCC_LIB64="$GCC_ROOT/lib64"
    export GCC_INCLUDE="$GCC_ROOT/include"
    export GCC_LIBEXEC="$GCC_ROOT/libexec"
    
    # Remove existing installation if present
    if [ -d "$GCC_ROOT" ]; then
        print_warning "Existing GCC installation found. Removing..."
        rm -rf "$GCC_ROOT"
    fi
    
    # Create directories
    mkdir -p "$GCC_ROOT"
    mkdir -p "$GCC_BIN"
    mkdir -p "$GCC_LIB"
    mkdir -p "$GCC_LIB64"
    mkdir -p "$GCC_INCLUDE"
    mkdir -p "$GCC_LIBEXEC"
    
    print_success "Directories created in $GCC_ROOT"
}

# Extract binaries and libraries
extract_packages() {
    print_status "Extracting GCC and dependencies..."
    
    # Get script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Extract GCC
    if [ -f "$SCRIPT_DIR/binaries/gcc-13.2.0-rhel9.tar.xz" ]; then
        print_status "Extracting GCC 13.2.0..."
        cd "$GCC_ROOT"
        tar -xf "$SCRIPT_DIR/binaries/gcc-13.2.0-rhel9.tar.xz" --strip-components=1
    else
        print_error "GCC binary package not found!"
        exit 1
    fi
    
    # Extract binutils
    if [ -f "$SCRIPT_DIR/binaries/binutils-2.40.tar.xz" ]; then
        print_status "Extracting binutils..."
        cd "$GCC_ROOT"
        tar -xf "$SCRIPT_DIR/binaries/binutils-2.40.tar.xz" --strip-components=1
    fi
    
    # Extract glibc headers
    if [ -f "$SCRIPT_DIR/binaries/glibc-headers.tar.xz" ]; then
        print_status "Extracting glibc headers..."
        cd "$GCC_ROOT"
        tar -xf "$SCRIPT_DIR/binaries/glibc-headers.tar.xz" --strip-components=1
    fi
    
    # Extract additional libraries
    if [ -f "$SCRIPT_DIR/libs/libc6-dev-rhel9.tar.xz" ]; then
        print_status "Extracting development libraries..."
        cd "$GCC_ROOT"
        tar -xf "$SCRIPT_DIR/libs/libc6-dev-rhel9.tar.xz" --strip-components=1
    fi
    
    # Extract kernel headers
    if [ -f "$SCRIPT_DIR/libs/linux-headers.tar.xz" ]; then
        print_status "Extracting Linux headers..."
        cd "$GCC_ROOT"
        tar -xf "$SCRIPT_DIR/libs/linux-headers.tar.xz" --strip-components=1
    fi
    
    print_success "All packages extracted successfully"
}

# Set correct permissions
fix_permissions() {
    print_status "Setting correct permissions..."
    
    # Make all executables in bin/ executable
    chmod +x "$GCC_BIN"/*
    
    # Set proper permissions for shared libraries
    find "$GCC_LIB" "$GCC_LIB64" -name "*.so*" -exec chmod 755 {} \; 2>/dev/null || true
    
    print_success "Permissions set correctly"
}

# Create activation script
create_activation_script() {
    print_status "Creating environment activation script..."
    
    cat > "$GCC_ROOT/activate-gcc.sh" << 'EOF'
#!/bin/bash

# GCC Portable Environment Activation Script

# Get the directory where this script is located
GCC_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Export GCC paths
export PATH="$GCC_ROOT/bin:$PATH"
export LD_LIBRARY_PATH="$GCC_ROOT/lib64:$GCC_ROOT/lib:$LD_LIBRARY_PATH"
export LIBRARY_PATH="$GCC_ROOT/lib64:$GCC_ROOT/lib:$LIBRARY_PATH"
export C_INCLUDE_PATH="$GCC_ROOT/include:$C_INCLUDE_PATH"
export CPLUS_INCLUDE_PATH="$GCC_ROOT/include:$CPLUS_INCLUDE_PATH"
export PKG_CONFIG_PATH="$GCC_ROOT/lib64/pkgconfig:$GCC_ROOT/lib/pkgconfig:$PKG_CONFIG_PATH"

# Set GCC specific environment
export CC="$GCC_ROOT/bin/gcc"
export CXX="$GCC_ROOT/bin/g++"
export CPP="$GCC_ROOT/bin/cpp"

# Set additional tool paths
export AR="$GCC_ROOT/bin/ar"
export RANLIB="$GCC_ROOT/bin/ranlib"
export STRIP="$GCC_ROOT/bin/strip"
export NM="$GCC_ROOT/bin/nm"
export OBJDUMP="$GCC_ROOT/bin/objdump"

echo "GCC environment activated!"
echo "GCC Version: $(gcc --version | head -1)"
echo "Installation path: $GCC_ROOT"
EOF
    
    chmod +x "$GCC_ROOT/activate-gcc.sh"
    
    # Also create a copy in the main directory for convenience
    cp "$GCC_ROOT/activate-gcc.sh" "$SCRIPT_DIR/"
    
    print_success "Activation script created"
}

# Create test script
create_test_script() {
    print_status "Creating test script..."
    
    cat > "$GCC_ROOT/test-gcc.sh" << 'EOF'
#!/bin/bash

# GCC Installation Test Script

# Activate GCC environment
source "$(dirname "$0")/activate-gcc.sh"

echo "=== Testing GCC Installation ==="
echo

# Test GCC version
echo "GCC Version:"
gcc --version
echo

# Test G++ version
echo "G++ Version:"
g++ --version
echo

# Test Make
echo "Make Version:"
make --version | head -1
echo

# Create and compile a simple C program
echo "Testing C compilation..."
cat > /tmp/test_gcc.c << 'EOC'
#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("Hello from GCC on RHEL 9!\n");
    printf("Compiler: %s\n", __VERSION__);
    return 0;
}
EOC

gcc /tmp/test_gcc.c -o /tmp/test_gcc
if [ $? -eq 0 ]; then
    echo "✓ C compilation successful"
    echo "Output:"
    /tmp/test_gcc
else
    echo "✗ C compilation failed"
    exit 1
fi
echo

# Create and compile a simple C++ program
echo "Testing C++ compilation..."
cat > /tmp/test_gxx.cpp << 'EOC'
#include <iostream>
#include <vector>

int main() {
    std::cout << "Hello from G++ on RHEL 9!" << std::endl;
    std::vector<int> v = {1, 2, 3, 4, 5};
    std::cout << "Vector size: " << v.size() << std::endl;
    return 0;
}
EOC

g++ /tmp/test_gxx.cpp -o /tmp/test_gxx
if [ $? -eq 0 ]; then
    echo "✓ C++ compilation successful"
    echo "Output:"
    /tmp/test_gxx
else
    echo "✗ C++ compilation failed"
    exit 1
fi

echo
echo "=== All tests passed! GCC is working correctly ==="

# Cleanup
rm -f /tmp/test_gcc.c /tmp/test_gcc /tmp/test_gxx.cpp /tmp/test_gxx
EOF
    
    chmod +x "$GCC_ROOT/test-gcc.sh"
    
    print_success "Test script created"
}

# Print final instructions
print_final_instructions() {
    print_success "GCC installation completed successfully!"
    echo
    echo "=== Next Steps ==="
    echo "1. Activate the GCC environment:"
    echo "   source activate-gcc.sh"
    echo
    echo "2. Verify the installation:"
    echo "   gcc --version"
    echo
    echo "3. Run tests:"
    echo "   ~/.local/gcc/test-gcc.sh"
    echo
    echo "4. To make GCC available in all new terminals, add this to ~/.bashrc:"
    echo "   echo 'source ~/.local/gcc/activate-gcc.sh' >> ~/.bashrc"
    echo
    echo "=== Installation Details ==="
    echo "Installation path: $GCC_ROOT"
    echo "Installed components:"
    echo "- GCC 13.2.0"
    echo "- G++ 13.2.0"
    echo "- Make"
    echo "- Binutils"
    echo "- Development headers"
    echo
    print_success "Ready to compile!"
}

# Main installation sequence
main() {
    echo "=== GCC Portable Installation for RHEL 9.2 ==="
    echo
    
    check_system
    setup_directories
    extract_packages
    fix_permissions
    create_activation_script
    create_test_script
    print_final_instructions
}

# Run main function
main