## Header
- **Source URL**: https://raw.githubusercontent.com/symfony/stimulus-bundle/refs/heads/2.x/doc/index.rst
- **Processed Date**: 2025-01-25
- **Domain**: symfony/stimulus-bundle
- **Version**: v2x
- **Weight Reduction**: ~38%
- **Key Sections**: Controller Management, Asset Integration, Configuration, Data Attributes, Performance, Integration Hooks

## Body

### Core Technical Specifications

#### 1. Controller Management
- **Location**: `assets/controllers/` directory
- **Supports**: JavaScript and TypeScript controllers
- **Lazy loading**: via `/* stimulusFetch: 'lazy' */` comment
- **Registration**: Automatic through `assets/controllers.json`

#### 2. Asset Integration Strategies
Compatible with two asset handling systems:
- **AssetMapper** (PHP-based)
- **Webpack Encore** (Node-based)

#### 3. Controller Configuration Patterns
```yaml
stimulus:
    controller_paths:
        - '%kernel.project_dir%/assets/controllers'
    controllers_json: '%kernel.project_dir%/assets/controllers.json'
```

#### 4. Stimulus Controller Structure
```javascript
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    connect() {
        // Initialization logic
    }
}
```

#### 5. Data Attribute Rendering
- **Dynamic generation**: controller, action, and target attributes
- **JSON encoding**: Automatic for complex values
- **Escape handling**: For attribute values

#### 6. Performance Considerations
- **Eager vs Lazy** controller loading
- **Dynamic discovery**: Controller auto-discovery
- **Minimal overhead**: Runtime performance optimization

#### 7. Integration Hooks
**Twig helper functions**:
- `stimulus_controller()`
- `stimulus_action()`
- `stimulus_target()`

### Key Technical Constraints
- Requires Symfony framework
- Depends on Stimulus JavaScript framework
- Requires modern JavaScript module system
- Supports TypeScript with additional configuration

### Recommended Implementation Strategy
1. **Install bundle** via Composer
2. **Configure** asset handling system
3. **Create controllers** in designated directory
4. **Utilize Twig helpers** for attribute management
5. **Leverage lazy loading** for complex interactions