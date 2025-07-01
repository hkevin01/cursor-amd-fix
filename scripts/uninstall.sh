#!/bin/bash

# Cursor AMD Fix Uninstall Script
# Removes all AMD optimizations and restores original system state

echo "🧹 Cursor AMD Fix Uninstall Script"
echo "=================================="
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

echo "Removing AMD optimizations and restoring original Cursor configuration..."
echo

# 1. Remove AMD environment configuration
print_info "Removing AMD environment configuration..."
if [ -f "/etc/environment.d/99-cursor-amd.conf" ]; then
    sudo rm -f /etc/environment.d/99-cursor-amd.conf
    print_status "Removed AMD environment configuration"
else
    print_status "AMD environment configuration not found"
fi

# 2. Remove AMD-optimized launcher
print_info "Removing AMD-optimized launcher..."
if [ -f "/usr/local/bin/cursor-amd" ]; then
    sudo rm -f /usr/local/bin/cursor-amd
    print_status "Removed AMD-optimized launcher"
else
    print_status "AMD-optimized launcher not found"
fi

# 3. Remove desktop entry
print_info "Removing desktop entry..."
if [ -f "/usr/share/applications/cursor-amd.desktop" ]; then
    sudo rm -f /usr/share/applications/cursor-amd.desktop
    print_status "Removed desktop entry"
else
    print_status "Desktop entry not found"
fi

# 4. Update desktop database
print_info "Updating desktop database..."
sudo update-desktop-database > /dev/null 2>&1
print_status "Desktop database updated"

# 5. Remove ptrace configuration (optional - ask user)
print_info "Checking ptrace configuration..."
if grep -q "kernel.yama.ptrace_scope = 0" /etc/sysctl.conf; then
    echo
    read -p "Remove ptrace_scope=0 from /etc/sysctl.conf? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo sed -i '/kernel.yama.ptrace_scope = 0/d' /etc/sysctl.conf
        print_status "Removed ptrace_scope configuration"
    else
        print_info "Keeping ptrace_scope configuration"
    fi
else
    print_status "No ptrace_scope configuration found"
fi

# 6. Remove AppArmor exceptions (if any)
print_info "Checking AppArmor exceptions..."
if command -v aa-status > /dev/null 2>&1; then
    if aa-status --enabled > /dev/null 2>&1; then
        print_info "AppArmor is active. Note: Manual cleanup may be needed."
        print_info "Check /etc/apparmor.d/ for any Cursor-specific profiles."
    fi
else
    print_status "AppArmor not installed"
fi

# 7. Check for any remaining AMD-specific files
print_info "Checking for remaining AMD-specific files..."
REMAINING_FILES=()

# Check for any remaining AMD environment files
if [ -f "/etc/environment.d/99-cursor-amd.conf" ]; then
    REMAINING_FILES+=("/etc/environment.d/99-cursor-amd.conf")
fi

# Check for any remaining launcher scripts
if [ -f "/usr/local/bin/cursor-amd" ]; then
    REMAINING_FILES+=("/usr/local/bin/cursor-amd")
fi

# Check for any remaining desktop entries
if [ -f "/usr/share/applications/cursor-amd.desktop" ]; then
    REMAINING_FILES+=("/usr/share/applications/cursor-amd.desktop")
fi

if [ ${#REMAINING_FILES[@]} -eq 0 ]; then
    print_status "All AMD-specific files removed successfully"
else
    print_warning "Some files could not be removed:"
    for file in "${REMAINING_FILES[@]}"; do
        echo "  - $file"
    done
    print_info "You may need to remove these manually with sudo"
fi

# 8. Test original Cursor
print_info "Testing original Cursor installation..."
if command -v cursor > /dev/null 2>&1; then
    print_status "Original Cursor found: $(which cursor)"
    echo
    print_info "You can now use the original Cursor with:"
    echo "  cursor"
else
    print_warning "Original Cursor not found in PATH"
    print_info "Check your Cursor installation:"
    echo "  - /opt/Cursor*/AppRun"
    echo "  - /snap/bin/cursor"
    echo "  - ~/.local/bin/cursor"
fi

echo
echo "🎉 Uninstall complete!"
echo
echo "Summary:"
echo "  • Removed AMD environment configuration"
echo "  • Removed AMD-optimized launcher"
echo "  • Removed desktop entry"
echo "  • Updated desktop database"
echo
echo "Your system has been restored to use the original Cursor installation."
echo "If you want to reinstall AMD optimizations, run:"
echo "  ./scripts/fix-cursor-ubuntu-amd.sh"
echo 