#!/bin/bash

# AMD Graphics Testing Script for Cursor IDE
# Tests AMD GPU detection, driver support, and hardware acceleration

echo "🔍 AMD Graphics Testing Script"
echo "=============================="
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

# Function to test command availability
test_command() {
    if command -v "$1" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to check if a file exists
test_file() {
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}

echo "Testing AMD graphics configuration for Cursor IDE..."
echo

# 1. Check for AMD GPU
print_info "1. AMD GPU Detection"
echo "========================"

if lspci | grep -i "vga.*amd\|vga.*radeon" > /dev/null; then
    GPU_INFO=$(lspci | grep -i "vga.*amd\|vga.*radeon")
    print_status "AMD GPU detected: $GPU_INFO"
    
    # Get detailed GPU info
    echo "Detailed GPU information:"
    lspci -v -s $(lspci | grep -i "vga.*amd\|vga.*radeon" | cut -d' ' -f1) 2>/dev/null | grep -E "(Kernel driver|Kernel modules)" || echo "  No driver information available"
else
    print_error "No AMD GPU detected"
    echo "Available graphics cards:"
    lspci | grep -i vga || echo "  No VGA controllers found"
fi

echo

# 2. Check AMD drivers
print_info "2. AMD Driver Status"
echo "======================="

# Check for amdgpu driver
if lsmod | grep -q amdgpu; then
    print_status "AMDGPU driver loaded"
    lsmod | grep amdgpu | head -1
else
    print_warning "AMDGPU driver not loaded"
fi

# Check for radeon driver
if lsmod | grep -q radeon; then
    print_status "Radeon driver loaded"
    lsmod | grep radeon | head -1
else
    print_warning "Radeon driver not loaded"
fi

# Check for AMD driver files
if test_file "/sys/class/drm/card0/device/driver"; then
    DRIVER_PATH=$(readlink /sys/class/drm/card0/device/driver)
    DRIVER_NAME=$(basename "$DRIVER_PATH")
    print_status "Primary GPU driver: $DRIVER_NAME"
else
    print_warning "No primary GPU driver found"
fi

echo

# 3. Check Mesa drivers
print_info "3. Mesa Graphics Drivers"
echo "============================"

# Check Mesa version
if test_command "glxinfo"; then
    MESA_VERSION=$(glxinfo | grep "OpenGL version" | head -1 | cut -d' ' -f4)
    print_status "Mesa version: $MESA_VERSION"
else
    print_warning "glxinfo not available (install mesa-utils)"
fi

# Check for Mesa drivers
MESA_DRIVERS=("libgl1-mesa-dri" "mesa-vulkan-drivers" "mesa-va-drivers" "mesa-vdpau-drivers")
for driver in "${MESA_DRIVERS[@]}"; do
    if dpkg -l | grep -q "$driver"; then
        print_status "$driver installed"
    else
        print_warning "$driver not installed"
    fi
done

echo

# 4. Test OpenGL support
print_info "4. OpenGL Support"
echo "==================="

if test_command "glxinfo"; then
    # Test direct rendering
    if glxinfo | grep -i "direct rendering: yes" > /dev/null; then
        print_status "Direct rendering enabled"
    else
        print_warning "Direct rendering disabled"
    fi
    
    # Get OpenGL renderer
    RENDERER=$(glxinfo | grep "OpenGL renderer" | cut -d: -f2 | xargs)
    if echo "$RENDERER" | grep -i "amd\|radeon\|ati" > /dev/null; then
        print_status "AMD OpenGL renderer: $RENDERER"
    else
        print_warning "OpenGL renderer: $RENDERER (may not be AMD)"
    fi
    
    # Get OpenGL version
    OPENGL_VERSION=$(glxinfo | grep "OpenGL version" | cut -d: -f2 | xargs)
    print_status "OpenGL version: $OPENGL_VERSION"
else
    print_warning "glxinfo not available - cannot test OpenGL"
fi

echo

# 5. Test Vulkan support
print_info "5. Vulkan Support"
echo "==================="

if test_command "vulkaninfo"; then
    if vulkaninfo | grep -i "radeon\|amd" > /dev/null; then
        print_status "AMD Vulkan support detected"
        vulkaninfo | grep -i "radeon\|amd" | head -3
    else
        print_warning "AMD Vulkan support not detected"
    fi
else
    print_warning "vulkaninfo not available - cannot test Vulkan"
fi

echo

# 6. Test VA-API support
print_info "6. VA-API Video Acceleration"
echo "================================="

if test_command "vainfo"; then
    if vainfo > /dev/null 2>&1; then
        print_status "VA-API working"
        echo "Available VA profiles:"
        vainfo | grep "VAProfile" | head -5
    else
        print_warning "VA-API not working properly"
    fi
else
    print_warning "vainfo not available - cannot test VA-API"
fi

echo

# 7. Test VDPAU support
print_info "7. VDPAU Video Acceleration"
echo "==============================="

if test_command "vdpauinfo"; then
    if vdpauinfo > /dev/null 2>&1; then
        print_status "VDPAU working"
        echo "Available VDPAU profiles:"
        vdpauinfo | grep "Decoder" | head -3
    else
        print_warning "VDPAU not working properly"
    fi
else
    print_warning "vdpauinfo not available - cannot test VDPAU"
fi

echo

# 8. Check environment variables
print_info "8. AMD Environment Variables"
echo "================================"

AMD_ENV_VARS=("LIBVA_DRIVER_NAME" "VDPAU_DRIVER" "RADV_PERFTEST" "AMD_VULKAN_ICD" "MESA_LOADER_DRIVER_OVERRIDE")
for var in "${AMD_ENV_VARS[@]}"; do
    if [ -n "${!var}" ]; then
        print_status "$var = ${!var}"
    else
        print_warning "$var not set"
    fi
done

# Check AMD environment configuration
if test_file "/etc/environment.d/99-cursor-amd.conf"; then
    print_status "AMD environment configuration found"
else
    print_warning "AMD environment configuration not found"
fi

echo

# 9. Test Cursor installation
print_info "9. Cursor Installation"
echo "========================="

CURSOR_FOUND=false

# Check different Cursor installation locations
if test_file "/opt/Cursor-patched/AppRun"; then
    print_status "Cursor-patched found: /opt/Cursor-patched/AppRun"
    CURSOR_FOUND=true
fi

if test_file "/snap/bin/cursor"; then
    print_status "Snap Cursor found: /snap/bin/cursor"
    CURSOR_FOUND=true
fi

if command -v cursor > /dev/null 2>&1; then
    print_status "System Cursor found: $(which cursor)"
    CURSOR_FOUND=true
fi

if [ "$CURSOR_FOUND" = false ]; then
    print_error "No Cursor installation found"
fi

# Check AMD-optimized launcher
if test_file "/usr/local/bin/cursor-amd"; then
    print_status "AMD-optimized launcher found"
else
    print_warning "AMD-optimized launcher not found"
fi

echo

# 10. Performance recommendations
print_info "10. Performance Recommendations"
echo "==================================="

RECOMMENDATIONS=()

# Check if AMD environment is configured
if ! test_file "/etc/environment.d/99-cursor-amd.conf"; then
    RECOMMENDATIONS+=("Install AMD environment configuration")
fi

# Check if AMD launcher is available
if ! test_file "/usr/local/bin/cursor-amd"; then
    RECOMMENDATIONS+=("Install AMD-optimized launcher")
fi

# Check Mesa drivers
if ! dpkg -l | grep -q "mesa-vulkan-drivers"; then
    RECOMMENDATIONS+=("Install mesa-vulkan-drivers")
fi

if ! dpkg -l | grep -q "mesa-va-drivers"; then
    RECOMMENDATIONS+=("Install mesa-va-drivers")
fi

# Check for recent Mesa version
if test_command "glxinfo"; then
    MESA_VERSION_NUM=$(glxinfo | grep "OpenGL version" | head -1 | cut -d' ' -f4 | cut -d'.' -f1,2)
    if [ "$(echo "$MESA_VERSION_NUM >= 20.0" | bc -l 2>/dev/null)" -eq 1 ]; then
        print_status "Mesa version is recent enough"
    else
        RECOMMENDATIONS+=("Update Mesa to version 20.0 or later")
    fi
fi

if [ ${#RECOMMENDATIONS[@]} -eq 0 ]; then
    print_status "No recommendations - AMD graphics are well configured"
else
    print_warning "Recommendations for better AMD performance:"
    for rec in "${RECOMMENDATIONS[@]}"; do
        echo "  • $rec"
    done
fi

echo

# 11. Summary
print_info "11. Test Summary"
echo "==================="

echo "AMD Graphics Test Results:"
echo "  • GPU Detection: $(if lspci | grep -i "vga.*amd\|vga.*radeon" > /dev/null; then echo "✅"; else echo "❌"; fi)"
echo "  • AMDGPU Driver: $(if lsmod | grep -q amdgpu; then echo "✅"; else echo "❌"; fi)"
echo "  • Direct Rendering: $(if test_command "glxinfo" && glxinfo | grep -i "direct rendering: yes" > /dev/null; then echo "✅"; else echo "❌"; fi)"
echo "  • VA-API Support: $(if test_command "vainfo" && vainfo > /dev/null 2>&1; then echo "✅"; else echo "❌"; fi)"
echo "  • Vulkan Support: $(if test_command "vulkaninfo" && vulkaninfo | grep -i "radeon\|amd" > /dev/null; then echo "✅"; else echo "❌"; fi)"
echo "  • AMD Environment: $(if test_file "/etc/environment.d/99-cursor-amd.conf"; then echo "✅"; else echo "❌"; fi)"
echo "  • AMD Launcher: $(if test_file "/usr/local/bin/cursor-amd"; then echo "✅"; else echo "❌"; fi)"

echo
echo "🎯 AMD Graphics Test Complete!"
echo
echo "For optimal Cursor performance with AMD graphics:"
echo "  • Run: ./scripts/fix-cursor-ubuntu-amd.sh"
echo "  • Use: cursor-amd"
echo 