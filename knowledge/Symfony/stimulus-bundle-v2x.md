## Header
- **Source**: https://raw.githubusercontent.com/symfony/stimulus-bundle/refs/heads/2.x/doc/index.rst
- **Processed Date**: 2025-01-25
- **Domain**: symfony/stimulus-bundle
- **Version**: v2x
- **Weight Reduction**: ~38%
- **Key Sections**: Controller Management, Asset Integration, Configuration, Data Attributes, Performance, Integration Hooks

## Body

### StimulusBundle 2.x Configuration

```yaml
# config/packages/stimulus.yaml
stimulus:
    controller_paths:
        - '%kernel.project_dir%/assets/controllers'
    controllers_json: '%kernel.project_dir%/assets/controllers.json'
```

### Controller Registration System

#### Auto-Discovery Mechanism
- **File location**: `assets/controllers/*.js` or `assets/controllers/*.ts`
- **Auto-registration**: Via `assets/controllers.json` file
- **Naming convention**: `hello_controller.js` → `hello` controller

#### controllers.json Format
```json
{
    "controllers": {
        "hello": {
            "enabled": true,
            "fetch": "eager",
            "autoimport": {
                "@hotwired/stimulus/webpack-helpers": true
            }
        }
    },
    "entrypoints": []
}
```

### Lazy Loading Implementation

#### Controller-Level Lazy Loading
```javascript
/* stimulusFetch: 'lazy' */
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    connect() {
        // Loaded only when first used
    }
}
```

### Twig Integration Functions

#### stimulus_controller() Function
```twig
{# Basic usage #}
<div {{ stimulus_controller('search') }}>

{# With values #}
<div {{ stimulus_controller('search', {
    'query': searchTerm,
    'limit': 10
}) }}>

{# Multiple controllers #}
<div {{ stimulus_controller('search|modal') }}>
```

#### stimulus_action() Function
```twig
{# Basic action binding #}
<button {{ stimulus_action('search', 'submit') }}>Search</button>

{# Multiple actions #}
<input {{ stimulus_action('search', 'input->search#query') }}>

{# Event modifiers #}
<form {{ stimulus_action('form', 'submit->save', { prevent: true }) }}>
```

#### stimulus_target() Function
```twig
{# Basic target #}
<input {{ stimulus_target('search', 'input') }}>

{# Multiple targets #}
<div {{ stimulus_target('modal', 'content|backdrop') }}>
```

### AssetMapper Integration (2.x)

#### Asset Pipeline Configuration
```yaml
# config/packages/asset_mapper.yaml
framework:
    asset_mapper:
        paths:
            - assets/
        excluded_patterns:
            - '*/tests/*'
```

### Asset Bundle Generation

#### Third-Party Controller Integration
```json
{
    "controllers": {
        "@symfony/ux-dropzone": {
            "dropzone": {
                "enabled": true,
                "fetch": "eager"
            }
        }
    }
}
```

### TypeScript Support (2.x)

#### Controller Typing
```typescript
import { Controller } from '@hotwired/stimulus';

export default class extends Controller<HTMLFormElement> {
    static values = {
        url: String,
        method: { type: String, default: 'POST' }
    };

    connect(): void {
        // TypeScript controller implementation
    }
}
```

### Performance Characteristics

- **Eager loading**: Controllers loaded at page load
- **Lazy loading**: Controllers loaded on first DOM interaction
- **Bundle size**: ~2KB overhead for registration system
- **Runtime cost**: Minimal DOM scanning on page load