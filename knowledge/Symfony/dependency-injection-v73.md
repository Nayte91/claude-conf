## Header
- **Source URL**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/components/dependency_injection.rst
- **Processed Date**: 2025-01-25
- **Domain**: symfony/symfony-docs
- **Version**: v73
- **Weight Reduction**: ~41%
- **Key Sections**: Container Architecture, Service Definitions, Configuration, Advanced Patterns, Performance, Extensibility

## Body

### Core Technical Specifications

#### 1. Service Container Architecture
- **PSR-11 compatible** service container
- **Centralizes object construction** and dependency management
- **Multiple configuration formats**: PHP, XML, YAML

#### 2. Service Definition Strategies
- **Constructor Injection**
- **Setter Injection**
- **Parameterized Service Configuration**
- **Reference-based Dependency Linking**

#### 3. Configuration Mechanisms
- **Programmatic Container Building**
- **File-based Configuration Loading**
- **Parameter Substitution**
- **Service Reference Management**

### Key Technical Implementation Patterns

```php
// Basic Service Registration
$container->register('service_name', ServiceClass::class)
    ->addArgument($parameter)
    ->addMethodCall('setDependency', [new Reference('dependency')]);

// Configuration Loading
$loader = new XmlFileLoader($container, new FileLocator(__DIR__));
$loader->load('services.xml');
```

### Advanced Configuration Behaviors

#### Service Retrieval Modes
- **`EXCEPTION_ON_INVALID_REFERENCE`** (default)
- **`RUNTIME_EXCEPTION_ON_INVALID_REFERENCE`**
- **`NULL_ON_INVALID_REFERENCE`**
- **`IGNORE_ON_INVALID_REFERENCE`**
- **`IGNORE_ON_UNINITIALIZED_REFERENCE`**

### Performance & Design Recommendations
- **Minimize direct container interactions**
- **Prefer dependency injection** over service location
- **Use configuration files** for complex service definitions
- **Leverage compiler passes** for advanced service modifications

### Technical Dependencies
- **Requires Symfony Config** component for file loading
- **Requires Symfony YAML** component for YAML configuration
- **PSR-11 compatibility**

### Architectural Best Practices
- **Decouple service implementation** from container
- **Use parameters** for configuration flexibility
- **Prefer composition** over service container coupling
- **Implement clear separation** of concerns in service definitions

### Extensibility Mechanisms
- **Multiple configuration formats** support
- **Dynamic service registration**
- **Flexible dependency resolution**
- **Compiler pass integration** for advanced customization