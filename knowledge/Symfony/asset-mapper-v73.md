## Header
- **Source**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/frontend/asset_mapper.rst
- **Processed Date**: 2025-09-01
- **Domain**: symfony.com
- **Version**: v73
- **Weight Reduction**: ~65%
- **Key Sections**: v7.3 Configuration, Console Commands, Twig Integration, Security Features

## Body

### Symfony 7.3 AssetMapper Installation

```bash
composer require symfony/asset-mapper
```

### Symfony 7.3 Configuration Options

```yaml
# config/packages/framework.yaml
framework:
    asset_mapper:
        paths:
            - assets/
        excluded_patterns:
            - '*/*.scss'
        public_prefix: /assets
        server: 'importmap-preload'  # v7.3: Preload support
        strict_mode: true            # v7.3: Import validation
        compression:
            brotli: true             # v7.3: Brotli compression
            zstandard: true          # v7.3: Zstandard compression
            gzip: true
        csp:
            script_src_self: true    # v7.3: CSP integration
            script_src_data: false
```

### Symfony 7.3 Console Commands

```bash
# Package management (v7.3 specific)
php bin/console importmap:require bootstrap
php bin/console importmap:require @hotwired/stimulus
php bin/console importmap:remove package
php bin/console importmap:list
php bin/console importmap:info bootstrap
php bin/console importmap:audit       # v7.3: Security auditing

# Asset compilation (v7.3)
php bin/console asset-map:compile

# Debugging (v7.3)
php bin/console debug:asset-map
php bin/console debug:asset-map app.js
```

### Symfony 7.3 Twig Functions

```twig
{# Import map rendering with v7.3 options #}
{{ importmap('app') }}
{{ importmap('app', {preload: true}) }}
{{ importmap('app', {preload: false}) }}

{# Asset preloading (v7.3 feature) #}
{{ preload(asset('app.js'), { as: 'script' }) }}
{{ preload(asset('styles/critical.css'), { as: 'style' }) }}
```

### Symfony 7.3 Asset Processor Interface

```php
// v7.3 AssetProcessorInterface implementation
class CustomAssetProcessor implements AssetProcessorInterface
{
    public function process(MappedAsset $asset): void
    {
        // v7.3 asset processing logic
    }
}
```

### Symfony 7.3 Import Map Structure

```html
<script type="importmap">{
    "imports": {
        "bootstrap": "/assets/bootstrap-abc123.js",
        "@hotwired/stimulus": "/assets/stimulus-def456.js"
    }
}</script>
```

### Symfony 7.3 Security Features

**v7.3 Security Auditing**:
```bash
php bin/console importmap:audit  # Check vulnerabilities
```

**v7.3 CSP Configuration**:
```yaml
framework:
    asset_mapper:
        csp:
            script_src_self: true
            script_src_data: false
```