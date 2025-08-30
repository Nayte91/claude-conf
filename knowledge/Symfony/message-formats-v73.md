# Symfony Message Formats v7.3 - Agent Reference

## Metadata
- **Source URL**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/reference/formats/message_format.rst
- **Processed Date**: 2025-08-29
- **Requesting Agent**: Documentation Chewer
- **Domain**: Translation/i18n
- **Version**: 7.3
- **Weight Reduction**: ~75% (specialized extraction)
- **Key Sections**: ICU MessageFormat, Complex Translations, Pluralization, Gender Selection

## ICU MessageFormat Overview

### Activation Requirements
- Translation files MUST use `+intl-icu` suffix
- Examples: `messages+intl-icu.en.yaml`, `validators+intl-icu.fr.xlf`
- Works with YAML, XLIFF, PHP formats

### Core Syntax Pattern
```
{variable_name, function_name, function_statement}
```

## Basic Placeholders

### Simple Variable Replacement
```yaml
# messages+intl-icu.en.yaml
welcome: 'Hello {name}!'
greeting: 'Welcome back, {username}!'
```

Usage:
```php
$translator->trans('welcome', ['name' => 'John']);
// Output: "Hello John!"
```

## Select Function (Conditional Messages)

### Gender-based Selection
```yaml
invitation_title: >-
    {organizer_gender, select,
        female   {{organizer_name} has invited you to her party!}
        male     {{organizer_name} has invited you to his party!}
        other    {{organizer_name} has invited you to their party!}
    }
```

### Status-based Selection
```yaml
user_status: >-
    {status, select,
        active   {User is currently online}
        inactive {User is away}
        offline  {User is not available}
        other    {Status unknown}
    }
```

**Key Rules:**
- `other` case is MANDATORY (fallback)
- Nested placeholders allowed within cases
- Case-sensitive matching

## Plural Function (Pluralization)

### Basic Pluralization
```yaml
num_of_apples: >-
    {apples, plural,
        =0    {There are no apples}
        =1    {There is one apple...}
        other {There are # apples!}
    }
```

### Complex Pluralization with Ranges
```yaml
file_count: >-
    {count, plural,
        =0    {No files}
        =1    {One file}
        =2    {A couple of files}
        few   {A few files}
        many  {Many files}
        other {# files}
    }
```

**Plural Categories (locale-dependent):**
- `zero` - Some languages (Arabic, Latvian)
- `one` - Singular form
- `two` - Dual form (Arabic, Welsh)
- `few` - Small quantities (Polish, Russian)
- `many` - Large quantities (Polish, Russian)
- `other` - Default/fallback (MANDATORY)

**Special Values:**
- `#` - Placeholder for actual number
- `=0`, `=1`, `=2` - Exact number matching

## Ordinal Function

### Ordinal Number Formatting
```yaml
position: >-
    {pos, ordinal,
        one   {#st position}
        two   {#nd position}  
        few   {#rd position}
        other {#th position}
    }
```

Usage:
```php
$translator->trans('position', ['pos' => 1]);  // "1st position"
$translator->trans('position', ['pos' => 22]); // "22nd position"
```

## Date/Time Formatting

### Date Formatting
```yaml
last_login: 'Last login: {date, date, short}'
full_date: 'Created on {date, date, full}'
```

**Date Styles:**
- `short` - 12/13/52
- `medium` - Jan 12, 1952
- `long` - January 12, 1952
- `full` - Tuesday, January 12, 1952

### Time Formatting
```yaml
current_time: 'Current time: {time, time, medium}'
```

**Time Styles:**
- `short` - 3:30 PM
- `medium` - 3:30:32 PM
- `long` - 3:30:32 PM PST
- `full` - 3:30:42 PM PST

### Combined Date/Time
```yaml
timestamp: 'Event at {datetime, date, medium} {datetime, time, short}'
```

## Number Formatting

### Currency Formatting
```yaml
price: 'Total cost: {amount, number, currency}'
```

### Percentage Formatting
```yaml
progress: 'Progress: {percent, number, percent}'
```

### Integer Formatting
```yaml
count: 'Items: {items, number, integer}'
```

## Complex Nested Examples

### Gender + Pluralization
```yaml
party_invitation: >-
    {organizer_gender, select,
        female {{guest_count, plural,
            =0    {{organizer_name} hasn't invited anyone to her party}
            =1    {{organizer_name} has invited one person to her party}
            other {{organizer_name} has invited # people to her party}
        }}
        male {{guest_count, plural,
            =0    {{organizer_name} hasn't invited anyone to his party}
            =1    {{organizer_name} has invited one person to his party}
            other {{organizer_name} has invited # people to his party}
        }}
        other {{guest_count, plural,
            =0    {{organizer_name} hasn't invited anyone to their party}
            =1    {{organizer_name} has invited one person to their party}
            other {{organizer_name} has invited # people to their party}
        }}
    }
```

### Multi-variable Selection
```yaml
notification: >-
    {type, select,
        email {{count, plural,
            =1    {You have one new email}
            other {You have # new emails}
        }}
        message {{count, plural,
            =1    {You have one new message}
            other {You have # new messages}
        }}
        other {{count, plural,
            =1    {You have one new notification}
            other {You have # new notifications}
        }}
    }
```

## Implementation Guidelines

### File Structure
```
translations/
├── messages+intl-icu.en.yaml     # ICU format
├── messages+intl-icu.fr.yaml
├── messages.en.yaml              # Standard format (fallback)
└── messages.fr.yaml
```

### PHP Usage
```php
// Standard usage
$message = $translator->trans('num_of_apples', [
    'apples' => 5
]);

// With domain
$message = $translator->trans('party_invitation', [
    'organizer_gender' => 'female',
    'organizer_name' => 'Alice',
    'guest_count' => 3
], 'messages');

// TranslatableMessage (recommended)
$message = new TranslatableMessage('num_of_apples', ['apples' => 0]);
```

### Twig Templates
```twig
{# ICU format automatically detected #}
{{ 'num_of_apples'|trans({'apples': apple_count}) }}

{# Complex parameters #}
{{ 'party_invitation'|trans({
    'organizer_gender': user.gender,
    'organizer_name': user.name,
    'guest_count': guests|length
}) }}
```

## Performance Considerations

### ICU vs Standard Format
- ICU: Requires additional parsing, slower
- Standard: Direct key-value lookup, faster
- Use ICU only when complex logic needed

### Caching Behavior
- ICU messages are cached after first parse
- Format validation occurs during cache warming
- Use `cache:clear` after format changes

## Debugging & Validation

### Common Errors
1. **Missing `other` case**: Always required in select/plural
2. **Unbalanced braces**: `{variable, select, case{message}`
3. **Invalid function names**: Only `select`, `plural`, `ordinal`, `date`, `time`, `number` supported
4. **Case sensitivity**: Function names and cases are case-sensitive

### Debug Commands
```bash
# Validate ICU format syntax
php bin/console lint:translations

# Extract ICU messages
php bin/console translation:extract --format=+intl-icu fr

# Debug specific domain with ICU
php bin/console debug:translation fr --domain=messages
```

## Migration from Standard Format

### Conversion Process
1. Rename files: `messages.en.yaml` → `messages+intl-icu.en.yaml`
2. Convert choice format to plural format
3. Test all message variations
4. Update extraction commands

### Choice to Plural Migration
```yaml
# OLD (choice format)
apples: '{0} no apples|{1} one apple|]1,Inf[ %count% apples'

# NEW (ICU plural format)  
apples: >-
    {count, plural,
        =0    {no apples}
        =1    {one apple}
        other {# apples}
    }
```

## Cross-References
- Related Knowledge: `/home/nayte/.claude/knowledge/Symfony/translation-v73.md`
- Agent Applications: i18n-expert, symfony-developer
- Update Schedule: Re-process with major Symfony releases

## Integration Points
- **Forms**: Validation message formatting
- **Validators**: Complex constraint messages  
- **Templates**: Dynamic content presentation
- **APIs**: Localized error messages
- **Security**: Multi-language authentication flows