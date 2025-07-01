# Quick Start Guide - Cursor AMD Fix

## 🚀 Get Started in 3 Steps

### 1. Clone and Install
```bash
git clone https://github.com/yourusername/cursor-amd-fix.git
cd cursor-amd-fix
./install.sh
```

### 2. Restart Your System
```bash
sudo reboot
```

### 3. Use AMD-Optimized Cursor
```bash
cursor-amd
```

## 📋 Prerequisites

- Ubuntu/Debian system with AMD Radeon graphics
- Cursor IDE installed
- sudo privileges

## 🔧 Essential Commands

### Installation
```bash
./install.sh                    # Easy installation
./scripts/fix-cursor-ubuntu-amd.sh  # Manual installation
```

### Testing
```bash
./scripts/test-amd-graphics.sh  # Test AMD graphics
cursor-amd                      # Test AMD-optimized launcher
```

### Troubleshooting
```bash
./scripts/uninstall.sh          # Remove optimizations
cursor                          # Use original Cursor
```

## 🎯 What You Get

- **Hardware acceleration** via Mesa/RADV drivers
- **Vulkan API support** for modern graphics
- **VA-API video acceleration** for media playback
- **Zero-copy buffer optimization** for better performance
- **AMD-specific environment variables** for optimal performance

## 🔍 Quick Diagnostics

### Check AMD GPU
```bash
lspci | grep -i "vga.*amd\|vga.*radeon"
```

### Test Graphics
```bash
glxinfo | grep "direct rendering"
vainfo | grep "VAProfile"
```

### Check Installation
```bash
which cursor-amd
ls -la /usr/local/bin/cursor-amd
```

## 🆘 Common Issues

### Cursor won't start
```bash
./scripts/test-amd-graphics.sh
```

### Poor performance
```bash
glxinfo | grep "OpenGL renderer"
```

### Reset to default
```bash
./scripts/uninstall.sh
cursor
```

## 📞 Need Help?

1. Check the full [README.md](README.md)
2. Run the test script: `./scripts/test-amd-graphics.sh`
3. Check your AMD driver: `lspci -k | grep -A 3 VGA`
4. Open an issue with system information

## 🎉 Success Indicators

- `cursor-amd` launches without errors
- Graphics are smooth and responsive
- No more debugging/ptrace issues
- Hardware acceleration is working

---

**For detailed information, see the full [README.md](README.md)** 