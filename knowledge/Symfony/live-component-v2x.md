## Header
- **Source**: https://raw.githubusercontent.com/symfony/ux/refs/heads/2.x/src/LiveComponent/doc/index.rst
- **Processed Date**: 2025-01-25
- **Domain**: symfony/ux
- **Version**: v2x
- **Weight Reduction**: ~85%
- **Key Sections**: Component Declaration, LiveProps, Actions, Data Binding, Form Integration, Events

## Body

### UX LiveComponent 2.x Declaration

```php
#[AsLiveComponent]
class ProductSearch
{
    use DefaultActionTrait; // Required for basic functionality
    
    #[LiveProp(writable: true, url: true)]
    public string $query = '';
    
    #[LiveProp(writable: true)]
    public int $page = 1;
}
```

### LiveProp Configuration (2.x)

#### Data Types & Hydration
```php
#[LiveProp(writable: true, format: 'Y-m-d')]
public \DateTime $date;

#[LiveProp(
    hydrateWith: 'hydrateEntity',
    dehydrateWith: 'dehydrateEntity'
)]
public Product $product;

public function hydrateEntity(int $id): Product
{
    return $this->entityManager->find(Product::class, $id);
}

public function dehydrateEntity(Product $product): int
{
    return $product->getId();
}
```

### Data Binding Attributes (2.x)

```html
<!-- Basic model binding -->
<input data-model="query" />

<!-- Debounced updates -->
<input data-model="debounce(300ms)|query" />

<!-- Event-specific binding -->
<input data-model="on(change)|query" />

<!-- Update without re-rendering -->
<input data-model="norender|query" />
```

### LiveAction Implementation (2.x)

```php
#[LiveAction]
public function search(): void
{
    $this->page = 1; // Reset pagination
}

#[LiveAction]
public function nextPage(#[LiveArg] int $page): void
{
    $this->page = $page;
}

#[LiveAction]
public function delete(#[LiveArg] int $id): Response
{
    $this->productRepository->delete($id);
    $this->addFlash('success', 'Product deleted');
    return $this->redirectToRoute('product_list');
}
```

### Form Integration (2.x)

#### ComponentWithFormTrait Usage
```php
#[AsLiveComponent]
class ProductForm extends AbstractController
{
    use ComponentWithFormTrait;
    use DefaultActionTrait;

    #[LiveProp]
    public ?Product $initialFormData = null;

    protected function instantiateForm(): FormInterface
    {
        return $this->createForm(ProductType::class, $this->initialFormData);
    }
}
```

#### Dynamic Collections
```php
#[LiveAction]
public function addItem(): void
{
    $this->formValues['items'][] = [];
}

#[LiveAction] 
public function removeItem(#[LiveArg] int $index): void
{
    unset($this->formValues['items'][$index]);
}
```

### Event System (2.x)

#### Event Emission
```php
#[LiveAction]
public function save(): void
{
    // Emit to parent component
    $this->emit('productSaved', ['id' => $product->getId()]);
    
    // Emit to specific component
    $this->emitTo('product_list', 'refresh');
}
```

#### Event Listeners
```php
#[LiveListener('productSaved')]
public function onProductSaved(#[LiveArg] int $id): void
{
    $this->products = $this->productRepository->findAll();
}
```

### Loading States (2.x)

```html
<!-- Loading indicators -->
<div data-loading>Loading...</div>
<div data-loading="action(save)">Saving...</div>
<div data-loading="addClass(opacity-50)">Content</div>

<!-- Hide during loading -->
<div data-loading="hide">Hide when loading</div>
```

### Advanced Features (2.x)

#### URL Parameter Binding
```php
#[LiveProp(writable: true, url: true)]
public string $filter = '';
```

#### Component Polling
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

### Testing Integration (2.x)

```php
use Symfony\UX\LiveComponent\Test\TestLiveComponent;

$component = TestLiveComponent::createFor(ProductSearch::class)
    ->set('query', 'laptop')
    ->call('search')
    ->assertSet('results', function($results) {
        return count($results) > 0;
    });
```

### Performance Optimizations

- **Debouncing**: `data-model="debounce(500ms)|field"`
- **Selective updates**: `data-model="norender|field"`
- **Lazy loading**: `lazy: true` attribute
- **Caching**: Implement `getExpensiveData()` with cache