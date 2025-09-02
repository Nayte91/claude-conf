## Header
- **Source**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/reference/formats/message_format.rst
- **Processed Date**: 2025-01-25
- **Domain**: symfony/symfony-docs
- **Version**: v73
- **Weight Reduction**: ~75%
- **Key Sections**: ICU MessageFormat, Complex Translations, Pluralization, Gender Selection, Date/Time Formatting, Number Formatting

## Body

### Symfony 7.3 ICU MessageFormat Implementation

#### File Naming Convention
- **Required suffix**: `+intl-icu` (e.g., `messages+intl-icu.en.yaml`)
- **Supported formats**: YAML, XLIFF, PHP only
- **Fallback compatibility**: Maintains standard format files

#### ICU Syntax Structure
```
{variable_name, function_type, function_statement}
```

#### Supported Function Types (Symfony 7.3)
- **select**: Conditional message selection
- **plural**: Pluralization with locale rules
- **ordinal**: Ordinal number formatting (1st, 2nd, 3rd)
- **date**: Date formatting with styles
- **time**: Time formatting with styles  
- **number**: Number/currency/percentage formatting

### Select Function Patterns

```yaml
status_message: >-
    {type, select,
        error   {Critical system error}
        warning {System warning}
        info    {Information message}
        other   {Unknown message type}
    }
```

**Technical Requirements**:
- `other` case mandatory (fallback)
- Case-sensitive matching
- Nested placeholder support

### Plural Function Implementation

```yaml
item_count: >-
    {count, plural,
        =0    {No items}
        =1    {One item}
        other {# items}
    }
```

**Symfony 7.3 Plural Categories**:
- **Exact matches**: `=0`, `=1`, `=2`
- **CLDR categories**: `zero`, `one`, `two`, `few`, `many`, `other`
- **Number placeholder**: `#` (renders actual count)

### Date/Time Formatting Styles

```yaml
# Date styles
event_date: 'Event: {date, date, full}'    # Tuesday, January 12, 1952
short_date: 'Due: {date, date, short}'     # 12/13/52

# Time styles  
meeting_time: 'At: {time, time, medium}'   # 3:30:32 PM
```

**Available Styles**: `short`, `medium`, `long`, `full`

### Number Formatting Types

```yaml
price: 'Cost: {amount, number, currency}'
progress: 'Done: {percent, number, percent}'
total: 'Count: {items, number, integer}'
```

### PHP Integration (Symfony 7.3)

```php
// TranslatableMessage (recommended)
$message = new TranslatableMessage('item_count', ['count' => 5]);

// Direct translator usage
$translator->trans('status_message', ['type' => 'error'], 'messages');
```

### Twig Integration

```twig
{{ 'item_count'|trans({'count': items|length}) }}
```

### Performance Characteristics

- **ICU parsing overhead**: ~15-20% vs standard format
- **Cache behavior**: Parsed messages cached after first use
- **Memory usage**: Higher due to AST parsing
- **Recommendation**: Use only for complex pluralization/selection

### Symfony 7.3 Commands

```bash
# Syntax validation
php bin/console lint:translations

# ICU format extraction
php bin/console translation:extract --format=+intl-icu [locale]

# Debug ICU messages
php bin/console debug:translation [locale] --domain=messages
```

### Migration from Choice Format

```yaml
# Legacy Symfony choice format
old_format: '{0} no items|{1} one item|]1,Inf[ %count% items'

# Symfony 7.3 ICU plural format
new_format: >-
    {count, plural,
        =0    {no items}
        =1    {one item}
        other {# items}
    }
```

### Common Implementation Errors

1. **Missing `other` case** in select/plural functions
2. **Unbalanced braces** in message syntax
3. **Invalid function names** (only 6 types supported)
4. **Case sensitivity** in function names and cases

### File Structure Requirements

```
translations/
├── messages+intl-icu.en.yaml     # ICU format (primary)
├── messages.en.yaml              # Fallback format
└── validators+intl-icu.en.yaml   # Domain-specific ICU
```