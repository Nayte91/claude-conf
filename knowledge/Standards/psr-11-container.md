## Header
- **Source URL**: https://www.php-fig.org/psr/psr-11/
- **Processed Date**: 2025-01-25
- **Domain**: php-fig.org
- **Version**: PSR-11
- **Weight Reduction**: ~43%
- **Key Sections**: Interface Definitions, Method Contracts, Exception Handling, Implementation Guidelines

## Body

### Core Interface Definitions

#### ContainerInterface
```php
namespace Psr\Container;

interface ContainerInterface
{
    public function get(string $id);
    public function has(string $id): bool;
}
```

#### Method Contracts

##### `get($id)` Method
- **Parameter**: `$id` - Entry identifier (unique, opaque string)
- **Returns**: Mixed value for the entry
- **Behavior**: 
  - Successive calls may return different values
  - Must throw `NotFoundExceptionInterface` if entry not found
  - Must throw `ContainerExceptionInterface` on other errors

##### `has($id)` Method
- **Parameter**: `$id` - Entry identifier
- **Returns**: `bool` - True if entry exists, false otherwise
- **Contract**: 
  - If `has($id)` returns `false`, `get($id)` MUST throw `NotFoundExceptionInterface`
  - If `has($id)` returns `true`, `get($id)` MUST NOT throw `NotFoundExceptionInterface`

### Exception Interfaces

#### Base Exception Interface
```php
namespace Psr\Container;

interface ContainerExceptionInterface extends Throwable
{
}
```

#### Not Found Exception Interface
```php
namespace Psr\Container;

interface NotFoundExceptionInterface extends ContainerExceptionInterface
{
}
```

### Exception Handling Rules

#### Required Exception Types
- **`ContainerExceptionInterface`** - Base container exception
- **`NotFoundExceptionInterface`** - Entry not found (extends ContainerExceptionInterface)

#### Exception Throwing Requirements
- **`get()` method** MUST throw `NotFoundExceptionInterface` when identifier not found
- **All container errors** MUST implement `ContainerExceptionInterface`
- **Implementation exceptions** SHOULD extend these interfaces

### Implementation Guidelines

#### Package Declaration
- **Implementations** MUST declare `psr/container-implementation` version 1.0.0
- **Composer.json** should include appropriate provide declaration

#### Best Practices
- **Avoid Service Locator pattern** - Discouraged usage pattern
- **Entry identifiers** should be unique, opaque strings
- **Container behavior** should be predictable and consistent

### Technical Constraints

#### Entry Identifier Rules
- **Format**: Unique, opaque strings
- **Uniqueness**: Each identifier maps to specific entry
- **Opacity**: Internal structure should not be relied upon

#### Return Value Behavior
- **`get()` returns**: Any PHP value (mixed)
- **Multiple calls**: May return different instances/values
- **Consistency**: Same identifier should resolve to same logical entry

### Version History

#### PSR-11 v1.0
- **Initial specification**
- **Basic interface contracts**

#### PSR-11 v1.1
- **Added argument type hints**
- **Enhanced type safety**

#### PSR-11 v2.0
- **Added return type hints** for `has()` method
- **Improved type declarations**

### Integration Patterns

#### Framework Integration
- **Dependency Injection** containers implement PSR-11
- **Interoperability** between different DI containers
- **Standardized access** patterns across frameworks

#### Usage Anti-Patterns
- **Service Locator** usage discouraged
- **Direct container** access in business logic
- **Container passing** through application layers

### Implementation Requirements

#### Interface Compliance
- **MUST implement** `ContainerInterface`
- **MUST throw** appropriate exceptions
- **MUST respect** method contracts

#### Exception Implementation
```php
class ContainerException extends Exception implements ContainerExceptionInterface
{
}

class NotFoundException extends ContainerException implements NotFoundExceptionInterface
{
}
```

### Fundamental Principles
- **Standardization** of container interactions
- **Framework interoperability**
- **Predictable exception handling**
- **Type safety** with modern PHP versions