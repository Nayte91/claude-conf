# PHP-AST API - Agent Reference

Comprehensive php-ast API reference for Claude Code agents working on Symfony projects.

## API

### Core Functions

```php
ast\parse_code($code, $version)       // Parse PHP code string
ast\parse_file($file, $version)       // Parse PHP file  
ast\get_kind_name($kind)              // Get AST node type name
ast\kind_uses_flags($kind)            // Check if node type uses flags
ast\get_metadata()                    // Get all AST metadata (CRITICAL)
ast\get_supported_versions()          // List supported AST versions
```

### AST Versions
- **Available**: 50, 60, 70, 80, 85, 90, 100, 110, 120
- **Current**: 110 (recommended)
- **PHP 8.4**: Use version 120

### Key Node Types for Filtering

#### AST_CLASS (70) - flagsCombinable: true
```php
CLASS_ABSTRACT | CLASS_FINAL | CLASS_TRAIT | CLASS_INTERFACE | CLASS_ENUM | CLASS_READONLY
```

#### AST_METHOD (69) - flagsCombinable: true  
```php
MODIFIER_PUBLIC (1) | MODIFIER_PROTECTED (2) | MODIFIER_PRIVATE (4)
MODIFIER_STATIC (16) | MODIFIER_ABSTRACT (64) | MODIFIER_FINAL (32)
FUNC_RETURNS_REF | FUNC_GENERATOR
```

#### AST_PROP_GROUP (774) - flagsCombinable: true
```php
MODIFIER_PUBLIC (1) | MODIFIER_PROTECTED (2) | MODIFIER_PRIVATE (4)  
MODIFIER_STATIC (16) | MODIFIER_READONLY (128)
MODIFIER_PUBLIC_SET (1024) | MODIFIER_PROTECTED_SET (2048) | MODIFIER_PRIVATE_SET (4096)
```

#### AST_ATTRIBUTE (546) - PHP 8 attributes
- Structure: `class` (attribute name) + `args` (arguments)
- No specific flags

#### AST_ATTRIBUTE_LIST (146) - Container for attributes
#### AST_PROP_ELEM (1027) - Individual property element

### Binary Flag System

#### Flag Values (Binary)
```php
MODIFIER_PUBLIC = 1      // 0001
MODIFIER_PROTECTED = 2   // 0010  
MODIFIER_PRIVATE = 4     // 0100
MODIFIER_STATIC = 16     // 10000
```

#### Flag Testing Patterns
```php
// Test single flag
if ($node->flags & ast\flags\MODIFIER_PUBLIC) { /* public */ }

// Combine flags (OR)
if ($node->flags & (ast\flags\MODIFIER_PUBLIC | ast\flags\MODIFIER_STATIC)) { /* public OR static */ }

// Exclude flag (NOT)
if (!($node->flags & ast\flags\MODIFIER_PRIVATE)) { /* not private */ }
```

### Validated Filtering Patterns

#### Visibility Filter
```php
function isPublic($node) {
    return ($node->kind === ast\AST_PROP_GROUP || $node->kind === ast\AST_METHOD) 
        && ($node->flags & ast\flags\MODIFIER_PUBLIC);
}
```

#### Node Type Filter
```php
function isClassStructure($node) {
    return in_array($node->kind, [ast\AST_CLASS, ast\AST_METHOD, ast\AST_PROP_GROUP]);
}
```

#### Symfony-Specific Filter (Public API)
```php
function isSymfonyPublicAPI($node) {
    return ($node->kind === ast\AST_PROP_GROUP && ($node->flags & ast\flags\MODIFIER_PUBLIC))
        || ($node->kind === ast\AST_METHOD && ($node->flags & ast\flags\MODIFIER_PUBLIC))
        || ($node->kind === ast\AST_ATTRIBUTE);
}
```

### Tested Results (User.php Entity)

#### Properties Found: 7 total
- **Public (flags=1)**: `id`, `email`, `username`, `ownedEvents`, `isVerified` 
- **Private (flags=4)**: `roles`, `password`

#### Methods Found: 13 public methods (flags=1)
- Core: `__construct`, `cleanStrings`  
- UserInterface: `getUsername`, `getUserIdentifier`, `getRoles`, `setRoles`
- Security: `hasRole`, `getPassword`, `setPassword`, `eraseCredentials`
- Relations: `getEvents`, `addEvent`, `removeEvent`

### Agent Implementation Patterns

#### Recursive AST Walker
```php
function walkAST($node, $filter, $level = 0) {
    $results = [];
    if ($node instanceof ast\Node) {
        if ($filter($node)) {
            $results[] = $node;
        }
        if (is_array($node->children)) {
            foreach ($node->children as $child) {
                $results = array_merge($results, walkAST($child, $filter, $level + 1));
            }
        }
    }
    return $results;
}
```

#### Performance-Optimized Filtering
```php
function applyDefaultFilters($ast) {
    // Skip non-class nodes early
    $classNode = findFirstNodeOfType($ast, ast\AST_CLASS);
    if (!$classNode) return null;
    
    // Apply visibility filters
    return filterTree($classNode, function($node) {
        return isSymfonyPublicAPI($node);
    });
}
```

### Critical Agent Notes

1. **Always use `ast\get_metadata()`** to understand node structure
2. **Flag combinations use binary operations** (&, |, !)  
3. **Version 110+ required** for PHP 8 attribute support
4. **flagsCombinable property** determines if binary operations work
5. **AST_PROP_GROUP contains multiple AST_PROP_ELEM** children
6. **Filter at parse time** for optimal performance

### ast\Node API

#### Class Structure
```php
class ast\Node {
    public int $kind;      // Node type (e.g., 70 = AST_CLASS)
    public int $flags;     // Combined flags (e.g., 1 = MODIFIER_PUBLIC)
    public int $lineno;    // Source line number  
    public array $children; // Child nodes or primitive values
    
    public function __construct(?int $kind, ?int $flags, ?array $children, ?int $lineno)
}
```

#### Key Characteristics
- **Minimal API**: Only `__construct()` method - no utility methods
- **No magic methods**: No `__toString()`, `__get()`, traversal helpers  
- **Mutable properties**: All properties are read/write accessible
- **Manual construction possible**: `new ast\Node(70, 1, [], 1)` works
- **No built-in filtering**: Must implement recursive tree walking manually

#### What Must Be Implemented by Agents
```php
// ✅ Manual recursive traversal required
function walkChildren($node) {
    if (!($node instanceof ast\Node)) return;
    foreach ($node->children as $child) {
        if ($child instanceof ast\Node) {
            processNode($child);
            walkChildren($child); // Recurse
        }
    }
}

// ✅ Type checking required
if ($node->kind === ast\AST_CLASS) { /* handle class */ }

// ✅ Flag testing required  
if ($node->flags & ast\flags\MODIFIER_PUBLIC) { /* handle public */ }

// ✅ Name conversion required
$typeName = ast\get_kind_name($node->kind); // "AST_CLASS"
```

#### ast\Metadata Companion Object
```php
class ast\Metadata {
    public int $kind;           // Node type number (70)
    public string $name;        // Node type name ("AST_CLASS")
    public array $flags;        // Available flags for this type
    public bool $flagsCombinable; // Whether flags can be combined (true/false)
}
```

### Flag System Deep Dive

#### Binary Flag Architecture
Each flag occupies a specific bit position:
```php
MODIFIER_PUBLIC = 1      // Binary: 0001 (bit 0)
MODIFIER_PROTECTED = 2   // Binary: 0010 (bit 1)  
MODIFIER_PRIVATE = 4     // Binary: 0100 (bit 2)
MODIFIER_STATIC = 16     // Binary: 10000 (bit 4)
MODIFIER_READONLY = 128  // Binary: 10000000 (bit 7)
```

#### flagsCombinable Property Significance
```php
// From ast\get_metadata()
AST_PROP_GROUP->flagsCombinable = 1;  // Can combine: public + static + readonly
AST_BINARY_OP->flagsCombinable = '';  // Single flag only: + OR - OR * (not combined)
```

#### Advanced Flag Testing Patterns
```php
// Test single flag (AND operation)
if ($node->flags & ast\flags\MODIFIER_PUBLIC) { /* is public */ }

// Test multiple flags (OR operation) - "any of these"
if ($node->flags & (ast\flags\MODIFIER_PUBLIC | ast\flags\MODIFIER_PROTECTED)) { 
    /* is public OR protected (not private) */ 
}

// Test combined flags (AND operation) - "all of these" 
if (($node->flags & ast\flags\MODIFIER_PUBLIC) && ($node->flags & ast\flags\MODIFIER_STATIC)) {
    /* is public AND static */ 
}

// Exclude flag (NOT operation)
if (!($node->flags & ast\flags\MODIFIER_PRIVATE)) { /* not private */ }

// Complex combination example
$isPublicNonStatic = ($node->flags & ast\flags\MODIFIER_PUBLIC) 
                  && !($node->flags & ast\flags\MODIFIER_STATIC);
```

#### Validated Flag Results (User.php Entity)
Our testing revealed:
```php
// Properties found with flag analysis
$publicProperties = 4;  // flags = 1 (MODIFIER_PUBLIC only)
$privateProperties = 2; // flags = 4 (MODIFIER_PRIVATE only)  
$combinedFlags = 0;     // No public+static or other combinations found

// Methods found  
$publicMethods = 13;    // flags = 1 (MODIFIER_PUBLIC only)
$privateMethods = 0;    // No private methods in this entity
```

#### Performance Optimization Strategy
```php
// Early filtering by node kind before flag checking
function efficientFilter($node) {
    // Quick type elimination
    if (!in_array($node->kind, [ast\AST_PROP_GROUP, ast\AST_METHOD, ast\AST_ATTRIBUTE])) {
        return false;
    }
    
    // Then apply flag filtering
    return ($node->flags & ast\flags\MODIFIER_PUBLIC) || ($node->kind === ast\AST_ATTRIBUTE);
}
```

### Implications for AstProvider

#### What php-ast Provides (Minimal)
- Raw `ast\Node` objects with basic properties
- Flag metadata via `ast\get_metadata()`  
- Type name resolution via `ast\get_kind_name()`

#### What Agents Must Build (Everything Else)
- **Recursive tree walking** - No built-in traversal API
- **Filtering logic** - Manual flag and type checking
- **JSON serialization** - Custom conversion required
- **Performance optimization** - Manual pruning and caching
- **Search functionality** - No findByName() or similar helpers

### Next Implementation Steps

1. Integrate manual filtering patterns into `AstProvider::applyDefaultFilters()`
2. Add URL parameters for dynamic filtering (`?visibility=public&flags=MODIFIER_STATIC`)  
3. Implement Symfony-specific presets (`?preset=symfony_entities`)
4. Build caching layer for identical file/filter combinations
5. Create utility functions for common flag combination patterns