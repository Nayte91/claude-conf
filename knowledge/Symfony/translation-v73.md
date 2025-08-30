## Header

- **Source URL**: https://symfony.com/doc/current/translation.html
- **Processed Date**: 2025-08-30
- **Requesting Agent**: Documents Chewer (force refresh)
- **Domain**: Symfony
- **Version**: 7.3
- **Weight Reduction**: ~78% (from web documentation to essential directives)
- **Key Sections**: Installation, Configuration, Translation Methods, File Formats, Locale Management, Advanced Features, Commands

## Body

### Installation
```bash
composer require symfony/translation
```
Requires PHP `intl` extension for non-English locales.

### Configuration
```yaml
# config/packages/translation.yaml
framework:
    default_locale: 'en'
    translator:
        default_path: '%kernel.project_dir%/translations'
        fallbacks: ['en']
        enabled_locales: ['en', 'fr', 'de']
```

### Translation Methods

**Controller Integration:**
```php
use Symfony\Contracts\Translation\TranslatorInterface;

public function index(TranslatorInterface $translator): Response
{
    $translated = $translator->trans('message.key');
    $withParams = $translator->trans('welcome.message', ['%name%' => $user->getName()]);
    $withDomain = $translator->trans('admin.title', domain: 'admin');
    $withLocale = $translator->trans('message', locale: 'fr');
}
```

**Twig Integration:**
```twig
{{ 'message.key'|trans }}
{{ 'welcome.message'|trans({'%name%': user.name}) }}
{{ 'admin.title'|trans({}, 'admin') }}
{% trans %}Hello World{% endtrans %}
{% trans with {'%name%': user.name} %}Hello %name%{% endtrans %}
```

### File Formats and Structure

**File Naming Convention:** `domain.locale.format`

**YAML Format (Recommended):**
```yaml
# translations/messages.fr.yaml
message.key: Message traduit
welcome.message: Bienvenue %name%
nested:
    key: Valeur imbriquée
```

**XLIFF Format:**
```xml
<!-- translations/messages.fr.xlf -->
<trans-unit id="message_key">
    <source>message.key</source>
    <target>Message traduit</target>
</trans-unit>
```

**PHP Format:**
```php
// translations/messages.fr.php
return [
    'message.key' => 'Message traduit',
    'welcome.message' => 'Bienvenue %name%',
];
```

### Locale Management

**URL-Based Locale Setting:**
```yaml
# config/routes.yaml
homepage:
    path: /{_locale}/homepage
    requirements:
        _locale: en|fr|de
```

**Programmatic Locale Management:**
```php
use Symfony\Component\Translation\LocaleSwitcher;

class LocaleController
{
    public function switchLocale(LocaleSwitcher $localeSwitcher, string $locale): Response
    {
        $localeSwitcher->setLocale($locale);
        return $this->redirectToRoute('homepage');
    }
}
```

### Advanced Features

**Message Placeholders:**
```php
$translator->trans('user.greeting', [
    '%username%' => $user->getUsername(),
    '%count%' => $messageCount
]);
```

**Translatable Objects:**
```php
use Symfony\Contracts\Translation\TranslatableInterface;

class TranslatableMessage implements TranslatableInterface
{
    public function trans(TranslatorInterface $translator, string $locale = null): string
    {
        return $translator->trans($this->message, $this->parameters, $this->domain, $locale);
    }
}
```

**ICU MessageFormat:**
```yaml
# translations/messages.en.yaml
notification.count: |
    {count, plural,
        =0 {No notifications}
        one {One notification}
        other {# notifications}
    }
```

### Translation Commands

**Extract Translatable Messages:**
```bash
php bin/console translation:extract --dump-messages fr
php bin/console translation:extract --force fr  # Update files
```

**Debug Translations:**
```bash
php bin/console debug:translation fr  # All translations for French
php bin/console debug:translation fr AppBundle  # Specific domain
php bin/console debug:translation --only-missing fr  # Missing only
php bin/console debug:translation --only-unused fr   # Unused only
```

**Lint Translation Files:**
```bash
php bin/console lint:translations
php bin/console lint:translations fr
```

### Translation Providers

**Configuration for External Services:**
```yaml
# config/packages/translation.yaml
framework:
    translator:
        providers:
            crowdin:
                dsn: 'crowdin://PROJECT_ID:API_TOKEN@default'
            lokalise:
                dsn: 'lokalise://PROJECT_ID:API_TOKEN@default'
```

**Provider Commands:**
```bash
php bin/console translation:push crowdin  # Push to provider
php bin/console translation:pull crowdin  # Pull from provider
```

### Testing with Pseudo-localization

**Enable Pseudo-localization:**
```yaml
# config/packages/translation.yaml
framework:
    translator:
        pseudo_localization:
            enabled: true
            accents: true
            expansion_factor: 1.3
            brackets: true
```

**Testing Commands:**
```bash
php bin/console translation:extract --dump-messages pseudo  # Generate pseudo translations
```

### Performance Optimization

**Translation Caching:**
```yaml
# config/packages/translation.yaml (prod)
framework:
    translator:
        cache_dir: '%kernel.cache_dir%/translations'
```

**Resource Loading Optimization:**
```php
// Load specific domains only
$translator->getCatalogue('fr')->getDomains();  // Get available domains
```

### Common Patterns

**Domain-Specific Translations:**
- `messages`: General application messages
- `validators`: Form validation messages  
- `security`: Authentication/authorization messages
- `admin`: Admin interface messages

**Key Naming Strategies:**
- Dot notation: `user.profile.title`
- Descriptive keys: `button.save`, `error.invalid_email`
- Avoid spaces and special characters in keys

### Integration Points

**Form Integration:**
```php
$form = $this->createForm(UserType::class, $user, [
    'translation_domain' => 'forms'
]);
```

**Validation Messages:**
```php
use Symfony\Component\Validator\Constraints as Assert;

class User
{
    #[Assert\NotBlank(message: 'user.name.required')]
    private string $name;
}
```

**Event Integration:**
```php
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\RequestEvent;

class LocaleSubscriber implements EventSubscriberInterface
{
    public function onKernelRequest(RequestEvent $event): void
    {
        $request = $event->getRequest();
        if ($locale = $request->attributes->get('_locale')) {
            $request->getSession()->set('_locale', $locale);
        }
    }
}
```