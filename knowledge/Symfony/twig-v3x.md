## Header
- **Source**: https://twig.symfony.com/doc/3.x/
- **Processed Date**: 2025-01-25
- **Domain**: twig.symfony.com
- **Version**: v3x
- **Weight Reduction**: ~44%
- **Key Sections**: Template Syntax, Tags, Filters, Functions, Security, Performance, Extensions, Implementation Patterns

## Body

### Twig 3.x Version-Specific Features

#### New Syntax Enhancements
- **Arrow functions** in filters: `{{ items|filter(v => v.active) }}`
- **Null-coalescing operator**: `{{ user.name ?? 'Anonymous' }}`
- **Spread operator**: `{{ {foo: 'bar', ...otherObj} }}`

#### Template Loading Performance
- **Optimized template cache**: Improved file system operations
- **Reduced memory footprint**: 15-20% less RAM usage vs 2.x
- **Faster compilation**: Streamlined AST generation

#### Security Improvements (3.x)

#### Auto-Escaping Strategy
```twig
{# Automatic context-aware escaping #}
{{ variable|raw }}          {# Bypasses escaping #}
{{ variable|escape('js') }} {# JavaScript context #}
{{ variable|escape('css') }}{# CSS context #}
```

#### Sandbox Mode Configuration
```php
$sandbox = new \Twig\Extension\SandboxExtension($policy);
$twig->addExtension($sandbox);
```

### Version-Specific Filters

#### New in 3.x
- **`filter`**: Array filtering with arrow functions
- **`map`**: Array transformation
- **`reduce`**: Array reduction operations
- **`column`**: Extract single column from array

#### Enhanced Date Handling
```twig
{{ date_now|date('Y-m-d H:i:s') }}
{{ date_modify('+1 day')|date('Y-m-d') }}
```

### Template Extension System

#### Custom Extension Registration
```php
class CustomExtension extends AbstractExtension
{
    public function getFilters(): array
    {
        return [
            new TwigFilter('custom_filter', [$this, 'customFilter'])
        ];
    }

    public function customFilter($value): string
    {
        return processed_value;
    }
}
```

### Twig 3.x Template Cache

#### Cache Configuration Options
- **auto_reload**: Development mode template reloading
- **cache**: Filesystem cache directory
- **optimizations**: Production-level optimizations

### Error Handling Improvements

#### Enhanced Error Messages (3.x)
- **Line-accurate error reporting**
- **Context-aware suggestions**
- **Improved stack traces** with template hierarchy

### API Compatibility Changes

#### Breaking Changes from 2.x
- **Removed deprecated features**
- **Stricter type checking**
- **Modified extension interface**