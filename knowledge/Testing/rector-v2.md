## Header
- **Source**: https://getrector.com/documentation
- **Processed Date**: 2025-08-31
- **Domain**: getrector.com
- **Version**: v2
- **Weight Reduction**: 75%
- **Key Sections**: Installation, Configuration, Rule Management, Custom Development, Debugging, Team Integration

## Body

# Core Concepts

## What is Rector
Automated PHP code refactoring tool for modernizing and improving PHP codebases through rule-based transformations.

**Technical Specifications:**
- Minimum PHP Version: 7.2+
- Code Compatibility: Works with PHP 5.x, 8.x code
- Best Performance: OOP, typed code, separated PHP/template layers
- Architecture: Uses nikic/php-parser for AST manipulation

## Installation & Basic Usage

### Installation
```bash
composer require rector/rector --dev
```

### Basic Commands
```bash
# Preview changes
vendor/bin/rector process --dry-run

# Apply changes
vendor/bin/rector process

# Process specific file/directory
vendor/bin/rector process src/SingleFile.php
```

### Configuration File
Default: `rector.php` in project root
```php
return RectorConfig::configure()
    ->withPaths([
        __DIR__ . '/src',
        __DIR__ . '/tests',
    ])
    ->withPreparedSets(deadCode: true);
```

# Integration & Project Setup

## Integration Strategy
**Incremental Approach:**
1. Apply 1-3 safe rules initially
2. Create small, reviewable pull requests
3. Gradually increase rule complexity
4. Confirm each change before adding more rules

## PHP Version Upgrade Process
```php
return RectorConfig::configure()
    ->withPaths([__DIR__ . '/src', __DIR__ . '/tests'])
    ->withPhpSets(php53: true);  // Target specific version
```

**Best Practice:** Upgrade one PHP version at a time

# Path Configuration

## Path Definition Methods

### Configuration File
```php
RectorConfig::configure()
    ->withPaths([
        __DIR__ . '/src/SingleFile.php',
        __DIR__ . '/src/WholeDirectory',
    ]);
```

### Include Root Files
```php
RectorConfig::configure()
    ->withRootFiles();
```

### File Extensions
```php
RectorConfig::configure()
    ->withFileExtensions(['php', 'phtml']);
```

# Rule Sets & Configuration

## Prepared Sets
```php
RectorConfig::configure()
    ->withPreparedSets(
        deadCode: true,
        codeQuality: true,
        codingStyle: true,
        naming: true,
        privatization: true,
        typeDeclarations: true,
        rectorPreset: true
    )
```

## PHP Version Sets
```php
// Auto-detect from composer.json
->withPhpSets()

// Manual version specification
->withSets([SetList::PHP_73])
```

## Community/External Sets
```php
->withSets([
    DoctrineSetList::DOCTRINE_CODE_QUALITY,
    __DIR__.'/config/rector-custom-set.php'
])
```

## Composer-Based Sets
```php
return RectorConfig::configure()
    ->withComposerBased(
        twig: true, 
        doctrine: true, 
        phpunit: true, 
        symfony: true
    );
```

# Level-Based Configuration

## Level Configuration Syntax
```php
return RectorConfig::configure()
    ->withPaths([__DIR__ . '/src', __DIR__ . '/tests'])
    ->withTypeCoverageLevel(0)
    ->withDeadCodeLevel(0)
    ->withCodeQualityLevel(0)
    ->withCodingStyleLevel(0);
```

**Workflow:** Start with level 0, incrementally increase levels

# Attribute Migration

## Configuration
```php
return RectorConfig::configure()
    ->withAttributesSets();
```

## Selective Migration
```php
return RectorConfig::configure()
    ->withAttributesSets(symfony: true, doctrine: true);
```

**Transformation Example:**
```php
-/**
- * @ORM\Entity
- */
+#[ORM\Entity]
 class SomeEntity {}
```

# Rule Management

## Single Rule Execution
```bash
vendor/bin/rector --only="Rector\DeadCode\Rector\ClassMethod\RemoveUnusedPrivateMethodRector"
```

## Rule Ignoring
```php
RectorConfig::configure()
    ->withSkip([
        // Skip directories/files
        __DIR__ . '/src/SingleFile.php',
        __DIR__ . '/src/WholeDirectory',
        __DIR__ . '/src/*/Tests/*',
        
        // Skip specific rules globally
        SimplifyIfReturnBoolRector::class,
        
        // Skip rules in specific files
        SimplifyIfReturnBoolRector::class => [
            __DIR__ . '/src/ComplicatedFile.php',
        ],
    ]);
```

## Configured Rules
```php
return RectorConfig::configure()
    ->withConfiguredRule(RenameClassRector::class, [
        'App\SomeOldClass' => 'App\SomeNewClass',
    ]);
```

# Import Management

## Import Configuration
```php
RectorConfig::configure()
    ->withImportNames(
        importShortClasses: true,
        removeUnusedImports: false
    )
```

**Transformation Examples:**
```php
// Before
$object = new \App\Some\Namespace\SomeClass();

// After
use App\Some\Namespace\SomeClass;
$object = new SomeClass();
```

# Static Reflection & Autoload

## Configuration Options
```php
RectorConfig::configure()
    ->withAutoloadPaths([
        __DIR__ . '/file-with-functions.php',
        __DIR__ . '/project-without-composer'
    ]);
```

## Bootstrap Files
```php
RectorConfig::configure()
    ->withBootstrapFiles([
        __DIR__ . '/constants.php',
        __DIR__ . '/project/special/autoload.php'
    ]);
```

# Advanced Configuration

## PHP Version Detection
Rector determines PHP version from:
1. `composer.json` PHP requirement
2. PHP version in `rector.php`
3. Composer platform configuration  
4. Current PHP runtime version

## Force PHP Version
```php
return RectorConfig::configure()
    ->withPhpVersion(PhpVersion::PHP_80);
```

## Configuration File Options
```php
return RectorConfig::configure()
    ->withIndent(indentChar: ' ', indentSize: 4);
```

# CLI Commands

## List Rules
```bash
# List all loaded rules
vendor/bin/rector list-rules

# Specify config file
vendor/bin/rector list-rules --config config/other-rector.php

# JSON output
vendor/bin/rector list-rules --output-format json
```

## Setup CI
```bash
vendor/bin/rector setup-ci
```

## Generate Custom Rule
```bash
vendor/bin/rector custom-rule
composer dump-autoload  # Required after generation
```

# Caching & Performance

## CI Cache Configuration
```php
return RectorConfig::configure()
    ->withCache(
        cacheClass: FileCacheStorage::class,
        cacheDirectory: '/tmp/rector'
    );
```

## Parallel Processing
```php
return RectorConfig::configure()
    ->withParallel(120, 16, 10);  // timeout, processes, jobSize
```

**Configuration Parameters:**
- `seconds`: Timeout duration (default 120)
- `maxNumberOfProcess`: Max concurrent processes (default 16)
- `jobSize`: Processing batch size (default 16)

# Debugging & Troubleshooting

## Debugging Options
```bash
# Enable debug output
vendor/bin/rector process src/Controller --debug

# Xdebug support
vendor/bin/rector process src/Controller --dry-run --xdebug
```

## Parallel Processing Issues
**Troubleshooting:** Use `--debug` to disable parallel processing
**Configuration:** Adjust timeout, processes, or job size parameters

## Preload Issues
Add to `composer.json`:
```json
{
    "autoload-dev": {
        "files": [
            "vendor/rector/rector/preload.php"
        ]
    }
}
```

# Team Tools & Integration

## Recommended Complementary Tools
- **Easy Coding Standard:** Code formatting cleanup
- **PHPStan:** Static analysis for type understanding
- **tomasvotruba/type-coverage:** Type coverage analysis
- **tomasvotruba/class-leak:** Dead code detection

**PHPStan Integration:** Reach level 3-4 without baseline for optimal Rector performance

# Custom Rule Development

## Basic Rule Structure
```php
final class MyFirstRector extends AbstractRector
{
    public function getNodeTypes(): array 
    {
        return [MethodCall::class];
    }

    public function refactor(Node $node): ?Node 
    {
        // Transformation logic
        return $modifiedNode;
    }

    public function getRuleDefinition(): RuleDefinition 
    {
        return new RuleDefinition(
            'Description of what this rule does',
            [
                new CodeSample(
                    '// before code',
                    '// after code'
                )
            ]
        );
    }
}
```

## Rule Registration
1. Update `composer.json` autoload configuration
2. Register in `rector.php`:
```php
return RectorConfig::configure()
    ->withRules([
        MyFirstRector::class,
    ]);
```

## Testing Custom Rules

### Directory Structure
```
/tests
    /Rector
        /MyFirstRector
            /Fixture
                test_fixture.php.inc
            /config
                config.php
            MyFirstRectorTest.php
```

### Test Class
```php
final class MyFirstRectorTest extends AbstractRectorTestCase
{
    /**
     * @dataProvider provideData()
     */
    public function test(FilePath $filePath): void
    {
        $this->doTestFile($filePath);
    }

    public function provideData(): Iterator
    {
        return $this->gatherDataFromDirectory(__DIR__ . '/Fixture');
    }

    public function provideConfigFilePath(): string
    {
        return __DIR__ . '/config/config.php';
    }
}
```

### Test Fixture Format
```php
<?php
// Before code
$old = someOldMethod();
-----
<?php
// After code  
$new = someNewMethod();
```

## Custom Set Provider
```php
final class LaravelSetProvider implements SetProviderInterface
{
    public function provide(): array
    {
        return [
            new ComposerTriggeredSet(
                'laravel',
                'laravel/framework',
                '10.0',
                __DIR__ . '/../../config/sets/laravel10.php'
            )
        ];
    }
}
```

## Node Visitor Pattern
```php
class HelloVisitor extends NodeVisitorAbstract implements ScopeResolverNodeVisitorInterface
{
    public function enterNode(Node $node)
    {
        if (! $node instanceof Stmt) {
            return null;
        }

        $node->setAttribute(self::HELLO_ATTRIBUTE, 'i was here');
        return $node;
    }
}
```

**Registration:**
```php
return RectorConfig::configure()
    ->registerService(HelloVisitor::class, null, ScopeResolverNodeVisitorInterface::class);
```

# Rector Internal Architecture

## Processing Workflow
1. **File Discovery:** Find source files specified in configuration
2. **Rule Loading:** Load configured Rectors
3. **AST Parsing:** Parse files into Abstract Syntax Tree using nikic/php-parser
4. **Node Traversal:** Process nodes and apply transformations
5. **Output Generation:** Save changes or generate diffs

## Processing Lifecycle
```php
foreach ($fileInfos as $fileInfo) {
    $nodes = $phpParser->parse(file_get_contents($fileInfo->getRealPath()));
    
    foreach ($nodes as $node) {
        foreach ($rectors as $rector) {
            foreach ($rector->getNodeTypes() as $nodeType) {
                if (is_a($node, $nodeType, true)) {
                    $rector->refactor($node);
                }
            }
        }
    }
}
```

# Bug Reporting & Contribution

## Issue Reporting Process
1. Fork Rector source repository
2. Create minimal reproducible test case
3. Use `.php.inc` file extension for fixtures
4. Include unique PSR-4 namespace
5. Create pull request with test demonstrating issue

## Test Requirements
- Change Test: Show before/after transformation
- No-Change Test: Show code that should remain unchanged
- Validate with PHPUnit before submission

**Goal:** Provide clear, minimal reproduction for efficient issue resolution