# Colima Performance Optimizations

This document explains the performance optimizations applied to Colima for optimal Docker performance on macOS.

## Key Optimizations

### 1. VirtioFS Mount Type
- **Setting**: `mountType: virtiofs`
- **Benefit**: Significantly faster file I/O compared to 9p or sshfs
- **Requirement**: macOS 13+ with Apple Silicon or Intel with virtualization support

### 2. Virtualization Framework (vz)
- **Setting**: `vmType: vz`
- **Benefit**: Native macOS virtualization, better performance than QEMU
- **Requirement**: macOS 13+

### 3. Inotify Support
- **Setting**: `mountInotify: true`
- **Benefit**: Better file watching for hot-reload in development
- **Note**: Experimental but stable for most use cases

### 4. Docker Daemon Optimizations
- **BuildKit**: Enabled by default for faster builds
- **Concurrent Operations**: Increased concurrent downloads/uploads to 10
- **Ulimits**: Increased file descriptor limits for better performance
- **Storage Driver**: Using overlay2 for optimal performance

### 5. Network Optimizations
- **Host Addresses**: Enabled for better port forwarding
- **Address Assignment**: VM gets a reachable IP address

### 6. Resource Allocation
- **CPU**: 4 cores (adjust based on your system)
- **Memory**: 8GB (adjust based on your system)
- **Disk**: 100GB

### 7. SSH Agent Forwarding
- **Setting**: `forwardAgent: true`
- **Benefit**: Seamless git operations with SSH keys

### 8. Rosetta Support
- **Setting**: `rosetta: true`
- **Benefit**: Better x86_64 emulation on Apple Silicon
- **Requirement**: Rosetta 2, which `install.sh` installs on Apple Silicon

## Applying Configuration

The optimized configuration is automatically applied when running:
```bash
./install.sh
```

To manually apply:
```bash
# Stop Colima if running
colima stop

# Copy configuration
cp configs/colima/colima.yaml ~/.colima/default/colima.yaml

# Start with new configuration
colima start
```

## Verifying Optimizations

Check that optimizations are applied:
```bash
# Check status
colima status

# Verify VirtioFS
colima status | grep "mountType: virtiofs"

# Check Docker info
docker info
```

## Troubleshooting

### If VirtioFS is not available
- Ensure you're on macOS 13+
- For Intel Macs, virtualization must be enabled
- Fall back to 9p if needed: `mountType: 9p`

### Performance issues
- Adjust CPU/memory allocation based on your system
- Check Docker logs: `colima ssh -- sudo journalctl -u docker`
- Consider reducing concurrent operations if system is constrained

### File watching not working
- Disable mountInotify if causing issues
- Use polling-based watchers in your development tools

### `docker compose` or `docker buildx` not found
- Homebrew installs both as CLI plugins outside Docker's default search path
- `install.sh` adds `$(brew --prefix)/lib/docker/cli-plugins` to `cliPluginsExtraDirs` in `~/.docker/config.json`; add it by hand if that file was replaced since

## Additional Tips

1. **Registry Mirrors**: Add registry mirrors for faster image pulls
2. **Custom Mounts**: Mount only necessary directories to reduce overhead
3. **Provision Scripts**: Add commonly needed tools to the VM
4. **Environment Variables**: Set Docker-specific env vars for optimization

## References
- [Colima Documentation](https://github.com/abiosoft/colima)
- [Docker Performance Best Practices](https://docs.docker.com/config/containers/resource_constraints/)
- [macOS Virtualization Framework](https://developer.apple.com/documentation/virtualization)