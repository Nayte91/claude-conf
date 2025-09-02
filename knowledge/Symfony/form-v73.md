## Header
- **Source**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/forms.rst
- **Processed Date**: 2025-09-01
- **Domain**: symfony.com
- **Version**: v7.3
- **Weight Reduction**: ~85%
- **Key Sections**: v7.3 Form Architecture, Processing Pattern, Configuration Options, Built-in Themes

## Body

### Symfony 7.3 Form Installation

```bash
composer require symfony/form
```

### Symfony 7.3 Form Type Architecture

```php
use Symfony\Component\Form\{AbstractType, FormBuilderInterface};
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Form\Extension\Core\Type\{TextType, DateType, SubmitType};

// v7.3 Form Type class
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

### Symfony 7.3 Form Processing Pattern

```php
// v7.3 processing workflow
public function new(Request $request): Response
{
    $task = new Task();
    $form = $this->createForm(TaskType::class, $task);

    $form->handleRequest($request);
    
    if ($form->isSubmitted() && $form->isValid()) {
        $task = $form->getData(); // Auto-updated
        // Process task
        return $this->redirectToRoute('task_success');
    }

    // Returns HTTP 422 on validation errors
    return $this->render('task/new.html.twig', ['form' => $form]);
}
```

### Symfony 7.3 Form Configuration Options

```php
// v7.3 custom options
$form = $this->createForm(TaskType::class, $task, [
    'require_due_date' => true,
    'action' => $this->generateUrl('target_route'),
    'method' => 'GET',
]);

// v7.3 OptionsResolver
public function configureOptions(OptionsResolver $resolver): void
{
    $resolver->setDefaults([
        'data_class' => Task::class,
        'require_due_date' => false,
    ]);
    $resolver->setAllowedTypes('require_due_date', 'bool');
}
```

### Symfony 7.3 Field Options

```php
// v7.3 field configuration
$builder
    ->add('task')  // Auto-guessed from validation constraints
    ->add('dueDate', null, ['required' => false])
    ->add('agreeTerms', CheckboxType::class, ['mapped' => false])
    ->add('save', SubmitType::class, ['label' => 'Create Task']);

// Access unmapped field
$agreeTerms = $form->get('agreeTerms')->getData();
```

### Symfony 7.3 Validation Integration

```php
// v7.3 entity validation
use Symfony\Component\Validator\Constraints as Assert;

class Task
{
    #[Assert\NotBlank]
    #[Assert\Length(min: 2, max: 255)]
    public string $task;

    #[Assert\NotBlank]
    #[Assert\Type(\DateTimeInterface::class)]
    protected \DateTimeInterface $dueDate;
}
```

### Symfony 7.3 Form Themes

```yaml
# config/packages/twig.yaml (v7.3 themes)
twig:
    form_themes: ['bootstrap_5_layout.html.twig']
```

**Available Themes in v7.3**:
- `bootstrap_3_layout.html.twig`
- `bootstrap_4_layout.html.twig`
- `bootstrap_5_layout.html.twig`
- `foundation_5_layout.html.twig`
- `foundation_6_layout.html.twig`
- `tailwind_2_layout.html.twig`

### Symfony 7.3 Twig Rendering

```twig
{# v7.3 form rendering #}
{{ form(form) }}

{# Disable HTML5 validation #}
{{ form_start(form, {'attr': {'novalidate': 'novalidate'}}) }}

{# v7.3 conditional rendering #}
{% if app.environment == 'dev' %}
    {{ form(form, {validation: false}) }}
{% endif %}
```

### Symfony 7.3 Debug Commands

```bash
# v7.3 form debugging
php bin/console debug:form
php bin/console debug:form BirthdayType
php bin/console debug:form BirthdayType label_attr
```

### Symfony 7.3 Form Builder Patterns

```php
// v7.3 FormBuilder alternatives
class TaskController extends AbstractController
{
    // Controller-based form (quick prototyping)
    public function quickForm(): Response
    {
        $task = new Task();
        
        $form = $this->createFormBuilder($task)
            ->add('task', TextType::class)
            ->add('dueDate', DateType::class)
            ->add('save', SubmitType::class, ['label' => 'Create Task'])
            ->getForm();
        
        return $this->render('task/new.html.twig', ['form' => $form]);
    }
}
```

### Symfony 7.3 Form States

1. **GET request**: Form not submitted → render empty form
2. **POST invalid**: `isValid()` = false → re-render with errors (HTTP 422)
3. **POST valid**: `isValid()` = true → process data → redirect

### Symfony 7.3 Performance Notes

- Forms automatically set HTTP 422 on validation errors
- Type guessing evaluates all constraints (regardless of validation groups)
- Use dedicated form classes for reusability
- Property accessors (getters/setters) are leveraged automatically