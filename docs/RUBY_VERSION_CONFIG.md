# Ruby Version Configuration Guide

This Jekyll site uses a configurable Ruby version matrix that allows you to easily customize which Ruby versions are used for building and testing.

## Default Configuration

The current default configuration uses:
- **Primary Ruby Version**: 3.3
- **Fallback Ruby Version**: 3.2 (automatically calculated as 3.3 - 1)

## How to Customize Ruby Versions

### Method 1: Environment Variables (Recommended)

Set this environment variable in your Travis CI repository settings:

```bash
PRIMARY_RUBY_VERSION=3.4
```

The fallback version will automatically be calculated as `3.3` (3.4 - 1) during the build process.

### Method 2: Direct .travis.yml Modification

Edit the environment variables section in `.travis.yml`:

```yaml
env:
  global:
    # Configurable Ruby versions (customize these to change the Ruby version matrix)
    # Examples: 3.4, 3.3, 3.2, 3.1, 3.0, 2.7
    # Note: FALLBACK_RUBY_VERSION is automatically calculated as PRIMARY_RUBY_VERSION - 1
    - PRIMARY_RUBY_VERSION=3.4
    - FALLBACK_RUBY_VERSION=3.3  # This will be overridden by dynamic calculation
```

## Supported Ruby Versions

The configuration supports any Ruby version that Travis CI supports:

- **Ruby 3.x**: 3.4, 3.3, 3.2, 3.1, 3.0
- **Ruby 2.x**: 2.7 (legacy support)

## Configuration Examples

### Example 1: Latest Ruby Versions
```yaml
- PRIMARY_RUBY_VERSION=3.4
# Fallback automatically becomes 3.3
```

### Example 2: Conservative Versions
```yaml
- PRIMARY_RUBY_VERSION=3.2
# Fallback automatically becomes 3.1
```

### Example 3: Legacy Support
```yaml
- PRIMARY_RUBY_VERSION=3.0
# Fallback automatically becomes 2.9 (which doesn't exist, so 2.7 would be used)
```

**Note**: The fallback version is automatically calculated as `PRIMARY_RUBY_VERSION - 1` (minor version decrement).

## How It Works

### Dynamic Fallback Calculation
The fallback Ruby version is automatically calculated during the build process:
```bash
export FALLBACK_RUBY_VERSION=$(echo ${PRIMARY_RUBY_VERSION:-3.3} | awk -F. '{print $1"."($2-1)}')
```

### Build Matrix
The configuration automatically creates a build matrix with:
1. **Primary Job**: Uses `PRIMARY_RUBY_VERSION` (required to pass)
2. **Fallback Job**: Uses calculated `FALLBACK_RUBY_VERSION` (allowed to fail)

### Caching Strategy
- **Version-specific caches**: `_site-ruby-{VERSION}.tar.gz`
- **Generic cache**: `_site.tar.gz` (backward compatibility)
- **Smart restoration**: Prioritizes higher Ruby versions

### Deployment Priority
The deployment process uses the best available build in this order:
1. Primary Ruby version build (`PRIMARY_RUBY_VERSION`)
2. Fallback Ruby version build (calculated `FALLBACK_RUBY_VERSION`)
3. Generic build
4. Fresh build (last resort)

## Cache Key Strategy

The cache key includes both Ruby versions to ensure proper invalidation:

```
travis-cache-ruby-{PRIMARY_VERSION}-{FALLBACK_VERSION}-{Gemfile.lock_hash}-{_config.yml_hash}
```

Where `FALLBACK_VERSION` is dynamically calculated as `PRIMARY_VERSION - 1`.

## Benefits

### Flexibility
- Easy to upgrade Ruby versions
- Support for different Ruby version combinations
- No need to modify multiple files

### Performance
- Version-specific caching
- Smart cache restoration
- Minimal rebuilds

### Reliability
- Fallback support for edge cases
- Clear logging of which version was used
- Consistent behavior across environments

## Migration Guide

### Upgrading Ruby Versions

1. **Update environment variable**:
   ```bash
   PRIMARY_RUBY_VERSION=3.4
   # Fallback automatically becomes 3.3
   ```

2. **Clear cache** (optional, but recommended):
   - Go to Travis CI repository settings
   - Clear the build cache
   - Or wait for natural cache expiration (7 days)

3. **Test the build**:
   - Push a commit to trigger a new build
   - Verify both primary and fallback jobs work

### Downgrading Ruby Versions

1. **Update environment variable**:
   ```bash
   PRIMARY_RUBY_VERSION=3.2
   # Fallback automatically becomes 3.1
   ```

2. **Clear cache** (recommended):
   - Clear build cache to avoid version conflicts

3. **Test the build**:
   - Verify compatibility with your Jekyll setup

## Troubleshooting

### Common Issues

1. **Cache conflicts**: Clear build cache when changing Ruby versions
2. **Gem compatibility**: Some gems may not support newer Ruby versions
3. **Jekyll compatibility**: Check Jekyll version compatibility with Ruby versions

### Debug Information

The build logs include detailed information about:
- Which Ruby version is being used
- Cache hit/miss status
- Build performance metrics
- Deployment source (which cache was used)

## Best Practices

1. **Keep fallback close to primary**: Use adjacent Ruby versions (e.g., 3.4/3.3)
2. **Test locally first**: Verify your Jekyll site works with new Ruby versions
3. **Monitor build times**: Newer Ruby versions may have different performance characteristics
4. **Update dependencies**: Ensure your gems support the Ruby versions you're using

## Support

For issues related to Ruby version configuration:
1. Check the build logs for detailed error information
2. Verify your Jekyll and gem versions support the Ruby versions
3. Test locally with the same Ruby versions
4. Clear build cache if experiencing version conflicts
