# GCC Portable for RHEL 9.2

Portable GCC installation for Red Hat Enterprise Linux 9.2 systems without internet access.

## Quick Start

```bash
# Clone this repository
git clone https://github.com/your-username/gcc-portable-rhel9.git
cd gcc-portable-rhel9

# Install GCC
./install-gcc.sh

# Activate GCC environment
source activate-gcc.sh

# Test installation
gcc --version
gcc examples/hello.c -o hello
./hello
```

## Contents

- **GCC 11+**: C and C++ compiler
- **Make**: Build automation tool  
- **Binutils**: Assembler, linker, and other tools
- **Development headers**: Standard C/C++ libraries

## Installation

The installation creates a portable GCC environment in `~/.local/gcc/` without modifying your system.

## Usage

After installation, activate the environment in each session:

```bash
source activate-gcc.sh
```

Or add to your `~/.bashrc` for permanent activation:

```bash
echo "source ~/.local/gcc/activate-gcc.sh" >> ~/.bashrc
```

## Examples

The `examples/` directory contains:
- `hello.c` - Basic C program
- `hello.cpp` - Basic C++ program  
- `math_example.c` - Program using math library

## Troubleshooting

If you encounter issues:

1. Ensure you're on RHEL 9.x: `cat /etc/redhat-release`
2. Check installation: `ls ~/.local/gcc/bin/gcc`
3. Verify activation: `which gcc` (should show gcc in .local/gcc/bin)
4. Test compilation: `gcc examples/hello.c -o test && ./test`

## Requirements

- RHEL 9.x or compatible (Rocky Linux, AlmaLinux)
- ~200MB disk space
- Git access for initial clone

## Note

This GCC installation is portable and self-contained. It can be uninstalled by simply removing the `~/.local/gcc/` directory.
