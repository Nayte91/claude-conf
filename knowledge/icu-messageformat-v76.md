# ICU MessageFormat v76 - Agent Reference

## Metadata
- **Source URL**: https://raw.githubusercontent.com/unicode-org/icu/refs/heads/main/docs/userguide/format_parse/messages/index.md
- **Processed Date**: 2025-08-29
- **Requesting Agent**: Documentation Chewer
- **Domain**: Internationalization/Unicode
- **Version**: 76 (ICU current)
- **Weight Reduction**: ~65% (core technical extraction)
- **Key Sections**: MessageFormat Core, Argument Types, Formatting Rules, Escaping Syntax

## Core MessageFormat Specification

### Message Structure
```
{argument_name, function, parameters}
```

**Essential Components**:
- `argument_name`: Variable placeholder identifier  
- `function`: Processing directive (plural, select, date, time, number)
- `parameters`: Function-specific configuration

### Basic Variable Substitution
```
Simple: "Hello {name}!"
Complex: "At {time,time,short} on {date,date,medium}, {event}"
```

## Argument Functions

### 1. Select Function (Conditional Logic)
```
{gender, select,
    male    {He will respond soon.}
    female  {She will respond soon.} 
    other   {They will respond soon.}
}
```

**Requirements**:
- `other` case MANDATORY (fallback)
- Cases are literal string matches
- Case-sensitive matching

### 2. Plural Function (Quantification Logic)
```
{count, plural,
    =0      {no items}
    =1      {one item}
    few     {few items}  
    many    {many items}
    other   {# items}
}
```

**Plural Categories (CLDR-based)**:
- `zero` - Languages like Arabic, Latvian
- `one` - Singular forms
- `two` - Dual forms (Arabic, Welsh)
- `few` - Small quantities (Slavic languages)
- `many` - Large quantities (Slavic languages)  
- `other` - Default case (MANDATORY)

**Special Symbols**:
- `#` - Substitutes actual numeric value
- `=0`, `=1`, `=2` - Exact numeric matches override rules

### 3. Date/Time Formatting
```
Date: {timestamp, date, short}    // 12/13/52
Time: {timestamp, time, medium}   // 3:30:32 PM
```

**Predefined Styles**:
- `short` - Minimal representation
- `medium` - Standard representation
- `long` - Extended representation  
- `full` - Complete representation

### 4. Number Formatting
```
Currency: {price, number, currency}     // $123.45
Percent:  {ratio, number, percent}      // 75%
Integer:  {count, number, integer}      // 1,234
```

### 5. Ordinal Function
```
{position, ordinal,
    one   {#st}
    two   {#nd}  
    few   {#rd}
    other {#th}
}
```

## Advanced Formatting Methods

### Skeleton Patterns (Recommended)
```
Date: {date, date, ::dMMMM}        // 13 January
Time: {time, time, ::jmm}          // 3:30 PM
```

**Skeleton Benefits**:
- Locale-independent specification
- Precise formatting control
- Future-compatible syntax

### Pre-formatting Strategy (Optimal)
```cpp
// Format externally, pass as strings
Formattable args[] = {preformattedDate, preformattedNumber};
MessageFormat::format("Event: {0} - Count: {1}", args, 2, result, err);
```

## Quoting and Escaping Rules

### Syntax Character Escaping
```
Literal brace: "Use '{' character here"
Apostrophe: "Don''t use '' for contractions"  
Real apostrophe: "Don't use " (U+2019 recommended)
```

**Escape Sequences**:
- Single `'` quotes next character literally
- Double `''` represents one literal apostrophe
- Only `{` and `}` require quoting within messages

### ICU Version Considerations
- **ICU 4.8+**: Improved apostrophe handling
- **Pre-4.8**: More restrictive quoting rules
- **Recommendation**: Use real apostrophe (U+2019) for user text

## Complex Message Patterns

### Nested Arguments (Discouraged)
```
{gender, select,
    male {{count, plural,
        =1    {He has one item}
        other {He has # items}
    }}
    female {{count, plural, 
        =1    {She has one item}
        other {She has # items}
    }}
    other {{count, plural,
        =1    {They have one item} 
        other {They have # items}
    }}
}
```

### Recommended Pattern
```
// Separate messages per gender
male_items: {count, plural, =1 {He has one item} other {He has # items}}
female_items: {count, plural, =1 {She has one item} other {She has # items}}
other_items: {count, plural, =1 {They have one item} other {They have # items}}

// Select gender message
{gender, select, male {male_items} female {female_items} other {other_items}}
```

## Implementation Architecture

### C++ API Example
```cpp
#include "unicode/msgfmt.h"

UErrorCode err = U_ZERO_ERROR;
MessageFormat fmt("{0,number,integer} files", Locale::getUS(), err);

Formattable args[] = {(int32_t)1273};
UnicodeString result;
fmt.format(args, 1, result, err);
```

### Performance Considerations
- **Parsing Cost**: Complex messages require pattern compilation
- **Caching Strategy**: Compile patterns once, reuse instances
- **Argument Processing**: Pre-format complex data types
- **Memory Usage**: Pattern trees consume memory proportional to complexity

## Error Handling Patterns

### Common Parse Errors
1. **Unbalanced Braces**: `{name, select, case message}`
2. **Missing Other Case**: Required for select/plural functions  
3. **Invalid Function Names**: Only predefined functions supported
4. **Malformed Syntax**: Strict adherence to grammar required

### Runtime Error Categories
- **Argument Mismatch**: Supplied args don't match pattern requirements
- **Format Failures**: Invalid data for specified formatting
- **Locale Issues**: Unsupported locale-specific operations

## Migration and Compatibility

### MessageFormat 2.0 (In Development)
- **Status**: CLDR Technical Committee specification
- **Timeline**: Future ICU versions
- **Compatibility**: Migration path planned
- **Current**: Continue with MessageFormat 1.0 syntax

### Legacy Choice Format
```
// DEPRECATED: Choice format
{count, choice, 0#no files|1#one file|1<{count} files}

// PREFERRED: Plural format  
{count, plural, =0{no files} =1{one file} other{# files}}
```

## Best Practices for Agents

### Message Design Principles
1. **Full Sentences**: Write complete sentences in sub-messages
2. **Outermost Structure**: Place select arguments outside plurals
3. **Argument Minimization**: Reduce parameter complexity
4. **Locale Awareness**: Consider target language plural rules

### Development Guidelines
1. **Pattern Validation**: Test all argument combinations
2. **Locale Testing**: Verify behavior across target locales  
3. **Performance Profiling**: Monitor parsing and formatting costs
4. **Error Boundaries**: Implement graceful degradation

## Cross-References
- **Related Knowledge**: `/home/nayte/.claude/knowledge/Symfony/message-formats-v73.md`
- **Agent Applications**: i18n systems, multilingual applications, localization tools
- **Update Schedule**: Monitor ICU major releases, MessageFormat 2.0 development

## Integration Points
- **C++/Java**: Native ICU library implementations
- **JavaScript**: Intl.MessageFormat polyfills  
- **Python**: PyICU bindings
- **PHP**: intl extension (Symfony Integration)
- **Web Frameworks**: Framework-specific adaptations (Rails, Django, etc.)