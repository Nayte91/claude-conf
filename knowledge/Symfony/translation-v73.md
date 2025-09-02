## Header
- **Source**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/translation.rst
- **Processed Date**: 2025-09-01
- **Domain**: symfony.com
- **Version**: v7.3
- **Weight Reduction**: ~85%
- **Key Sections**: v7.3 Configuration, Translation Methods, Console Commands, Provider Integration

## Body

### Symfony 7.3 Translation Installation

```bash
composer require symfony/translation
```

### Symfony 7.3 Configuration

```yaml
# config/packages/framework.yaml (v7.3)
framework:
    default_locale: 'en'
    translator:
        default_path: '%kernel.project_dir%/translations'
        fallbacks: ['en']
        cache_dir: '%kernel.cache_dir%/translations'  # v7.3: Cache optimization
        providers:
            crowdin:
                dsn: '%env(CROWDIN_DSN)%'  # v7.3: Provider integration
        pseudo_localization:               # v7.3: Pseudo-localization
            enabled: true
            accenter: true
            expander: true
            brackets: true
```

### Symfony 7.3 Translation Methods

```php
// v7.3 basic translation
$translated = $translator->trans('Symfony is great');

// v7.3 TranslatableMessage
$message = new TranslatableMessage('Symfony is great!');

// v7.3 with parameters
$translated = $translator->trans('Hello %name%', ['%name%' => $name]);

// v7.3 translation domains
$translated = $translator->trans('hello.world', [], 'messages');
```

### Symfony 7.3 Locale Management

```php
// v7.3 programmatic locale switching
$localeSwitcher->setLocale('fr');

// v7.3 run with specific locale
$localeSwitcher->runWithLocale('es', function() {
    // Localized execution context
});

// v7.3 get current locale
$currentLocale = $requestStack->getCurrentRequest()->getLocale();
```

### Symfony 7.3 Message Formats

#### YAML Format (v7.3)
```yaml
# translations/messages.fr.yaml
hello.world: 'Bonjour le monde'
user.greeting: 'Bonjour %name%'
```

#### XLIFF Format (v7.3)
```xml
<!-- translations/messages.fr.xlf -->
<trans-unit id="hello.world">
    <source>hello.world</source>
    <target>Bonjour le monde</target>
</trans-unit>
```

### Symfony 7.3 ICU MessageFormat

```yaml
# translations/messages.en.yaml (v7.3 ICU support)
user.balance: |
    {balance, number, currency} remaining.
    {balance, plural,
        =0 {You have no money}
        one {You have one dollar}
        other {You have # dollars}
    }
```

### Symfony 7.3 Pluralization

```php
// v7.3 pluralization pattern
$translator->trans('apples.count', [
    '%count%' => $appleCount,
    '{0}' => 'no apples',
    '{1}' => 'one apple',
    'other' => '%count% apples'
]);
```

### Symfony 7.3 Console Commands

```bash
# v7.3 translation extraction
php bin/console translation:extract --format=yaml en
php bin/console translation:extract --format=yaml --force-write en

# v7.3 debugging commands
php bin/console debug:translation fr
php bin/console debug:translation fr --only-missing
php bin/console debug:translation --only-invalid

# v7.3 validation
php bin/console lint:yaml translations/
```

### Symfony 7.3 Translation Providers

**Supported Providers (v7.3)**:
- Crowdin
- Lokalise
- Phrase

```yaml
# config/packages/framework.yaml (v7.3)
framework:
    translator:
        providers:
            crowdin:
                dsn: '%env(CROWDIN_DSN)%'
            lokalise:
                dsn: '%env(LOKALISE_DSN)%'
```

### Symfony 7.3 Twig Integration

```twig
{# v7.3 Twig translation filters #}
{{ 'hello.world'|trans }}
{{ 'user.greeting'|trans({'%name%': user.name}) }}
{{ 'button.save'|trans({},'admin') }}

{# v7.3 translation blocks #}
{% trans %}Hello World{% endtrans %}
{% trans with {'%name%': user.name} %}Hello %name%{% endtrans %}
```

### Symfony 7.3 HTML-Aware Translations

```php
// v7.3 TranslatableMessage with HTML
$message = new TranslatableMessage('Welcome <strong>%name%</strong>!', [
    '%name%' => $user->getName()
]);
```

### Symfony 7.3 Pseudo-localization

```yaml
# config/packages/framework.yaml (v7.3)
framework:
    translator:
        pseudo_localization:
            enabled: true     # Enable pseudo-localization
            accenter: true    # Add accents to characters
            expander: true    # Expand text length
            brackets: true    # Add brackets around text
```

### Symfony 7.3 Performance Configuration

```yaml
# config/packages/prod/framework.yaml (v7.3)
framework:
    translator:
        cache_dir: '%kernel.cache_dir%/translations'
```

### Symfony 7.3 Error Handling

```php
// v7.3 check translation existence
if ($translator->getCatalogue()->has('some.key', 'domain')) {
    $translated = $translator->trans('some.key', [], 'domain');
}

// v7.3 validation commands
php bin/console lint:yaml translations/
php bin/console debug:translation --only-invalid
```

### Symfony 7.3 Resource Formats

**Supported in v7.3**:
- YAML (recommended)
- XML (XLIFF) - professional workflows
- PHP array
- JSON
- CSV
- INI

### Symfony 7.3 Translation Workflow

1. **Internationalization**: Abstract locale-specific strings
2. **Translation Functions**: Wrap text with `trans()` or `TranslatableMessage`
3. **Resource Creation**: Create translation files per locale
4. **Extraction**: Use console commands to extract translatable strings
5. **Provider Integration**: Sync with translation services