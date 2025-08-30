## Header
- **Source URL**: https://phpstan.org/config-reference
- **Processed Date**: 2025-01-25
- **Domain**: phpstan.org
- **Version**: Latest
- **Weight Reduction**: ~44%
- **Key Sections**: Configuration, Rule Levels, File Analysis, Parallel Processing, Advanced Options

## Body

### Technical Overview
- **Purpose**: Static code analysis for PHP
- **Capabilities**: Finds bugs without writing tests, analyzes rarely executed code paths
- **Integration**: Supports gradual adoption through rule levels
- **Extensions**: Framework-specific support (Symfony, Laravel, Doctrine)

### Configuration File Format

#### Configuration Priority Order
1. **Explicitly provided** config file
2. **`phpstan.neon`**
3. **`phpstan.neon.dist`**
4. **`phpstan.dist.neon`**

#### NEON Format (YAML-like)
```neon
parameters:
    level: 6
    paths:
        - src
        - tests
```

### Core Configuration Parameters

#### File Analysis Configuration
```neon
parameters:
    paths:
        - src
        - tests
        - config
    excludePaths:
        analyse:
            - src/thirdparty
            - src/legacy
    fileExtensions:
        - php
        - module
        - inc
```

#### Rule Levels (0-9)
```neon
parameters:
    level: 6  # 0=basic, 9=strict
    customRulesetUsed: true
```

**Rule Level Progression**:
- **Level 0**: Basic undefined variables/functions
- **Level 1**: Unknown methods, accessing undefined properties  
- **Level 2**: Unknown methods on all expressions
- **Level 3**: Return types, types assigned to properties
- **Level 4**: Basic dead code checking
- **Level 5**: Checking types of arguments passed to methods
- **Level 6**: Missing typehints
- **Level 7**: Partially wrong union types  
- **Level 8**: Calling methods on nullable types
- **Level 9**: Strict arrays, strings, numeric operations

### Parallel Processing Configuration

```neon
parameters:
    parallel:
        jobSize: 20                    # Files per job
        maximumNumberOfProcesses: 32   # Max parallel processes
        processTimeout: 900.0          # Timeout in seconds
        buffer: 134217728              # Memory buffer
```

### Advanced Analysis Options

#### Strictness Controls
```neon
parameters:
    checkDynamicProperties: false
    checkUninitializedProperties: false
    reportMaybesInMethodSignatures: false
    checkBenevolentUnionTypes: false
    checkImplicitMixed: false
    checkFunctionNameCase: false
```

#### PHP Version Configuration
```neon
parameters:
    phpVersion: 80103  # PHP 8.1.3
    # OR range:
    phpVersion:
        min: 80103
        max: 80304
```

#### Temporary Directory
```neon
parameters:
    tmpDir: %env.PHPSTAN_TMP_DIR%
    # OR absolute path:
    tmpDir: /tmp/phpstan
```

### Type Discovery Configuration

#### Additional Symbol Files
```neon
parameters:
    scanFiles:
        - additional_symbols.php
        - bootstrap/constants.php
```

#### Universal Object Crates
```neon
parameters:
    universalObjectCratesClasses:
        - Dibi\Row
        - stdClass
```

#### Dynamic Constants
```neon
parameters:
    dynamicConstantNames:
        - DATABASE_ENGINE
        - CONFIG_CACHE_ENABLED
```

### Error Handling and Ignoring

#### Ignore Patterns
```neon
parameters:
    ignoreErrors:
        - '/Parameter #1 \$x of function foo expects int, string given\./'
        - 
            message: '/Access to an undefined property/'
            path: 'src/legacy/*'
```

#### Baseline File
```neon
parameters:
    baseline: phpstan-baseline.neon
```

### Command-Line Usage

#### Basic Analysis
```bash
vendor/bin/phpstan analyse src tests
```

#### With Configuration
```bash
vendor/bin/phpstan analyse -c phpstan.neon
```

#### Level Override
```bash
vendor/bin/phpstan analyse --level 8 src
```

#### Memory Limit
```bash
php -d memory_limit=2G vendor/bin/phpstan analyse
```

#### Generate Baseline
```bash
vendor/bin/phpstan analyse --generate-baseline
```

### Extension Configuration

#### Include Extensions
```neon
includes:
    - vendor/phpstan/phpstan-symfony/extension.neon
    - vendor/phpstan/phpstan-doctrine/extension.neon
```

#### Custom Rules
```neon
rules:
    - App\PHPStan\NoEchoRule
    - App\PHPStan\NoVarDumpRule
```

### Environment-Specific Configuration

#### Environment Variables
```neon
parameters:
    tmpDir: %env.PHPSTAN_TMP_DIR%
    level: %env.PHPSTAN_LEVEL%
```

#### Conditional Configuration
```neon
parameters:
    checkDynamicProperties: %env.bool(STRICT_MODE)
```

### Advanced Features

#### Container Configuration
```neon
services:
    -
        class: App\PHPStan\MyExtension
        tags:
            - phpstan.rules.rule
```

#### Custom Parameter Schema
```neon
parametersSchema:
    myCustomParameter: structure([
        foo: string()
        bar: int()
    ])
```

### Performance Optimization

#### Analysis Performance
```neon
parameters:
    parallel:
        maximumNumberOfProcesses: %env.int(PHPSTAN_PARALLEL_PROCESSES)
    cache:
        nodesByFileCountMax: 1024
        nodesByStringCountMax: 512
```

#### Memory Management
```neon
parameters:
    memoryLimitFile: .phpstan-memory-limit
```

### Integration Patterns

#### CI/CD Configuration
```yaml
# GitHub Actions example
- name: PHPStan
  run: |
    php -d memory_limit=1G vendor/bin/phpstan analyse \
      --error-format=github \
      --no-progress
```

#### Make Integration
```makefile
phpstan:
	php -d memory_limit=2G vendor/bin/phpstan analyse
```

### Output Formats

#### Available Formats
- **table** (default) - Human-readable table
- **raw** - Machine-readable format  
- **json** - JSON output for parsing
- **junit** - JUnit XML format
- **github** - GitHub Actions annotations

```bash
vendor/bin/phpstan analyse --error-format=json
```

### Best Practices

#### Configuration Strategy
- **Start with level 0** and gradually increase
- **Use baseline** for legacy codebases
- **Configure excludePaths** for third-party code
- **Leverage parallel processing** for large projects

#### Performance Recommendations  
- **Set appropriate memory limits**
- **Use tmpDir** on fast storage
- **Configure parallel processing** based on CPU cores
- **Exclude vendor directories** from analysis