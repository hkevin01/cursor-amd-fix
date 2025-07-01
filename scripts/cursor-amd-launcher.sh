#!/bin/bash

# AMD Radeon optimized Cursor launcher
# This script launches Cursor with AMD-specific optimizations for better performance

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

# Export AMD-specific environment variables
export LIBVA_DRIVER_NAME=radeonsi
export VDPAU_DRIVER=radeonsi
export RADV_PERFTEST=aco
export AMD_VULKAN_ICD=RADV
export MESA_LOADER_DRIVER_OVERRIDE=radeonsi

# Export Electron environment variables for better AMD compatibility
export ELECTRON_OZONE_PLATFORM_HINT=auto
export ELECTRON_DISABLE_SECURITY_WARNINGS=true
export ELECTRON_ENABLE_LOGGING=false

# Force GPU acceleration
export ELECTRON_FORCE_IS_PACKAGED=true

# Load AMD environment configuration if it exists
if [ -f "/etc/environment.d/99-cursor-amd.conf" ]; then
    source /etc/environment.d/99-cursor-amd.conf
    print_info "Loaded AMD environment configuration"
fi

# Find Cursor installation
CURSOR_PATH=""
if [ -f "/opt/Cursor-patched/AppRun" ]; then
    CURSOR_PATH="/opt/Cursor-patched/AppRun"
    print_info "Found Cursor-patched installation"
elif [ -f "/snap/bin/cursor" ]; then
    CURSOR_PATH="/snap/bin/cursor"
    print_info "Found snap Cursor installation"
elif command -v cursor > /dev/null 2>&1; then
    CURSOR_PATH="cursor"
    print_info "Found system Cursor installation"
else
    print_error "Cursor not found. Please install Cursor first."
    echo "Installation locations checked:"
    echo "  - /opt/Cursor-patched/AppRun"
    echo "  - /snap/bin/cursor"
    echo "  - system PATH"
    exit 1
fi

# Check if AMD GPU is detected
if lspci | grep -i "vga.*amd\|vga.*radeon" > /dev/null; then
    GPU_INFO=$(lspci | grep -i "vga.*amd\|vga.*radeon")
    print_status "AMD GPU detected: $GPU_INFO"
else
    print_warning "AMD GPU not detected. Optimizations may not be effective."
fi

# Launch Cursor with AMD-optimized flags
print_info "Launching Cursor with AMD optimizations..."
exec "$CURSOR_PATH" \
    --enable-features=UseOzonePlatform,VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan \
    --ozone-platform=wayland \
    --enable-gpu-rasterization \
    --enable-zero-copy \
    --ignore-gpu-blacklist \
    --disable-gpu-sandbox \
    --enable-native-gpu-memory-buffers \
    --enable-gpu-memory-buffer-compositor-resources \
    --enable-gpu-memory-buffer-video-frames \
    --disable-dev-shm-usage \
    --disable-software-rasterizer \
    --disable-background-timer-throttling \
    --disable-renderer-backgrounding \
    --disable-backgrounding-occluded-windows \
    --enable-accelerated-2d-canvas \
    --enable-accelerated-jpeg-decoding \
    --enable-accelerated-mjpeg-decode \
    --enable-accelerated-video-decode \
    --use-gl=desktop \
    "$@" 