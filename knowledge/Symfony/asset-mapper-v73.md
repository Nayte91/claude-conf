## Header
- **Source URL**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/frontend/asset_mapper.rst
- **Processed Date**: 2025-01-25
- **Domain**: symfony/symfony-docs
- **Version**: v73
- **Weight Reduction**: ~43%
- **Key Sections**: Asset Mapping, Importmaps, Configuration, Compilation, Performance, CSS/JS Processing, Security

## Body

### Core Capabilities
- **Native browser module support** without bundling
- **Direct file serving** with versioning
- **Automatic asset mapping** and importmap generation
- **Performance-optimized** asset management

### Key Technical Mechanisms

#### 1. Asset Mapping
- **Scans directories**: (default: `assets/`)
- **Generates versioned URLs** with content hash
- **Supports references**: relative and absolute asset references
- **Automatic path resolution** across JavaScript/CSS

#### 2. Importmap Processing
- **Native browser `import`** statement support
- **Automatic module discovery** and mapping
- **Polyfill support** for legacy browsers
- **Dynamic import handling** with shim support

#### 3. Configuration Patterns
```yaml
framework:
  asset_mapper:
    paths:
      - assets/
      - vendor/package/assets
    excluded_patterns:
      - '*/*.scss'
    importmap_polyfill: 'es-module-shims'
```

#### 4. Compilation Strategies
**Development**: Dynamic asset serving
**Production**:
- **`asset-map:compile`** command
- **Static asset generation**
- **Versioned file output**
- **Manifest generation**

#### 5. Performance Optimization
- **HTTP/2** parallel asset loading
- **Preloading** critical assets
- **Compression support**: Brotli, Zstandard, gzip
- **Content hash-based** caching

#### 6. CSS/JS Processing
- **Direct CSS import** from JavaScript
- **Third-party package** integration
- **Automatic dependency tracking**
- **Lazy loading support**

#### 7. Security Considerations
- **Content Security Policy (CSP)** compatibility
- **Dependency vulnerability** scanning
- **Nonce support** for script execution

### Recommended Implementation Workflow
1. **Define asset paths**
2. **Configure importmap**
3. **Implement asset references**
4. **Optimize for production**
5. **Implement security measures**

### Critical Configuration Directives
- **Specify asset paths**
- **Define exclusion patterns**
- **Configure importmap polyfill**
- **Set compression strategies**

### Emerging Best Practices
- **Minimize build complexity**
- **Leverage native browser capabilities**
- **Implement granular asset management**
- **Prioritize performance optimization**