## Header
- **Source**: https://raw.githubusercontent.com/symfony/ux/refs/heads/2.x/src/Icons/doc/index.rst
- **Processed Date**: 2025-01-25
- **Domain**: symfony/ux
- **Version**: v2x
- **Weight Reduction**: ~41%
- **Key Sections**: Icon Rendering, Configuration, Icon Sources, Performance, Iconify Integration, Accessibility, CLI Commands

## Body

### UX Icons 2.x Configuration

```yaml
# config/packages/ux_icons.yaml
ux_icons:
    icon_dir: '%kernel.project_dir%/assets/icons'
    default_icon_attributes:
        fill: 'currentColor'
        'aria-hidden': 'true'
    aliases:
        menu: 'heroicons:bars-3'
        close: 'heroicons:x-mark'
    ignore_not_found: false
```

### Icon Rendering Methods

#### Twig Function
```twig
{{ ux_icon('heroicons:home') }}
{{ ux_icon('local-icon', {class: 'w-6 h-6'}) }}
```

#### HTML Component Syntax (2.x)
```twig
<twig:ux:icon name="heroicons:home" class="text-blue-500" />
<twig:ux:icon name="local-icon" :name="dynamicIconName" />
```

### Icon Sources

#### Local Icons
- **Directory**: `assets/icons/*.svg`
- **Naming**: Files named `icon-name.svg`
- **Usage**: `ux_icon('icon-name')`

#### Iconify Integration
- **Pattern**: `{collection}:{icon-name}`
- **On-demand**: Auto-downloaded from Iconify API
- **Caching**: Downloaded icons cached locally

### CLI Commands (2.x)

```bash
# Search available icons
php bin/console ux:icons:search heroicons home

# Import specific icons  
php bin/console ux:icons:import heroicons:home heroicons:user

# Lock all on-demand icons (production)
php bin/console ux:icons:lock

# Warm icon cache
php bin/console ux:icons:warm-cache
```

### Accessibility Features

#### Automatic Attributes
```twig
{# Decorative icon - auto aria-hidden #}
{{ ux_icon('heroicons:home') }}
{# Renders: <svg aria-hidden="true">... #}

{# Informative icon - with label #}
{{ ux_icon('heroicons:home', {'aria-label': 'Home page'}) }}
{# Renders: <svg aria-label="Home page">... #}
```

#### Role Configuration
```yaml
ux_icons:
    default_icon_attributes:
        role: 'img'
        'aria-hidden': 'false'  # Override for informative icons
```

### Performance Characteristics

- **Local icons**: Direct file read, fastest
- **Cached Iconify**: Single HTTP request, cached indefinitely
- **Dynamic names**: No pre-warming possible, runtime resolution
- **Bundle overhead**: ~10KB for icon resolution logic

### Icon Name Patterns

#### Valid Formats
- **Iconify**: `collection:icon-name` (e.g., `heroicons:home`)
- **Local**: `icon-name` (matches filename without .svg)
- **Aliases**: Custom names from configuration

#### Naming Constraints
- **Collection names**: Lowercase, hyphens allowed
- **Icon names**: Lowercase, hyphens/numbers allowed
- **Dynamic resolution**: Variables work but disable caching

### Production Optimizations

```bash
# Lock all icons before deployment
php bin/console ux:icons:lock

# Disable on-demand in production
# config/packages/prod/ux_icons.yaml
ux_icons:
    ignore_not_found: true  # Throw errors for missing icons
```