## Header
- **Source**: https://raw.githubusercontent.com/symfony/ux/refs/heads/2.x/src/TwigComponent/doc/index.rst
- **Processed Date**: 2025-01-25
- **Domain**: symfony/ux
- **Version**: v2x
- **Weight Reduction**: ~42%
- **Key Sections**: Component Structure, Attributes Management, Lifecycle Hooks, Performance, Configuration, Advanced Features, Testing

## Body

### UX TwigComponent 2.x Attribute System

#### Component Declaration
```php
#[AsTwigComponent]
class AlertComponent {
    public string $type = 'info';
    public string $message;
    
    public function mount(string $message): void {
        $this->message = $message;
    }
}
```

#### Template Rendering Syntax
```twig
{# Function syntax #}
{{ component('Alert', {message: 'Error occurred', type: 'danger'}) }}

{# HTML-like syntax (2.x) #}
<twig:Alert message="Error occurred" type="danger" />
```

### Attributes Object (2.x Enhancement)

#### Attribute Manipulation Methods
```twig
{# In alert.html.twig template #}
<div {{ attributes.defaults({
    'class': 'alert alert-' ~ type,
    'role': 'alert'
}) }}>
    {{ message }}
</div>
```

**Available Methods**:
- `defaults(array)`: Set default attributes
- `only(array)`: Keep only specified attributes
- `without(array)`: Remove specified attributes
- `nested(string)`: Nest attributes under key

### Component Lifecycle (2.x)

#### Mount Method Signature
```php
public function mount(string $required, ?string $optional = null): void
{
    // Component initialization
    $this->processData($required);
}
```

#### Lifecycle Events
- **PreMountEvent**: Before mount() execution
- **PostMountEvent**: After mount() completion
- **PreRenderEvent**: Before template rendering

### Configuration Structure

```yaml
# config/packages/twig_component.yaml
twig_component:
    defaults:
        App\Components\:
            template_directory: 'components/'
            name_prefix: 'App'
        App\Components\Form\:
            template_directory: 'components/form/'
```

### Variable Exposure Control

#### ExposeInTemplate Attribute
```php
#[AsTwigComponent]
class ProductComponent {
    #[ExposeInTemplate]
    public Product $product;
    
    #[ExposeInTemplate('productName')]
    public function getName(): string {
        return $this->product->getName();
    }
    
    // Not exposed to template
    private EntityManagerInterface $em;
}
```

### Dynamic Component Names

#### Anonymous Components (2.x)
```twig
{% set componentName = 'Button' %}
{{ component(componentName, {text: 'Click me'}) }}
```

### Testing Integration

#### Test Trait Usage
```php
use Symfony\UX\TwigComponent\Test\InteractsWithTwigComponents;

class ComponentTest extends KernelTestCase {
    use InteractsWithTwigComponents;
    
    public function testAlertComponent(): void {
        $rendered = $this->renderComponent('Alert', [
            'message' => 'Test message',
            'type' => 'success'
        ]);
        
        $this->assertSelectorTextContains('.alert-success', 'Test message');
    }
}
```

### Console Commands

```bash
# Debug registered components
php bin/console debug:twig-component

# List component templates
php bin/console debug:twig-component --show-templates
```

### Performance Characteristics

- **Component instantiation**: Per-render cycle
- **Template caching**: Standard Twig cache applies
- **Attribute processing**: Runtime overhead for complex manipulations
- **Service injection**: Container resolution on each render