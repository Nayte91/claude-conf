# Symfony Intl Component v73 - Agent Reference

## Metadata
- **Source URL**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/components/intl.rst
- **Processed Date**: 2025-08-29
- **Requesting Agent**: Documentation Chewer
- **Domain**: Symfony/Internationalization
- **Version**: 7.3
- **Weight Reduction**: ~70% (core technical extraction)
- **Key Sections**: Core Classes, Locale Data Access, ICU Integration, Practical Usage

## Installation & Requirements

```bash
composer require symfony/intl
```

**Dependencies**: PHP Intl extension with ICU library

## Core Classes & Capabilities

### 1. Languages Class
```php
use Symfony\Component\Intl\Languages;

// Get all language names for locale
$languages = Languages::getNames($locale = 'en');
$languages = Languages::getNames('fr'); // Returns French language names

// Get specific language name
$name = Languages::getName('fr');        // "French"
$name = Languages::getName('fr', 'fr');  // "français"

// Code conversion
$alpha3 = Languages::getAlpha3Code('fr'); // "fra"
$alpha2 = Languages::getAlpha2Code('fra'); // "fr"

// Validation
$exists = Languages::exists('fr');       // true
```

### 2. Countries Class
```php
use Symfony\Component\Intl\Countries;

// Get all country names
$countries = Countries::getNames($locale = 'en');

// Get specific country name  
$name = Countries::getName('GB');        // "United Kingdom"
$name = Countries::getName('GB', 'fr');  // "Royaume-Uni"

// Code conversion
$alpha3 = Countries::getAlpha3Code('GB'); // "GBR"
$numeric = Countries::getNumericCode('GB'); // "826"

// Validation
$exists = Countries::exists('GB');       // true
```

### 3. Currencies Class
```php
use Symfony\Component\Intl\Currencies;

// Get all currency names
$currencies = Currencies::getNames($locale = 'en');

// Get currency details
$name = Currencies::getName('USD');           // "US Dollar"
$symbol = Currencies::getSymbol('USD');       // "$"
$digits = Currencies::getFractionDigits('USD'); // 2

// Validation
$exists = Currencies::exists('USD');          // true
```

### 4. Locales Class
```php
use Symfony\Component\Intl\Locales;

// Get all locale names
$locales = Locales::getNames($locale = 'en');

// Get specific locale name
$name = Locales::getName('fr_FR');       // "French (France)"
$name = Locales::getName('fr_FR', 'fr'); // "français (France)"

// Validation
$exists = Locales::exists('fr_FR');      // true
```

### 5. Scripts Class
```php
use Symfony\Component\Intl\Scripts;

// Get all script names
$scripts = Scripts::getNames($locale = 'en');

// Get specific script name
$name = Scripts::getName('Latn');        // "Latin"
$name = Scripts::getName('Cyrl', 'ru');  // "кириллица"

// Validation
$exists = Scripts::exists('Latn');       // true
```

### 6. Timezones Class
```php
use Symfony\Component\Intl\Timezones;

// Get all timezone names
$timezones = Timezones::getNames($locale = 'en');

// Get specific timezone details
$name = Timezones::getName('Europe/Paris');     // "Central European Time"
$offset = Timezones::getRawOffset('Europe/Paris'); // 3600 (seconds)
$gmt = Timezones::getGmtOffset('Europe/Paris');    // "GMT+01:00"

// Country timezones
$countryTimezones = Timezones::forCountryCode('US');

// Validation
$exists = Timezones::exists('Europe/Paris');    // true
```

## Locale Handling

### Default Locale Configuration
```php
// Set default locale globally
\Locale::setDefault('en_US');

// All methods will use this locale unless overridden
$languages = Languages::getNames(); // Uses 'en_US'
$languages = Languages::getNames('fr'); // Override to 'fr'
```

### Locale Fallback Chain
```php
// Symfony follows ICU locale fallback rules:
// 'en_US_POSIX' → 'en_US' → 'en' → root locale
```

## ICU Data Integration

### Data Source
- Uses ICU library data (version-specific)
- Data includes CLDR (Common Locale Data Repository)
- Automatically updated with ICU releases

### Data Coverage
```php
// Supported data types:
// - Language codes (ISO 639-1/2)  
// - Country codes (ISO 3166-1)
// - Currency codes (ISO 4217)
// - Script codes (ISO 15924)
// - Timezone identifiers (IANA)
```

## Practical Usage Patterns

### 1. Locale-Aware Forms
```php
use Symfony\Component\Intl\Countries;
use Symfony\Component\Intl\Languages;

// Country dropdown
$countries = Countries::getNames($request->getLocale());

// Language selector
$languages = Languages::getNames($request->getLocale());
```

### 2. Currency Display
```php
use Symfony\Component\Intl\Currencies;

$currency = 'EUR';
$symbol = Currencies::getSymbol($currency);     // "€"
$name = Currencies::getName($currency, $locale); // "Euro"
$digits = Currencies::getFractionDigits($currency); // 2

// Format: "€ 123.45 (Euro)"
$display = sprintf('%s %s (%s)', 
    $symbol, 
    number_format($amount, $digits), 
    $name
);
```

### 3. Multi-Language Data Display
```php
use Symfony\Component\Intl\Languages;

// Display user's language in their locale
$userLocale = $user->getLocale();
$displayLanguage = Languages::getName($userLocale, $userLocale);
```

### 4. Validation Integration
```php
use Symfony\Component\Intl\Countries;
use Symfony\Component\Validator\Constraints as Assert;

// Custom constraint using Intl data
class ValidCountry extends Assert\Callback
{
    public function validate($value, ExecutionContextInterface $context)
    {
        if (!Countries::exists($value)) {
            $context->addViolation('Invalid country code');
        }
    }
}
```

## Integration Points

### With Translation Component
```php
// Intl provides locale data, Translation handles message formatting
// See: ~/.claude/knowledge/Symfony/translation-v73.md
```

### With ICU MessageFormat
```php
// Intl provides locale context for ICU MessageFormat patterns
// See: ~/.claude/knowledge/icu-messageformat-v76.md
```

### With Form Component
```php
// Intl data commonly used in ChoiceType fields
use Symfony\Component\Form\Extension\Core\Type\ChoiceType;

$builder->add('country', ChoiceType::class, [
    'choices' => Countries::getNames($locale),
]);
```

## Performance Considerations

### Data Caching
- ICU data is loaded on-demand
- Results should be cached for repeated access
- Consider using Symfony Cache component

### Memory Usage
```php
// Efficient: Get only needed data
$countryName = Countries::getName('US');

// Less efficient: Load all countries for single lookup  
$allCountries = Countries::getNames();
$countryName = $allCountries['US'];
```

## Error Handling

### Common Exceptions
```php
// Invalid locale/code handling
try {
    $name = Countries::getName('INVALID');
} catch (\InvalidArgumentException $e) {
    // Handle invalid country code
}

// Existence checks before access
if (Currencies::exists($currencyCode)) {
    $symbol = Currencies::getSymbol($currencyCode);
}
```

## Cross-References
- Related Knowledge: 
  - ~/.claude/knowledge/Symfony/translation-v73.md
  - ~/.claude/knowledge/icu-messageformat-v76.md
  - ~/.claude/knowledge/Symfony/message-formats-v73.md
- Agent Applications: Symfony internationalization, form building, data validation
- Update Schedule: Re-process with new Symfony major versions