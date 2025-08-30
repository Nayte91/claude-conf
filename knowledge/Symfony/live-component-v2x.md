## Header
- **Source URL**: https://raw.githubusercontent.com/symfony/ux/refs/heads/2.x/src/LiveComponent/doc/index.rst
- **Processed Date**: 2025-01-25
- **Domain**: symfony/ux
- **Version**: v2x
- **Weight Reduction**: ~65%
- **Key Sections**: Installation, Components, LiveProps, Actions, Forms, Events, Testing, Performance, Security

## Body

### Installation & Setup
```bash
composer require symfony/ux-live-component
```

### Core Component Structure

#### Basic Component Declaration
```php
#[AsLiveComponent]
class ComponentName
{
    use DefaultActionTrait; // Required for basic functionality
}
```

#### Template Requirements
- **Single root HTML element**
- **Include `{{ attributes }}`** on root element
- **Example**: `<div {{ attributes }}>content</div>`

### LiveProps - Component State

#### Property Declaration
```php
#[LiveProp(writable: true)]    // User can modify
#[LiveProp(writable: false)]   // Read-only (default)
#[LiveProp(format: 'Y-m-d')]   // Date formatting
public string $property = 'default';
```

#### Supported Data Types
- **Scalars**: string, int, bool, float
- **Arrays and objects**
- **Doctrine entities** (with hydration)
- **DTOs and value objects**

#### Custom Hydration/Dehydration
```php
#[LiveProp(
    hydrateWith: 'hydrateEntity',
    dehydrateWith: 'dehydrateEntity'
)]
public Entity $entity;

public function hydrateEntity(int $id): Entity
{
    return $this->repository->find($id);
}

public function dehydrateEntity(Entity $entity): int
{
    return $entity->getId();
}
```

### Data Binding

#### Frontend Binding Attributes
```html
<!-- Basic model binding -->
<input data-model="query" />

<!-- With modifiers -->
<input data-model="debounce(300ms)|query" />
<input data-model="on(change)|query" />
<input data-model="norender|query" />
```

#### Binding Modifiers
- **`debounce(Nms)`**: Delay updates by N milliseconds
- **`on(event)`**: Update on specific event (change, blur, etc.)
- **`norender`**: Update prop without re-rendering
- **`defer`**: Update only on form submit

### Actions - Server-Side Methods

#### Action Declaration
```php
#[LiveAction]
public function methodName(#[LiveArg] string $arg): void
{
    // Action logic
    // Can modify component state
    // Can return Response for redirects
}
```

#### Frontend Action Triggers
```html
<!-- Button click -->
<button data-action="live#action" data-action-name="methodName">Click</button>

<!-- With arguments -->
<button 
    data-action="live#action" 
    data-action-name="methodName"
    data-action-method-arg-value="argument">
    Click
</button>

<!-- Form submission -->
<form data-action="live#action" data-action-name="save">
```

### Form Integration

#### ComponentWithFormTrait
```php
#[AsLiveComponent]
class FormComponent extends AbstractController
{
    use ComponentWithFormTrait;
    use DefaultActionTrait;

    #[LiveProp]
    public ?Entity $initialFormData = null;

    protected function instantiateForm(): FormInterface
    {
        return $this->createForm(EntityType::class, $this->initialFormData);
    }
}
```

#### Form Template Usage
```twig
<div {{ attributes }}>
    {{ form_start(form) }}
    {{ form_widget(form) }}
    <button type="submit">Submit</button>
    {{ form_end(form) }}
</div>
```

#### Collection Type Handling
```php
#[LiveAction]
public function addItem(): void
{
    $this->formValues['items'][] = [];
    // Form automatically re-renders with new item
}

#[LiveAction]
public function removeItem(#[LiveArg] int $index): void
{
    unset($this->formValues['items'][$index]);
}
```

### Validation

#### Automatic Validation
- **Forms validate automatically** on submission
- **Individual fields validate** on blur/change
- **Validation errors display** in real-time

#### Custom Validation
```php
use Symfony\Component\Validator\Constraints as Assert;

#[LiveProp(writable: true)]
#[Assert\NotBlank]
#[Assert\Length(min: 3)]
public string $username = '';
```

#### ValidatableComponentTrait
```php
use ValidatableComponentTrait;

public function getDataToValidate(): mixed
{
    return $this;
}

public function getValidationGroups(): array|string
{
    return ['Default', 'custom_group'];
}
```

### Events & Component Communication

#### Event Emission
```php
#[LiveAction]
public function save(): void
{
    // Emit to parent
    $this->emit('productSaved', ['id' => $product->getId()]);
    
    // Emit to specific component
    $this->emitTo('product_list', 'refresh');
    
    // Emit to self
    $this->emitSelf('reload');
}
```

#### Event Listening
```php
#[LiveListener('productSaved')]
public function onProductSaved(#[LiveArg] int $id): void
{
    $this->products = $this->repository->findAll();
}
```

#### Frontend Event Handling
```html
<div 
    data-live-listen="productSaved->live#action"
    data-action-name="refreshList"
>
```

### Loading States & UI Feedback

#### Loading Attributes
```html
<!-- Show during any action -->
<div data-loading>Loading...</div>

<!-- Show during specific action -->
<div data-loading="action(save)">Saving...</div>

<!-- Hide during loading -->
<div data-loading="hide">Content</div>

<!-- Disable during loading -->
<button data-loading="addClass(opacity-50)">Submit</button>
```

### Advanced Features

#### URL Parameter Binding
```php
#[LiveProp(writable: true, url: true)]
public string $page = '1';
```

#### Polling
```html
<div 
    {{ attributes }}
    data-poll="2000"
    data-poll-action="refresh"
>
```

#### Lazy Loading
```php
#[AsLiveComponent(lazy: true)]
class ExpensiveComponent
{
    // Component loads after initial page render
}
```

#### Morphing Configuration
```html
<div {{ attributes.defaults({
    'data-live-morph': 'morph',
    'data-live-morph-options': '{"childrenOnly": true}'
}) }}>
```

### File Uploads

#### Upload Action
```php
#[LiveAction]
public function uploadFile(#[LiveArg] UploadedFile $file): void
{
    // Handle file upload
    $filename = $this->fileUploader->upload($file);
    $this->uploadedFilename = $filename;
}
```

#### Frontend Upload
```html
<input 
    type="file"
    data-action="live#action"
    data-action-name="uploadFile"
>
```

### Performance Optimizations

#### Selective Re-rendering
```php
#[LiveProp(writable: true)]
public string $query = '';

public function getExpensiveData(): array
{
    // Use caching or memoization
    return $this->cache->get('expensive_' . $this->query, function() {
        return $this->repository->complexQuery($this->query);
    });
}
```

#### Debouncing
```html
<input data-model="debounce(500ms)|searchTerm" />
```

### Testing

#### Component Testing
```php
use Symfony\UX\LiveComponent\Test\TestLiveComponent;

$component = TestLiveComponent::createFor(ProductSearch::class)
    ->set('query', 'laptop')
    ->call('search')
    ->assertSet('results', function($results) {
        return count($results) > 0;
    });
```

#### Integration Testing
```php
$client->request('GET', '/product-search');
$client->submitForm('Search', ['query' => 'laptop']);
$this->assertSelectorTextContains('.results', 'MacBook');
```

### Security Considerations

#### CSRF Protection
- **Enabled by default** for all actions
- **Uses Symfony's CSRF** token manager
- **Tokens automatically included** in requests

#### Input Sanitization
- **All LiveProp values** are validated
- **Use Symfony constraints** for validation
- **Escape output** in templates

#### Access Control
```php
#[LiveAction]
#[IsGranted('ROLE_ADMIN')]
public function adminAction(): void
{
    // Restricted action
}
```

### Best Practices

#### Component Design
- **Keep components focused** and single-purpose
- **Use composition** over inheritance
- **Limit LiveProp count** for performance
- **Implement proper validation**

#### State Management
- **Use LiveProps** for component-specific state
- **Emit events** for cross-component communication
- **Consider URL parameters** for shareable state

#### Performance
- **Implement debouncing** for user input
- **Use lazy loading** for expensive components
- **Cache expensive computations**
- **Minimize DOM morphing scope**

### Common Patterns

#### Search Component
```php
#[AsLiveComponent]
class SearchComponent
{
    use DefaultActionTrait;

    #[LiveProp(writable: true, url: true)]
    public string $query = '';

    #[LiveProp(writable: true, url: true)]
    public int $page = 1;

    public function getResults(): PaginatorInterface
    {
        return $this->paginator->paginate(
            $this->repository->searchQuery($this->query),
            $this->page,
            10
        );
    }

    #[LiveAction]
    public function nextPage(): void
    {
        $this->page++;
    }
}
```

#### Dynamic Form
```php
#[AsLiveComponent]
class DynamicForm extends AbstractController
{
    use ComponentWithFormTrait;
    use DefaultActionTrait;

    #[LiveProp]
    public array $formData = [];

    #[LiveAction]
    public function addField(): void
    {
        $this->formData['fields'][] = '';
    }

    #[LiveAction]
    public function removeField(#[LiveArg] int $index): void
    {
        unset($this->formData['fields'][$index]);
    }

    protected function instantiateForm(): FormInterface
    {
        return $this->createFormBuilder($this->formData)
            ->add('fields', CollectionType::class, [
                'entry_type' => TextType::class,
                'allow_add' => true,
                'allow_delete' => true,
            ])
            ->getForm();
    }
}
```