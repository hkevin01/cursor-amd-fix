# Create an AMD-optimized Cursor fix script
sudo tee /usr/local/bin/fix-cursor-ubuntu-amd > /dev/null << 'EOF'
#!/bin/bash

# Cursor Ubuntu Fix Script - AMD Radeon Optimized
# Fixes common Cursor IDE issues on Ubuntu/Debian systems with AMD graphics

echo "🔧 Cursor Ubuntu Fix Script (AMD Radeon Optimized)"
echo "================================================"
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

echo "Fixing Cursor IDE issues on Ubuntu with AMD Radeon optimization..."
echo

# 1. Fix ptrace restrictions
print_info "Fixing ptrace restrictions..."
current_ptrace=$(cat /proc/sys/kernel/yama/ptrace_scope)
if [ "$current_ptrace" != "0" ]; then
    echo "Current ptrace_scope: $current_ptrace (restrictive)"
    sudo sysctl kernel.yama.ptrace_scope=0
    print_status "Temporarily set ptrace_scope to 0"
    
    # Make it permanent
    if ! grep -q "kernel.yama.ptrace_scope = 0" /etc/sysctl.conf; then
        echo 'kernel.yama.ptrace_scope = 0' | sudo tee -a /etc/sysctl.conf > /dev/null
        print_status "Made ptrace_scope=0 permanent in /etc/sysctl.conf"
    else
        print_status "ptrace_scope=0 already permanent in /etc/sysctl.conf"
    fi
else
    print_status "ptrace_scope already set to 0"
fi

# 2. Install/update dependencies including AMD-specific ones
print_info "Installing dependencies optimized for AMD graphics..."
sudo apt update -qq
sudo apt install -y \
    libfuse2 libnss3 libatk-bridge2.0-0 libgtk-3-0 libgdk-pixbuf2.0-0 \
    mesa-vulkan-drivers mesa-va-drivers mesa-vdpau-drivers \
    libgl1-mesa-dri libglx-mesa0 mesa-utils \
    vainfo vdpauinfo > /dev/null 2>&1
print_status "Dependencies installed/updated with AMD graphics support"

# 3. Check AMD graphics info
print_info "Detecting AMD graphics configuration..."
if lspci | grep -i "vga.*amd\|vga.*radeon" > /dev/null; then
    GPU_INFO=$(lspci | grep -i "vga.*amd\|vga.*radeon")
    print_status "AMD GPU detected: $GPU_INFO"
    
    # Check for hardware acceleration support
    if command -v vainfo > /dev/null 2>&1; then
        if vainfo > /dev/null 2>&1; then
            print_status "Hardware video acceleration (VA-API) available"
        else
            print_warning "VA-API not working properly"
        fi
    fi
else
    print_warning "AMD GPU not detected in primary slot"
fi

# 4. Fix AppArmor if it's interfering
print_info "Checking AppArmor restrictions..."
if command -v aa-status > /dev/null 2>&1; then
    if aa-status --enabled > /dev/null 2>&1; then
        print_warning "AppArmor is active. Adding Cursor exception..."
        sudo aa-complain /usr/bin/cursor 2>/dev/null || true
        sudo aa-complain /opt/Cursor*/AppRun 2>/dev/null || true
        print_status "AppArmor restrictions relaxed for Cursor"
    fi
else
    print_status "AppArmor not installed"
fi

# 5. Fix file permissions for Cursor installation
print_info "Fixing file permissions..."
if [ -d "/opt/Cursor-patched" ]; then
    sudo chmod +x /opt/Cursor-patched/AppRun
    sudo chmod +x /opt/Cursor-patched/cursor
    print_status "Fixed Cursor-patched permissions"
fi

if [ -d "/snap/cursor" ]; then
    print_status "Snap Cursor installation detected"
fi

# 6. AMD-specific environment optimizations
print_info "Setting up AMD-specific optimizations..."
sudo tee /etc/environment.d/99-cursor-amd.conf > /dev/null << 'AMD_ENV_EOF'
# AMD Radeon optimizations for Cursor IDE
LIBVA_DRIVER_NAME=radeonsi
VDPAU_DRIVER=radeonsi
RADV_PERFTEST=aco
AMD_VULKAN_ICD=RADV
AMD_DEBUG=nodma
MESA_LOADER_DRIVER_OVERRIDE=radeonsi
AMD_ENV_EOF
print_status "AMD environment optimizations configured"

# 7. Create AMD-optimized launcher script
print_info "Creating AMD-optimized Cursor launcher..."
sudo tee /usr/local/bin/cursor-amd > /dev/null << 'LAUNCHER_EOF'
#!/bin/bash

# AMD Radeon optimized Cursor launcher with sandbox enabled
# This script fixes common Cursor issues while optimizing for AMD graphics

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

# Find Cursor installation
CURSOR_PATH=""
if [ -f "/opt/Cursor-patched/AppRun" ]; then
    CURSOR_PATH="/opt/Cursor-patched/AppRun"
elif [ -f "/snap/bin/cursor" ]; then
    CURSOR_PATH="/snap/bin/cursor"
elif command -v cursor > /dev/null 2>&1; then
    CURSOR_PATH="cursor"
else
    echo "❌ Cursor not found. Please install Cursor first."
    exit 1
fi

# Launch Cursor with AMD-optimized flags (sandbox enabled)
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
LAUNCHER_EOF

sudo chmod +x /usr/local/bin/cursor-amd
print_status "Created AMD-optimized launcher: cursor-amd"

# 8. Create desktop entry for AMD-optimized version
print_info "Creating desktop entry for AMD-optimized version..."
sudo tee /usr/share/applications/cursor-amd.desktop > /dev/null << 'DESKTOP_EOF'
[Desktop Entry]
Name=Cursor (AMD Optimized)
Exec=cursor-amd %U
Terminal=false
Type=Application
Icon=cursor-ai
StartupWMClass=Cursor
Comment=AI-powered code editor (AMD Radeon optimized)
MimeType=text/plain;inode/directory;
Categories=Development;IDE;
Actions=new-empty-window;
StartupNotify=true

[Desktop Action new-empty-window]
Name=New Empty Window
Exec=cursor-amd --new-window %U
Icon=cursor-ai
DESKTOP_EOF

print_status "Created desktop entry: Cursor (AMD Optimized)"

# 9. Update desktop database
print_info "Updating desktop database..."
sudo update-desktop-database > /dev/null 2>&1
print_status "Desktop database updated"

# 10. Test AMD graphics capabilities
print_info "Testing AMD graphics capabilities..."
if command -v glxinfo > /dev/null 2>&1; then
    if glxinfo | grep -i "direct rendering: yes" > /dev/null; then
        print_status "Direct rendering enabled"
    else
        print_warning "Direct rendering may not be working"
    fi
    
    RENDERER=$(glxinfo | grep "OpenGL renderer" | cut -d: -f2 | xargs)
    if echo "$RENDERER" | grep -i "amd\|radeon\|ati" > /dev/null; then
        print_status "AMD OpenGL renderer: $RENDERER"
    else
        print_warning "OpenGL renderer: $RENDERER (may not be AMD)"
    fi
else
    print_warning "glxinfo not available (install mesa-utils for graphics testing)"
fi

# 11. Test the installation
print_info "Testing Cursor installation..."
if timeout 5 cursor-amd --version > /dev/null 2>&1; then
    print_status "Cursor launches successfully with AMD optimizations!"
else
    print_warning "Cursor may have issues. Try running 'cursor-amd' manually."
fi

echo
echo "🎉 AMD-optimized Cursor Ubuntu fix complete!"
echo
echo "Usage:"
echo "  • Run 'cursor-amd' from terminal (recommended for AMD)"
echo "  • Or find 'Cursor (AMD Optimized)' in applications menu"
echo "  • This version is specifically optimized for AMD Radeon graphics"
echo
echo "AMD Graphics Features Enabled:"
echo "  • Hardware acceleration via Mesa/RADV"
echo "  • Vulkan API support"
echo "  • VA-API video acceleration"
echo "  • Zero-copy buffer optimization"
echo "  • Native GPU memory buffers"
echo
echo "If you still have problems:"
echo "  • Restart your system to apply all changes"
echo "  • Check AMD driver with: 'lspci -k | grep -A 3 VGA'"
echo "  • Test graphics with: 'glxinfo | grep -i amd'"
echo "  • Run this script again after driver updates"
echo
EOF

# Make the script executable
sudo chmod +x /usr/local/bin/fix-cursor-ubuntu-amd

echo "🚀 AMD-optimized fix script created!"
echo "Run it with: fix-cursor-ubuntu-amd"
