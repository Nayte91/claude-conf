# Symfony Forms v7.3 - Agent Reference

## Installation

```bash
composer require symfony/form
```

## Core Workflow

1. **Build** form (controller or dedicated class)
2. **Render** form in template
3. **Process** form (validate/transform data)

## Form Types Concept

Everything is a "form type":
- Single fields: `<input type="text">` → `TextType`
- Field groups: postal address → `PostalAddressType` 
- Complete forms: user profile → `UserProfileType`

## Entity Example

```php
// src/Entity/Task.php
namespace App\Entity;

class Task
{
    protected string $task;
    protected ?\DateTimeInterface $dueDate;

    public function getTask(): string { return $this->task; }
    public function setTask(string $task): void { $this->task = $task; }
    public function getDueDate(): ?\DateTimeInterface { return $this->dueDate; }
    public function setDueDate(?\DateTimeInterface $dueDate): void { $this->dueDate = $dueDate; }
}
```

## Form Creation Methods

### 1. Controller-Based Forms

```php
// src/Controller/TaskController.php
use Symfony\Component\Form\Extension\Core\Type\{TextType, DateType, SubmitType};

class TaskController extends AbstractController
{
    public function new(Request $request): Response
    {
        $task = new Task();
        
        $form = $this->createFormBuilder($task)
            ->add('task', TextType::class)
            ->add('dueDate', DateType::class)
            ->add('save', SubmitType::class, ['label' => 'Create Task'])
            ->getForm();
            
        // Process form...
    }
}
```

### 2. Dedicated Form Classes (Recommended)

```php
// src/Form/Type/TaskType.php
use Symfony\Component\Form\{AbstractType, FormBuilderInterface};
use Symfony\Component\OptionsResolver\OptionsResolver;

class TaskType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('task', TextType::class)
            ->add('dueDate', DateType::class)
            ->add('save', SubmitType::class);
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults([
            'data_class' => Task::class,
        ]);
    }
}
```

Controller usage:
```php
$form = $this->createForm(TaskType::class, $task);
```

## Form Rendering

### Controller
```php
public function new(Request $request): Response
{
    $form = $this->createForm(TaskType::class, $task);
    
    return $this->render('task/new.html.twig', [
        'form' => $form, // Calls $form->createView() internally
    ]);
}
```

### Template
```twig
{# templates/task/new.html.twig #}
{{ form(form) }}
```

### Bootstrap Integration
```yaml
# config/packages/twig.yaml
twig:
    form_themes: ['bootstrap_5_layout.html.twig']
```

## Form Processing

```php
public function new(Request $request): Response
{
    $task = new Task();
    $form = $this->createForm(TaskType::class, $task);

    $form->handleRequest($request);
    
    if ($form->isSubmitted() && $form->isValid()) {
        $task = $form->getData(); // Both $task and $form->getData() are updated
        
        // Process task (save to database, etc.)
        
        return $this->redirectToRoute('task_success');
    }

    return $this->render('task/new.html.twig', [
        'form' => $form, // Returns HTTP 422 on validation errors
    ]);
}
```

### Processing Flow
1. **GET request**: Form not submitted → render empty form
2. **POST invalid**: `isValid()` = false → re-render with errors (HTTP 422)
3. **POST valid**: `isValid()` = true → process data → redirect

## Validation

### Installation
```bash
composer require symfony/validator
```

### Entity-Level Constraints
```php
// src/Entity/Task.php
use Symfony\Component\Validator\Constraints as Assert;

class Task
{
    #[Assert\NotBlank]
    public string $task;

    #[Assert\NotBlank]
    #[Assert\Type(\DateTimeInterface::class)]
    protected \DateTimeInterface $dueDate;
}
```

Alternative formats:
```yaml
# config/validator/validation.yaml
App\Entity\Task:
    properties:
        task:
            - NotBlank: ~
        dueDate:
            - NotBlank: ~
            - Type: \DateTimeInterface
```

```php
// PHP method-based validation
public static function loadValidatorMetadata(ClassMetadata $metadata): void
{
    $metadata->addPropertyConstraint('task', new NotBlank());
    $metadata->addPropertyConstraint('dueDate', new NotBlank());
    $metadata->addPropertyConstraint('dueDate', new Type(\DateTimeInterface::class));
}
```

## Form Options

### Passing Custom Options
```php
// Controller
$form = $this->createForm(TaskType::class, $task, [
    'require_due_date' => true,
]);

// Form Type
public function configureOptions(OptionsResolver $resolver): void
{
    $resolver->setDefaults([
        'data_class' => Task::class,
        'require_due_date' => false,
    ]);
    $resolver->setAllowedTypes('require_due_date', 'bool');
}

public function buildForm(FormBuilderInterface $builder, array $options): void
{
    $builder
        ->add('task', TextType::class)
        ->add('dueDate', DateType::class, [
            'required' => $options['require_due_date'],
        ]);
}
```

### Common Field Options

#### `required` Option
```php
->add('dueDate', DateType::class, [
    'required' => false, // HTML5 validation only, server validation needs constraints
])
```

#### `label` Option
```php
->add('dueDate', DateType::class, [
    'label' => 'To Be Completed Before', // or false to hide label
])
```

## Form Configuration

### Action and Method
```php
// FormBuilder
$form = $this->createFormBuilder($task)
    ->setAction($this->generateUrl('target_route'))
    ->setMethod('GET')
    ->getForm();

// Form Type
$form = $this->createForm(TaskType::class, $task, [
    'action' => $this->generateUrl('target_route'),
    'method' => 'GET',
]);
```

```twig
{# Template override #}
{{ form_start(form, {'action': path('target_route'), 'method': 'GET'}) }}
```

### Custom Form Names
```php
// Using FormFactory
$form = $formFactory->createNamed('my_name', TaskType::class, $task);
// Creates: <form name="my_name" ...> and <input name="my_name[task]" ...>
```

## Advanced Features

### Type Guessing
When validation constraints exist, Symfony auto-guesses field types:
```php
$builder
    ->add('task') // Guesses TextType from validation
    ->add('dueDate', null, ['required' => false]) // Guesses DateType
    ->add('save', SubmitType::class);
```

**Guessed Options:**
- `required`: From NotBlank/NotNull constraints or Doctrine nullable
- `maxlength`: From Length/Range constraints or Doctrine field length

### Unmapped Fields
For fields not stored in the object:
```php
->add('agreeTerms', CheckboxType::class, ['mapped' => false])
```

Access in controller:
```php
$agreeTerms = $form->get('agreeTerms')->getData();
$form->get('agreeTerms')->setData(true);
```

### Client-Side Validation Control
```twig
{# Disable HTML5 validation #}
{{ form_start(form, {'attr': {'novalidate': 'novalidate'}}) }}
```

## Debug Commands

```bash
# List all form types
php bin/console debug:form

# Show specific type details
php bin/console debug:form BirthdayType

# Show specific option details
php bin/console debug:form BirthdayType label_attr
```

## HTTP Method Handling

For PUT/PATCH/DELETE methods:
- Symfony adds `<input type="hidden" name="_method" value="PUT">`
- Form submits as POST, but routing interprets as PUT
- Requires `http_method_override: true` in config

## Property Access Requirements

- Public properties: Direct access
- Protected/private: Requires getter/setter methods
- Boolean properties: Can use `isProperty()` or `hasProperty()` instead of `getProperty()`

## Form Theme Integration

Built-in themes:
- `bootstrap_3_layout.html.twig`
- `bootstrap_4_layout.html.twig`
- `bootstrap_5_layout.html.twig`
- `foundation_5_layout.html.twig`
- `foundation_6_layout.html.twig`
- `tailwind_2_layout.html.twig`

## Key Performance Notes

- Forms automatically set HTTP 422 on validation errors when passing `$form` (not `$form->createView()`)
- Form builder uses fluent interface for efficient chaining
- Type guessing reduces code but evaluates all constraints regardless of validation groups
- Unmapped fields explicitly set to null if not in submitted data