## Header
- **Source URL**: https://getrector.com/documentation
- **Processed Date**: 2025-01-25
- **Domain**: getrector.com
- **Version**: Latest
- **Weight Reduction**: ~41%
- **Key Sections**: Installation, Configuration, Command Usage, Rule Sets, Workflow

## Body

### Technical Overview
- **Requirements**: PHP 7.2+
- **Target Compatibility**: PHP 5.x to 8.x code
- **Optimal Usage**: OOP, typed code, separated PHP/template layers
- **Purpose**: Automated code refactoring and modernization

### Installation

#### Composer Installation
```bash
composer require rector/rector --dev
```

#### Verification
```bash
vendor/bin/rector --version
```

### Basic Configuration

#### Configuration File: `rector.php`
```php
use Rector\Config\RectorConfig;
use Rector\Set\ValueObject\SetList;

return RectorConfig::configure()
    ->withPaths([
        __DIR__ . '/src',
        __DIR__ . '/tests',
    ])
    ->withPreparedSets(deadCode: true);
```

#### Path Configuration
```php
->withPaths([
    __DIR__ . '/src',
    __DIR__ . '/tests',
    __DIR__ . '/config',
])
```

#### Skip Patterns
```php
->withSkip([
    __DIR__ . '/src/legacy',
    __DIR__ . '/vendor',
])
```

### Command Usage

#### Preview Changes (Dry Run)
```bash
vendor/bin/rector process --dry-run
```

#### Apply Changes
```bash
vendor/bin/rector process
```

#### Process Specific Paths
```bash
vendor/bin/rector process src/
vendor/bin/rector process src/Controller/
```

#### Generate Configuration
```bash
vendor/bin/rector  # Interactive configuration generation
```

### Rule Sets and Configuration

#### Prepared Sets
```php
->withPreparedSets(
    deadCode: true,           // Remove dead code
    codeQuality: true,        // Improve code quality
    codingStyle: true,        // Apply coding standards
    typeDeclarations: true,   // Add type declarations
    privatization: true,      // Make properties/methods private
    naming: true,             // Improve naming
    instanceOf: true,         // Optimize instanceof checks
    earlyReturn: true,        // Apply early return pattern
    strictBooleans: true      // Enforce strict boolean comparisons
)
```

#### PHP Version Sets
```php
->withSets([
    SetList::PHP_74,
    SetList::PHP_80,
    SetList::PHP_81,
    SetList::PHP_82,
    SetList::PHP_83,
])
```

#### Framework-Specific Sets
```php
->withSets([
    SetList::SYMFONY_60,
    SetList::SYMFONY_61,
    SetList::SYMFONY_62,
    SetList::SYMFONY_63,
    SetList::SYMFONY_64,
])
```

### Advanced Configuration

#### Custom Rules
```php
->withRules([
    RemoveUnusedVariableRule::class,
    SimplifyIfReturnBoolRule::class,
])
```

#### Import Names
```php
->withImportNames(
    importNames: true,
    importDocBlockNames: true,
)
```

#### Parallel Processing
```php
->withParallel(
    maxNumberOfProcess: 4
)
```

### Output and Reporting

#### Verbose Output
```bash
vendor/bin/rector process --dry-run --verbose
```

#### Debug Mode
```bash
vendor/bin/rector process --dry-run --debug
```

#### Memory Limit
```bash
php -d memory_limit=2G vendor/bin/rector process
```

### Workflow Best Practices

#### Recommended Process
1. **Install** via Composer in development
2. **Generate/customize** `rector.php` configuration
3. **Preview changes** with `--dry-run`
4. **Review changes** carefully
5. **Apply transformations** incrementally
6. **Test thoroughly** after each application

#### CI/CD Integration
```bash
# Check for needed changes
vendor/bin/rector process --dry-run --output-format json

# Apply in CI (not recommended for production)
vendor/bin/rector process
```

### Configuration Examples

#### Minimal Configuration
```php
use Rector\Config\RectorConfig;

return RectorConfig::configure()
    ->withPaths([__DIR__ . '/src'])
    ->withPreparedSets(deadCode: true);
```

#### Advanced Configuration
```php
use Rector\Config\RectorConfig;
use Rector\Set\ValueObject\SetList;
use Rector\TypeDeclaration\Rector\ClassMethod\AddVoidReturnTypeWhereNoReturn;

return RectorConfig::configure()
    ->withPaths([
        __DIR__ . '/src',
        __DIR__ . '/tests',
    ])
    ->withSkip([
        __DIR__ . '/src/Legacy',
        AddVoidReturnTypeWhereNoReturn::class => [
            __DIR__ . '/src/EventSubscriber',
        ],
    ])
    ->withSets([
        SetList::PHP_82,
        SetList::DEAD_CODE,
        SetList::CODE_QUALITY,
    ])
    ->withImportNames()
    ->withParallel();
```

### Key Features

#### Automated Transformations
- **Dead code removal**
- **Type declaration additions**
- **Code quality improvements**
- **Modern PHP feature adoption**
- **Framework-specific optimizations**

#### Safety Features
- **Dry-run mode** for preview
- **Incremental processing**
- **Configurable skip patterns**
- **Rollback capability** via version control

### Performance Considerations

#### Optimization Strategies
- **Use parallel processing** for large codebases
- **Process specific paths** rather than entire project
- **Increase memory limit** for large files
- **Run incrementally** for better control

#### Memory Management
```bash
# Increase memory for large projects
php -d memory_limit=4G vendor/bin/rector process
```

### Troubleshooting

#### Common Issues
- **Memory exhaustion** - Increase PHP memory limit
- **Time limits** - Process in smaller batches
- **Parse errors** - Fix syntax issues first
- **Autoloading** - Ensure proper Composer autoload

#### Debug Commands
```bash
# Detailed output
vendor/bin/rector process --dry-run --debug

# Memory usage tracking
vendor/bin/rector process --dry-run --memory-limit 1G
```