# Changelog

All notable changes to the Cursor AMD Fix project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Cursor AMD Fix for Ubuntu
- Complete AMD optimization script (`fix-cursor-ubuntu-amd.sh`)
- AMD-optimized launcher script (`cursor-amd-launcher.sh`)
- Comprehensive graphics testing script (`test-amd-graphics.sh`)
- Uninstall script (`uninstall.sh`)
- Easy installation script (`install.sh`)
- Desktop integration with AMD-optimized desktop entry
- AMD-specific environment variable configuration
- System configuration templates
- Comprehensive documentation (README.md, QUICK_START.md)
- MIT License

### Features
- **AMD Graphics Optimization**: Full support for AMD Radeon graphics cards
- **Hardware Acceleration**: Mesa/RADV drivers with Vulkan API support
- **Video Acceleration**: VA-API and VDPAU support for media playback
- **Performance Optimizations**: Zero-copy buffers, native GPU memory buffers
- **System Integration**: Desktop shortcuts, environment variables, system configs
- **Troubleshooting Tools**: Comprehensive testing and diagnostic scripts
- **Easy Installation**: One-command installation with user-friendly interface

### Technical Details
- Fixes ptrace restrictions for debugging
- Installs AMD-optimized Mesa drivers
- Configures AMD-specific environment variables
- Creates AMD-optimized Electron launcher with hardware acceleration flags
- Sets up desktop integration
- Provides comprehensive testing and diagnostics
- Includes uninstall functionality for easy removal

### Supported Systems
- Ubuntu 20.04+
- Debian 11+
- AMD Radeon GPUs (GCN 1.0+ recommended)
- Mesa 20.0+ with RADV support

### Installation Methods
- Snap Cursor installations
- AppImage Cursor installations
- System package Cursor installations

---

## [Unreleased]

### Planned Features
- Support for additional Linux distributions
- NVIDIA graphics card support
- Intel graphics card support
- Advanced performance profiling
- Automated driver updates
- Integration with Cursor settings
- Performance monitoring dashboard

### Planned Improvements
- Enhanced error handling and recovery
- More detailed diagnostics
- Performance benchmarking tools
- Configuration management system
- Automated testing suite
- Community-contributed optimizations 