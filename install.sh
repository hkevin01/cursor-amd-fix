#!/bin/bash

# Cursor AMD Fix - Installation Script
# Easy installation script for AMD optimizations

echo "🚀 Cursor AMD Fix - Installation Script"
echo "======================================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Run without sudo."
   exit 1
fi

# Check if we're in the right directory
if [ ! -f "scripts/fix-cursor-ubuntu-amd.sh" ]; then
    print_error "Please run this script from the cursor-amd-fix directory"
    exit 1
fi

echo "This script will install AMD optimizations for Cursor IDE."
echo "It will:"
echo "  • Fix ptrace restrictions"
echo "  • Install AMD graphics dependencies"
echo "  • Configure AMD environment variables"
echo "  • Create AMD-optimized launcher"
echo "  • Set up desktop integration"
echo

# Check for AMD GPU
if lspci | grep -i "vga.*amd\|vga.*radeon" > /dev/null; then
    GPU_INFO=$(lspci | grep -i "vga.*amd\|vga.*radeon")
    print_status "AMD GPU detected: $GPU_INFO"
else
    print_warning "No AMD GPU detected. This script is designed for AMD graphics."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled."
        exit 0
    fi
fi

# Check for Cursor installation
CURSOR_FOUND=false
if [ -f "/opt/Cursor-patched/AppRun" ] || [ -f "/snap/bin/cursor" ] || command -v cursor > /dev/null 2>&1; then
    CURSOR_FOUND=true
fi

if [ "$CURSOR_FOUND" = false ]; then
    print_warning "Cursor IDE not found. Please install Cursor first."
    echo "You can install Cursor from:"
    echo "  • https://cursor.sh/ (official website)"
    echo "  • Snap: sudo snap install cursor"
    echo "  • Or download the AppImage"
    echo
    read -p "Continue with installation anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled."
        exit 0
    fi
else
    print_status "Cursor IDE installation detected"
fi

echo
print_info "Starting AMD optimization installation..."
echo

# Run the main fix script
if ./scripts/fix-cursor-ubuntu-amd.sh; then
    echo
    print_status "Installation completed successfully!"
    echo
    echo "🎉 AMD optimizations for Cursor IDE are now installed!"
    echo
    echo "Next steps:"
    echo "  • Restart your system to apply all changes"
    echo "  • Use 'cursor-amd' to launch Cursor with AMD optimizations"
    echo "  • Or find 'Cursor (AMD Optimized)' in your applications menu"
    echo
    echo "Testing:"
    echo "  • Run './scripts/test-amd-graphics.sh' to test your AMD graphics"
    echo "  • Run 'cursor-amd' to test the optimized launcher"
    echo
    echo "Troubleshooting:"
    echo "  • Run './scripts/uninstall.sh' to remove optimizations"
    echo "  • Check the README.md for detailed information"
    echo
else
    echo
    print_error "Installation failed. Please check the error messages above."
    echo
    echo "Troubleshooting:"
    echo "  • Make sure you have sudo privileges"
    echo "  • Check that your system is up to date"
    echo "  • Try running './scripts/test-amd-graphics.sh' first"
    echo
    exit 1
fi 