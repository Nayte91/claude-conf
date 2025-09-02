## Header
- **Source**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/components/intl.rst
- **Processed Date**: 2025-09-01
- **Domain**: symfony.com
- **Version**: v7.3
- **Weight Reduction**: ~85%
- **Key Sections**: v7.3 Core Classes, API Methods, ICU Integration, Validation Patterns

## Body

### Symfony 7.3 Intl Installation

```bash
composer require symfony/intl
# Requires: PHP Intl extension with ICU library
```

### Symfony 7.3 Languages Class

```php
use Symfony\Component\Intl\Languages;

// v7.3 Languages API
$languages = Languages::getNames($locale = 'en');
$languages = Languages::getNames('fr');

$name = Languages::getName('fr');        // "French"
$name = Languages::getName('fr', 'fr');  // "français"

$alpha3 = Languages::getAlpha3Code('fr'); // "fra"
$alpha2 = Languages::getAlpha2Code('fra'); // "fr"

$exists = Languages::exists('fr');       // true
```

### Symfony 7.3 Countries Class

```php
use Symfony\Component\Intl\Countries;

// v7.3 Countries API
$countries = Countries::getNames($locale = 'en');

$name = Countries::getName('GB');        // "United Kingdom"
$name = Countries::getName('GB', 'fr');  // "Royaume-Uni"

$alpha3 = Countries::getAlpha3Code('GB'); // "GBR"
$numeric = Countries::getNumericCode('GB'); // "826"

$exists = Countries::exists('GB');       // true
```

### Symfony 7.3 Currencies Class

```php
use Symfony\Component\Intl\Currencies;

// v7.3 Currencies API
$currencies = Currencies::getNames($locale = 'en');

$name = Currencies::getName('USD');           // "US Dollar"
$symbol = Currencies::getSymbol('USD');       // "$"
$digits = Currencies::getFractionDigits('USD'); // 2

$exists = Currencies::exists('USD');          // true
```

### Symfony 7.3 Locales Class

```php
use Symfony\Component\Intl\Locales;

// v7.3 Locales API
$locales = Locales::getNames($locale = 'en');

$name = Locales::getName('fr_FR');       // "French (France)"
$name = Locales::getName('fr_FR', 'fr'); // "français (France)"

$exists = Locales::exists('fr_FR');      // true
```

### Symfony 7.3 Scripts Class

```php
use Symfony\Component\Intl\Scripts;

// v7.3 Scripts API
$scripts = Scripts::getNames($locale = 'en');

$name = Scripts::getName('Latn');        // "Latin"
$name = Scripts::getName('Cyrl', 'ru');  // "кириллица"

$exists = Scripts::exists('Latn');       // true
```

### Symfony 7.3 Timezones Class

```php
use Symfony\Component\Intl\Timezones;

// v7.3 Timezones API
$timezones = Timezones::getNames($locale = 'en');

$name = Timezones::getName('Europe/Paris');     // "Central European Time"
$offset = Timezones::getRawOffset('Europe/Paris'); // 3600 (seconds)
$gmt = Timezones::getGmtOffset('Europe/Paris');    // "GMT+01:00"

$countryTimezones = Timezones::forCountryCode('US');

$exists = Timezones::exists('Europe/Paris');    // true
```

### Symfony 7.3 Locale Management

```php
// v7.3 global locale configuration
\Locale::setDefault('en_US');

// All methods use default locale unless overridden
$languages = Languages::getNames(); // Uses 'en_US'
$languages = Languages::getNames('fr'); // Override to 'fr'
```

### Symfony 7.3 Form Integration

```php
use Symfony\Component\Form\Extension\Core\Type\ChoiceType;

// v7.3 form choices with Intl
$builder->add('country', ChoiceType::class, [
    'choices' => Countries::getNames($locale),
]);

$builder->add('language', ChoiceType::class, [
    'choices' => Languages::getNames($locale),
]);

$builder->add('currency', ChoiceType::class, [
    'choices' => Currencies::getNames($locale),
]);
```

### Symfony 7.3 Currency Display Pattern

```php
// v7.3 currency formatting helper
$currency = 'EUR';
$symbol = Currencies::getSymbol($currency);     // "€"
$name = Currencies::getName($currency, $locale); // "Euro"
$digits = Currencies::getFractionDigits($currency); // 2

$display = sprintf('%s %s (%s)', 
    $symbol, 
    number_format($amount, $digits), 
    $name
);
```

### Symfony 7.3 Validation Integration

```php
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\Validator\Context\ExecutionContextInterface;

// v7.3 custom validator using Intl
class ValidCountry extends Assert\Callback
{
    public function validate($value, ExecutionContextInterface $context)
    {
        if (!Countries::exists($value)) {
            $context->addViolation('Invalid country code');
        }
    }
}

class ValidCurrency extends Assert\Callback
{
    public function validate($value, ExecutionContextInterface $context)
    {
        if (!Currencies::exists($value)) {
            $context->addViolation('Invalid currency code');
        }
    }
}
```

### Symfony 7.3 Error Handling

```php
// v7.3 exception handling
try {
    $name = Countries::getName('INVALID');
} catch (\InvalidArgumentException $e) {
    // Handle invalid country code
}

// v7.3 existence checks
if (Currencies::exists($currencyCode)) {
    $symbol = Currencies::getSymbol($currencyCode);
}

if (Languages::exists($languageCode)) {
    $name = Languages::getName($languageCode, $locale);
}
```

### Symfony 7.3 Performance Optimization

```php
// v7.3 efficient single lookups
$countryName = Countries::getName('US');

// v7.3 avoid unnecessary bulk loading
// Less efficient for single lookups:
$allCountries = Countries::getNames();
$countryName = $allCountries['US'];
```

### Symfony 7.3 ICU Standards

- **Languages**: ISO 639-1/639-2 codes
- **Countries**: ISO 3166-1 codes (alpha-2, alpha-3, numeric)
- **Currencies**: ISO 4217 codes
- **Scripts**: ISO 15924 codes
- **Timezones**: IANA timezone database
- **Data Source**: ICU library with CLDR (Common Locale Data Repository)