## Header
- **Source URL**: https://raw.githubusercontent.com/symfony/ux/refs/heads/2.x/src/Icons/doc/index.rst
- **Processed Date**: 2025-01-25
- **Domain**: symfony/ux
- **Version**: v2x
- **Weight Reduction**: ~41%
- **Key Sections**: Icon Rendering, Configuration, Icon Sources, Performance, Iconify Integration, Accessibility, CLI Commands

## Body

### Core Capabilities
- **SVG icon rendering** across Symfony applications
- **Access to 200,000+ vector icons** from multiple icon sets
- **Local and remote** icon integration
- **Twig and HTML** component support

### Key Technical Features

#### 1. Icon Rendering Mechanisms
- **Function**: `ux_icon('icon_name')`
- **HTML Component**: `<twig:ux:icon name="icon_name" />`
- **Sources**: Local and remote icon support
- **Accessibility**: Automatic attribute management

#### 2. Configuration Options
```yaml
ux_icons:
    icon_dir: '%kernel.project_dir%/assets/icons'
    default_icon_attributes:
        fill: currentColor
    aliases:
        dots: 'clarity:ellipsis-horizontal-line'
    ignore_not_found: false
```

#### 3. Icon Source Management
- **Local directory**: `assets/icons/`
- **On-demand retrieval**: via Iconify API
- **Import commands**: for locking icons
- **Caching mechanisms**: for performance

#### 4. Performance Optimizations
- **Icon file caching**
- **Pre-warming cache** via CLI
- **Reduced TwigComponent overhead**
- **Dynamic icon name resolution limitations**

#### 5. Iconify Integration
- **Optional on-demand** icon retrieval
- **Configurable API endpoint**
- **Extensive icon set support**

#### 6. Accessibility Handling
- **Automatic `aria-hidden`** management
- **Support for**: informative, functional, and decorative icons
- **Customizable screen reader** attributes

### Installation
```bash
composer require symfony/ux-icons
composer require symfony/http-client  # For on-demand icons
```

### Key CLI Commands
- **`ux:icons:search`**: Find icon sets
- **`ux:icons:import`**: Download specific icons
- **`ux:icons:lock`**: Import all used on-demand icons
- **`ux:icons:warm-cache`**: Preload icon cache

### Technical Constraints
- **Icon names**: must match `[a-z0-9-]+(-[a-z0-9])+` pattern
- **Dynamic names**: won't cache properly
- **Advanced scenarios**: require explicit configuration