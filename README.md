# Cursor AMD Fix for Ubuntu

A comprehensive solution to fix Cursor IDE issues specifically optimized for AMD Radeon graphics on Ubuntu/Debian systems.

## 🎯 What This Project Does

This project addresses common Cursor IDE problems on Ubuntu systems with AMD graphics cards by:

- **Fixing ptrace restrictions** that prevent debugging
- **Installing AMD-optimized dependencies** (Mesa, RADV, VA-API drivers)
- **Configuring AMD-specific environment variables** for better performance
- **Creating an AMD-optimized launcher** with hardware acceleration
- **Setting up desktop integration** for easy access
- **Testing graphics capabilities** to ensure proper AMD driver support

## 🚀 Quick Start

### Prerequisites
- Ubuntu/Debian system with AMD Radeon graphics
- Cursor IDE installed (from snap, AppImage, or official package)
- sudo privileges

### Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/yourusername/cursor-amd-fix.git
   cd cursor-amd-fix
   ```

2. **Run the main fix script:**
   ```bash
   chmod +x scripts/fix-cursor-ubuntu-amd.sh
   ./scripts/fix-cursor-ubuntu-amd.sh
   ```

3. **Use the AMD-optimized version:**
   ```bash
   cursor-amd
   ```

## 📁 Project Structure

```
cursor-amd-fix/
├── README.md                 # This file
├── docs/
│   └── directions.md         # Detailed technical directions
├── scripts/
│   ├── fix-cursor-ubuntu-amd.sh    # Main AMD fix script
│   ├── cursor-amd-launcher.sh      # AMD-optimized launcher
│   ├── uninstall.sh                # Uninstall script
│   └── test-amd-graphics.sh        # Graphics testing script
├── templates/
│   ├── desktop-entry.desktop       # Desktop entry template
│   ├── environment.conf            # Environment variables template
│   └── sysctl.conf                 # System configuration template
└── configs/
    ├── amd-optimized.conf          # AMD-specific optimizations
    └── electron-flags.conf         # Electron launch flags
```

## 🔧 Scripts Overview

### Main Scripts

- **`fix-cursor-ubuntu-amd.sh`** - Complete AMD optimization and fix
- **`cursor-amd-launcher.sh`** - AMD-optimized Cursor launcher
- **`uninstall.sh`** - Remove all AMD optimizations
- **`test-amd-graphics.sh`** - Test AMD graphics capabilities

### What Each Script Does

#### `fix-cursor-ubuntu-amd.sh`
- Fixes ptrace restrictions
- Installs AMD graphics dependencies
- Configures AMD environment variables
- Creates AMD-optimized launcher
- Sets up desktop integration
- Tests graphics capabilities

#### `cursor-amd-launcher.sh`
- Exports AMD-specific environment variables
- Launches Cursor with AMD-optimized flags
- Enables hardware acceleration
- Configures GPU memory buffers

#### `uninstall.sh`
- Removes AMD environment configurations
- Removes desktop entries
- Restores original system settings

#### `test-amd-graphics.sh`
- Tests AMD GPU detection
- Verifies hardware acceleration
- Checks OpenGL/Vulkan support
- Validates VA-API functionality

## 🎮 AMD Graphics Features Enabled

- **Hardware acceleration** via Mesa/RADV drivers
- **Vulkan API support** for modern graphics
- **VA-API video acceleration** for media playback
- **Zero-copy buffer optimization** for better performance
- **Native GPU memory buffers** for reduced latency
- **AMD-specific environment variables** for optimal performance

## 🔍 Troubleshooting

### Common Issues

#### Cursor won't start
```bash
# Check if AMD GPU is detected
lspci | grep -i "vga.*amd\|vga.*radeon"

# Test graphics capabilities
./scripts/test-amd-graphics.sh

# Check Cursor installation
which cursor
ls -la /opt/Cursor* /snap/bin/cursor
```

#### Poor performance
```bash
# Verify hardware acceleration
glxinfo | grep "direct rendering"
vainfo | grep "VAProfile"

# Check AMD drivers
lspci -k | grep -A 3 VGA
```

#### Graphics glitches
```bash
# Test with different graphics APIs
export MESA_LOADER_DRIVER_OVERRIDE=radeonsi
cursor-amd

# Or try with different platform
cursor-amd --ozone-platform=x11
```

### Debug Mode

Run Cursor with debug information:
```bash
ELECTRON_ENABLE_LOGGING=true cursor-amd
```

### Reset to Default

If you encounter issues, reset to default Cursor:
```bash
./scripts/uninstall.sh
cursor  # Use original Cursor
```

## 📋 System Requirements

- **OS:** Ubuntu 20.04+ or Debian 11+
- **Graphics:** AMD Radeon GPU (GCN 1.0+ recommended)
- **Drivers:** Mesa 20.0+ with RADV support
- **Memory:** 4GB RAM minimum, 8GB recommended
- **Storage:** 2GB free space

## 🔄 Updates

To update the AMD optimizations:
```bash
git pull
./scripts/fix-cursor-ubuntu-amd.sh
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on AMD systems
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- AMD for their excellent open-source graphics drivers
- Mesa team for RADV and VA-API support
- Cursor team for the excellent IDE
- Ubuntu community for system integration

## 📞 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Run the test script: `./scripts/test-amd-graphics.sh`
3. Check your AMD driver version: `lspci -k | grep -A 3 VGA`
4. Open an issue with system information and error logs

## 🔗 Related Links

- [Cursor IDE](https://cursor.sh/)
- [AMD Linux Drivers](https://www.amd.com/en/support/kb/release-notes/rn-amdgpu-unified-linux-20-45)
- [Mesa Graphics Library](https://www.mesa3d.org/)
- [RADV Vulkan Driver](https://github.com/ValveSoftware/radv) 