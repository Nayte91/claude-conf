# Symfony Translation v7.3 - Developer Reference Digest

## Metadata
- **Source URL**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/translation.rst
- **Processed Date**: 2025-08-29
- **Domain**: Translation/i18n
- **Version**: 7.3
- **Weight Reduction**: ~85% (from 1702 lines to ~400 lines)

## Installation & Configuration

### Install
```bash
composer require symfony/translation
```

### Basic Configuration
```yaml
# config/packages/translation.yaml
framework:
    default_locale: 'en'
    translator:
        default_path: '%kernel.project_dir%/translations'
        fallbacks: ['en']
        enabled_locales: ['en', 'fr', 'de'] # optional restriction
```

## Core Translation Methods

### Basic Translation
```php
// Controller injection
public function index(TranslatorInterface $translator): Response
{
    $translated = $translator->trans('Hello World');
    $withParams = $translator->trans('Hello %name%', ['%name%' => $user->getName()]);
    $withDomain = $translator->trans('Hello World', [], 'messages');
    $withLocale = $translator->trans('Hello World', [], 'messages', 'fr');
}
```

### Translatable Objects (Recommended for Services)
```php
use Symfony\Component\Translation\TranslatableMessage;

// Create translatable object (delays translation)
$message = new TranslatableMessage('Hello %name%', ['%name%' => $name], 'domain');

// Use in templates
// {{ message|trans }}

// Shortcut function
$message = t('Hello %name%', ['%name%' => $name], 'domain');
```

## Translation Files

### File Naming Convention
`domain.locale.loader`
- `messages.fr.yaml` (default domain, French, YAML format)
- `validators.en.xlf` (validators domain, English, XLIFF format)

### File Locations (Priority Order)
1. `translations/` (project root)
2. Bundle `translations/` directories
3. Custom paths via `framework.translator.paths`

### Supported Formats
- `.yaml/.yml` - YAML (recommended for simple projects)
- `.xlf/.xliff` - XLIFF (recommended for teams/translation services)
- `.php` - PHP arrays
- `.csv`, `.json`, `.ini`, `.dat`, `.res`, `.mo`, `.po`, `.qt`

### Translation File Examples

**YAML (nested keys supported)**:
```yaml
# translations/messages.fr.yaml
Hello World: Bonjour le monde
user:
    login: Connexion
    logout: Déconnexion
    profile:
        edit: Modifier le profil
```

**XLIFF**:
```xml
<!-- translations/messages.fr.xlf -->
<?xml version="1.0" encoding="UTF-8" ?>
<xliff version="1.2" xmlns="urn:oasis:names:tc:xliff:document:1.2">
    <file source-language="en" datatype="plaintext" original="file.ext">
        <body>
            <trans-unit id="hello_world">
                <source>Hello World</source>
                <target>Bonjour le monde</target>
            </trans-unit>
        </body>
    </file>
</xliff>
```

**PHP Arrays**:
```php
// translations/messages.fr.php
return [
    'Hello World' => 'Bonjour le monde',
    'user' => [
        'login' => 'Connexion', // nested key: user.login
    ],
];
```

## Template Translation

### Twig Filters
```twig
{# Basic translation #}
{{ message|trans }}
{{ message|trans({'%name%': user.name}, 'app') }}

{# Set domain for entire template #}
{% trans_default_domain 'app' %}

{# Escape HTML (default behavior with filter) #}
{{ message|trans|raw }}
```

### Twig Tags
```twig
{# Static blocks (no auto-escaping) #}
{% trans %}Hello %name%{% endtrans %}
{% trans with {'%name%': user.name} from 'app' %}Hello %name%{% endtrans %}
{% trans with {'%name%': user.name} from 'app' into 'fr' %}Hello %name%{% endtrans %}

{# Escape percent signs #}
{% trans %}Progress: %progress%%%{% endtrans %}
```

## Locale Management

### Setting Locale
```php
// In controller/listener (before LocaleListener)
$request->setLocale($locale);

// Direct on translator (late binding)
$translator->setLocale($locale);

// URL-based locale (automatic)
// Route: /{_locale}/contact
// URL: /fr/contact -> locale = 'fr'
```

### Route Configuration
```php
// Attributes
#[Route(path: '/{_locale}/contact', requirements: ['_locale' => 'en|fr|de'])]

// YAML
contact:
    path: /{_locale}/contact
    controller: App\Controller\ContactController::contact
    requirements:
        _locale: en|fr|de
```

### Locale Switcher (7.3+)
```php
use Symfony\Component\Translation\LocaleSwitcher;

class SomeService
{
    public function __construct(private LocaleSwitcher $localeSwitcher) {}

    public function method(): void
    {
        $current = $this->localeSwitcher->getLocale();
        
        // Change locale temporarily
        $this->localeSwitcher->setLocale('fr');
        
        // Reset to default
        $this->localeSwitcher->reset();
        
        // Execute code with specific locale
        $this->localeSwitcher->runWithLocale('es', function(string $locale) {
            // Code executed with 'es' locale
        });
    }
}
```

### Preferred Language Detection
```php
$request = $this->requestStack->getCurrentRequest();
$locale = $request->getPreferredLanguage(['pt', 'fr', 'en']);
```

## Translation Fallback

**Fallback Chain Example** (locale: `es_AR`):
1. `es_AR` (Argentinean Spanish)
2. `es_419` (Latin American Spanish) - auto-parent
3. `es` (Spanish)
4. Configured fallbacks (`en`)
5. Default locale

## Global Translation Parameters (7.3+)

### Configuration
```yaml
# config/packages/translation.yaml
framework:
    translator:
        globals:
            '%%app_name%%': 'My App'      # %% escaping required
            '{app_version}': '2.1.0'
            '{url}': 
                message: 'base_url'
                parameters: {scheme: 'https://'}
                domain: 'global'
```

### Usage
```twig
{{ 'App: %%app_name%% v{app_version}'|trans }}
{# Output: "App: My App v2.1.0" #}

{# Override globals #}
{{ 'Version: {app_version}'|trans({'{app_version}': '3.0.0'}) }}
```

## CLI Commands

### Extract Translations
```bash
# Show missing translations
php bin/console translation:extract --dump-messages fr

# Update translation files
php bin/console translation:extract --force fr

# Custom prefix for new entries
php bin/console translation:extract --force --prefix="TODO_" fr

# Leave new entries empty
php bin/console translation:extract --force --no-fill fr
```

### Debug Translations
```bash
# Check all translations for locale
php bin/console debug:translation fr

# Specific domain
php bin/console debug:translation fr --domain=messages

# Only show issues
php bin/console debug:translation fr --only-missing
php bin/console debug:translation fr --only-unused
```

**Exit codes**: `TranslationDebugCommand::EXIT_CODE_*`
- `GENERAL_ERROR`: Generic failure
- `MISSING`: Missing translations
- `UNUSED`: Unused translations  
- `FALLBACK`: Using fallback translations

### Lint Translation Files
```bash
# Validate syntax
php bin/console lint:yaml translations/
php bin/console lint:xliff translations/

# Validate content (7.2+)
php bin/console lint:translations
php bin/console lint:translations --locale=fr --locale=de
```

## Translation Providers

### Supported Providers
| Provider | Package | DSN Format |
|----------|---------|------------|
| Crowdin | `symfony/crowdin-translation-provider` | `crowdin://PROJECT_ID:API_TOKEN@ORGANIZATION.default` |
| Loco | `symfony/loco-translation-provider` | `loco://API_KEY@default` |
| Lokalise | `symfony/lokalise-translation-provider` | `lokalise://PROJECT_ID:API_KEY@default` |
| Phrase | `symfony/phrase-translation-provider` | `phrase://PROJECT_ID:API_TOKEN@default?userAgent=myProject` |

### Configuration
```yaml
# config/packages/translation.yaml
framework:
    translator:
        providers:
            loco:
                dsn: '%env(LOCO_DSN)%'
                domains: ['messages', 'validators']
                locales: ['en', 'fr', 'de']
```

### Push/Pull Commands
```bash
# Push translations to provider
php bin/console translation:push loco --force
php bin/console translation:push loco --locales fr --domains validators

# Pull translations from provider
php bin/console translation:pull loco --force
php bin/console translation:pull loco --locales fr --domains validators --as-tree
```

## Message Format (ICU)

Symfony supports ICU MessageFormat for complex translations:

```php
// Pluralization
$translator->trans('There {count, plural, =0{are no apples} one{is one apple} other{are # apples}}', ['count' => 5]);

// Choice/Select
$translator->trans('Hello {gender, select, male{Mr.} female{Ms.} other{}}', ['gender' => 'male']);
```

## Best Practices

### Message Keys Strategy
**Real Messages** (good for simple apps):
```php
$translator->trans('Symfony is great');
// translations/messages.fr.yaml: 'Symfony is great': 'Symfony est génial'
```

**Keyword Messages** (recommended for complex apps):
```php
$translator->trans('app.welcome');
// translations/messages.fr.yaml: 'app.welcome': 'Bienvenue'
```

### Performance Tips
- Use YAML for development, XLIFF for production
- Enable `enabled_locales` to restrict supported locales
- Use `nikic/php-parser` for better extraction results
- Clear cache after adding new translation catalogs

### Extraction Targets
The `translation:extract` command scans:
- Templates in `templates/` directory
- PHP files injecting `TranslatorInterface`
- PHP files using `TranslatableMessage` or `t()` function
- Validation constraint messages with `*message` arguments

## Pseudo-localization (Development)

```yaml
# config/packages/translation.yaml (dev environment)
framework:
    translator:
        pseudo_localization:
            accents: true              # Àççôûñţ Šéţţîñĝš
            brackets: true             # [!!! text !!!]
            expansion_factor: 1.4      # Make text longer
            parse_html: true           # Preserve HTML tags
            localizable_html_attributes: ['title', 'alt']
```

## Cross-References

### Related Symfony Components
- **Validation**: Uses translation for constraint messages
- **Form**: Form labels and validation messages  
- **Security**: Authentication/authorization messages
- **Console**: Command help and error messages

### Integration Points
- Templates: `trans` filter and tags
- Validators: `message` parameter translation
- Forms: Automatic label translation
- Flash messages: Manual translation in controllers