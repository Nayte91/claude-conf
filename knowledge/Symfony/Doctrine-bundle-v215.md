## Header
- **Source**: Multiple DoctrineBundle v2.15.x documentation sources
- **Processed Date**: 2025-09-01
- **Domain**: doctrine-bundle.readthedocs.io
- **Version**: v2.15
- **Weight Reduction**: ~65%
- **Key Sections**: Installation, Configuration, Entity Listeners, Event Listeners, Custom ID Generators, Middlewares

## Body

# Table of Contents

1. [Installation](#installation)
2. [Configuration Reference](#configuration-reference)
3. [Entity Listeners](#entity-listeners)
4. [Event Listeners](#event-listeners)
5. [Custom ID Generators](#custom-id-generators)
6. [Middlewares](#middlewares)

---

## Installation

### Quick Installation Process

#### Step 1: Download Bundle
```bash
composer require doctrine/doctrine-bundle
```
> Requires global Composer installation

#### Step 2: Bundle Configuration

##### With Symfony Flex
Automatically enabled. No manual intervention needed.

##### Without Flex
Manually add to `config/bundles.php`:
```php
return [
    Doctrine\Bundle\DoctrineBundle\DoctrineBundle::class => ['all' => true],
];
```

##### Legacy Symfony Versions
For older versions, update `app/AppKernel.php`:
```php
class AppKernel extends Kernel
{
    public function registerBundles()
    {
        $bundles = [
            new Doctrine\Bundle\DoctrineBundle\DoctrineBundle(),
        ];
    }
}
```

### Key Requirements
- Global Composer installation
- Symfony project structure
- PHP environment compatible with Doctrine Bundle

---

## Configuration Reference

### Key Configuration Sections

#### DBAL (Database Abstraction Layer) Configuration

##### Primary Connection Parameters
- `dbname`: Database name
- `host`: Database host (default: `localhost`)
- `port`: Database port
- `user`: Database username
- `password`: Database password
- `driver`: Database driver (e.g., `pdo_mysql`)

##### Advanced Connection Options
- `url`: Complete database connection URL
- `unix_socket`: Unix socket path
- `persistent`: Enable persistent connections
- `charset`: Character set
- `logging`: Enable query logging
- `schema_filter`: Filter for database schema objects

##### Database-Specific Options
- PostgreSQL: SSL configuration parameters
- Oracle: Session and service configuration
- SQLite: Path and memory options

#### ORM (Object-Relational Mapping) Configuration

##### Proxy Configuration
- `auto_generate_proxy_classes`: Proxy generation strategy
- `proxy_dir`: Directory for proxy classes
- `proxy_namespace`: Namespace for proxy classes

##### Caching Strategies
- Supports metadata, query, and result caching
- Can use Symfony Cache pools
- Configurable cache drivers (pool, service)

##### Mapping Configuration
Key mapping parameters:
- `type`: Metadata type (attribute, xml, yml, php)
- `dir`: Path to mapping files
- `prefix`: Namespace prefix
- `alias`: Simplified entity namespace

##### Filters
- Define custom doctrine filters
- Enable/disable filters
- Set default filter parameters

#### Recommended Practices
1. Use environment-specific configurations
2. Leverage Symfony's cache integration
3. Configure database-specific options carefully
4. Use autowiring for multiple connections/entity managers

#### Example Minimal Configuration
```yaml
doctrine:
    dbal:
        driver: pdo_mysql
        host: localhost
        user: database_user
        password: database_password
        dbname: database_name
    orm:
        auto_mapping: true
```

---

## Entity Listeners

### Core Configuration

Entity listeners in Doctrine require two primary steps:

1. Annotate/Attribute the Entity
```php
#[ORM\Entity]
#[ORM\EntityListeners([UserListener::class])]
class User {
    // Entity definition
}
```

2. Register the Listener Service
```yaml
services:
    App\UserListener:
        tags:
            - { name: doctrine.orm.entity_listener }
```

### Advanced Configuration Options

#### Specific Event Targeting
```yaml
services:
    App\UserListener:
        tags:
            - {
                name: doctrine.orm.entity_listener,
                event: preUpdate,
                entity: App\Entity\User
            }
```

#### Lazy Loading
```yaml
services:
    App\UserListener:
        tags:
            - { name: doctrine.orm.entity_listener, lazy: true }
```

### Key Principles
- Listeners must be registered with the entity listener resolver
- Use `doctrine.orm.entity_listener` tag for automatic resolution
- Optional `entity_manager` attribute for specific manager targeting
- Supports both annotation and attribute-based configuration

### Invocation Strategies
1. Explicit method specification
2. Event-based method matching
3. Fallback to `__invoke()` method if no specific method defined

---

## Event Listeners

### Core Concept
Event listeners in Doctrine are services that monitor entity lifecycle events across an entire application.

### Registration Methods

#### PHP Attribute Method
```php
#[AsDoctrineListener('postPersist')]
class SearchIndexer {
    public function postPersist(LifecycleEventArgs $event): void {
        // Event handling logic
    }
}
```

#### YAML Configuration
```yaml
services:
    App\EventListener\SearchIndexer:
        tags:
            - { 
                name: 'doctrine.event_listener', 
                event: 'postPersist',
                priority: 500,
                connection: 'default' 
            }
```

### Key Configuration Parameters
- `event`: Required event type (e.g., 'postPersist')
- `priority`: Execution order (higher number = earlier execution)
- `connection`: Optional specific database connection

### Best Practices
- Use `AsDoctrineListener` attribute for modern PHP implementations
- Specify clear, focused event handling logic
- Consider priority when multiple listeners exist for same event

### Supported Configuration Formats
- PHP Attributes
- YAML
- XML
- PHP Service Configuration

---

## Custom ID Generators

### Key Technical Implementation Details

#### Core Concept
Custom ID generators extend `Doctrine\ORM\Id\AbstractIdGenerator` and implement a `generate()` method to create custom identifier logic.

#### Symfony Integration

##### Configuration
- Supports service-based ID generation via `doctrine.id_generator` tag
- Autoconfiguration enabled by default
- Supports built-in generators for ULIDs and UUIDs

#### Implementation Example
```php
#[ORM\Entity]
class User {
    #[ORM\Id]
    #[ORM\Column(type: 'uuid')]
    #[ORM\GeneratedValue(strategy: 'CUSTOM')]
    #[ORM\CustomIdGenerator('doctrine.uuid_generator')]
    private $id;
}
```

#### Key Considerations
- Pre-2.3 Doctrine bundle: Generators created without constructor arguments
- Post-2.3: Can reference tagged services for ID generation
- Supports programmatic ID generation strategies

---

## Middlewares

### Core Concept
Middlewares in Doctrine DBAL intercept and modify driver interactions:

> "A middleware sits in the middle between the wrapper components and the driver"

### Supported Decoration Classes
- `Doctrine\DBAL\Driver`
- `Doctrine\DBAL\Driver\Connection`
- `Doctrine\DBAL\Driver\Statement`
- `Doctrine\DBAL\Driver\Result`

### Implementation Pattern

#### Basic Middleware Structure
```php
class PreventRootConnectionMiddleware implements Middleware {
    public function wrap(Driver $driver): Driver {
        return new CustomDriverWrapper($driver);
    }
}

class CustomDriverWrapper extends AbstractDriverMiddleware {
    public function connect(array $params): Connection {
        // Custom connection logic
        return parent::connect($params);
    }
}
```

### Configuration Options

#### Connection Scoping
- Use `#[AsMiddleware]` attribute to limit middleware to specific connections
- Set priority to control execution order

#### Example: Restrict Root User Connection
```php
#[AsMiddleware(connections: ['legacy'], priority: 10)]
class PreventRootConnectionMiddleware implements Middleware {
    public function connect(array $params) {
        if ($params['user'] === 'root') {
            throw new \LogicException('Root connection prevented');
        }
        // Proceed with connection
    }
}
```

### Key Considerations
- Requires Doctrine DBAL 3.2+
- Supports granular driver interaction modification
- Enables custom connection, statement, and result handling