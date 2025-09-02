## Header
- **Source**: Multiple Doctrine ORM v3.5 reference sources
- **Processed Date**: 2025-09-01
- **Domain**: Doctrine ORM
- **Version**: v3.5
- **Weight Reduction**: ~58%
- **Key Sections**: Configuration, Architecture, Mapping, DQL, Query Builder, Entity Management, Inheritance, Performance, Caching, Events

## Body

# Doctrine ORM Reference v3.5

## Installation and Configuration

### Installation
Use Composer for installation:
```bash
composer require doctrine/orm
```

### EntityManager Setup

**Attribute-based Configuration:**
```php
$paths = ['/path/to/entity-files'];
$isDevMode = false;
$dbParams = [
    'driver'   => 'pdo_mysql',
    'user'     => 'root',
    'password' => '',
    'dbname'   => 'foo',
];

$config = ORMSetup::createAttributeMetadataConfig($paths, $isDevMode);
$connection = DriverManager::getConnection($dbParams, $config);
$entityManager = new EntityManager($connection, $config);
```

**XML-based Configuration:**
```php
$paths = ['/path/to/xml-mappings'];
$config = ORMSetup::createXMLMetadataConfig($paths, $isDevMode);
$connection = DriverManager::getConnection($dbParams, $config);
$entityManager = new EntityManager($connection, $config);
```

### Development vs Production Configuration

**Development Mode (isDevMode = true):**
- In-memory caching
- Proxy objects recreated on each request
- Automatic metadata processing

**Production Mode (isDevMode = false):**
- Persistent caching (APCu, Redis, Memcache)
- Pre-generated proxy classes required
- Requires `symfony/cache` library

## Advanced Configuration

### Caching Strategies
Uses PSR-6 standard cache interfaces:
- **Metadata Caching**: Stores entity mapping information
- **Query Caching**: Caches DQL query parsing results
- **Result Caching**: Stores query result sets

### Cache Adapters
- ArrayAdapter (development)
- PhpFilesAdapter (production)
- APCu, Redis, Memcache for production

### Proxy Configuration
```php
$config = new Configuration;
$config->setMetadataCache($metadataCache);
$config->setQueryCache($queryCache);
$config->setProxyDir('/path/to/proxies');
$config->setProxyNamespace('MyProject\Proxies');
```

### Proxy Generation Strategies
- `AUTOGENERATE_NEVER`: Manual generation
- `AUTOGENERATE_ALWAYS`: Always regenerate
- `AUTOGENERATE_FILE_NOT_EXISTS`: Generate if missing
- `AUTOGENERATE_EVAL`: Runtime generation

### Metadata Drivers
- **AttributeDriver**: PHP 8+ attributes
- **XmlDriver**: XML mapping files
- **DriverChain**: Multiple driver combination

## Architecture

### System Requirements
- PHP 8.1+ minimum
- Recommended: APC for performance

### Core Components
- **EntityManager**: Central ORM access point
- **UnitOfWork**: Tracks database operations
- **Metadata Drivers**: Entity mapping configuration
- **DBAL**: Database abstraction layer

### Entity States
- **NEW**: No persistent identity, not managed
- **MANAGED**: Has persistent identity, managed by EntityManager
- **DETACHED**: Has persistent identity, not managed
- **REMOVED**: Marked for deletion on next flush

### Entity Requirements
- Cannot be final or read-only classes
- No duplicate mapped properties in inheritance
- Collection fields must use `Doctrine\Common\Collections\Collection`
- Field access only within entity methods

## Basic Mapping

### Entity Declaration
```php
#[Entity]
#[Table(name: 'message')]
class Message {
    #[Id]
    #[Column(type: 'integer')]
    #[GeneratedValue]
    private int|null $id = null;

    #[Column(length: 140)]
    private string $text;
}
```

### Column Attributes
- **type**: Data type (default: 'string')
- **name**: Column name (default: property name)
- **length**: Column length (default: 255)
- **unique**: Unique constraint (default: false)
- **nullable**: NULL values allowed (default: false)

### Identifier Generation Strategies
- **AUTO**: Platform-dependent (default)
- **IDENTITY**: Database auto-increment
- **SEQUENCE**: Database sequence
- **NONE**: Manually assigned
- **CUSTOM**: Custom generator

### PHP Type Automatic Mapping
- `DateTime` → `DATETIME_MUTABLE`
- `DateTimeImmutable` → `DATETIME_IMMUTABLE`
- `bool` → `BOOLEAN`
- `int` → `INTEGER`
- `array` → `JSON`
- Default → `STRING`

## Association Mapping

### Association Types
1. **Many-To-One**: Multiple entities reference one entity
2. **One-To-One**: Single entity references single entity
3. **One-To-Many**: One entity references multiple entities
4. **Many-To-Many**: Multiple entities reference multiple entities

### Key Mapping Attributes
- **targetEntity**: Related entity class
- **mappedBy**: Inverse side (bidirectional)
- **inversedBy**: Owning side (bidirectional)
- **JoinColumn**: Foreign key configuration

### Collection Initialization
```php
use Doctrine\Common\Collections\ArrayCollection;

public function __construct() {
    $this->items = new ArrayCollection();
}
```

### Relationship Examples
```php
// Many-To-One
#[ManyToOne(targetEntity: User::class)]
#[JoinColumn(name: 'user_id', referencedColumnName: 'id')]
private User $user;

// One-To-Many (Bidirectional)
#[OneToMany(targetEntity: Comment::class, mappedBy: 'article')]
private Collection $comments;

// Many-To-Many
#[ManyToMany(targetEntity: Tag::class, inversedBy: 'articles')]
#[JoinTable(name: 'article_tags')]
private Collection $tags;
```

### Join Column Defaults
- Column name: `<fieldname>_id`
- Referenced column: `id`
- Join table: Combination of class names

## Inheritance Mapping

### Inheritance Strategies

**1. Mapped Superclasses**
- Abstract/concrete class providing persistent state
- No database table created
- Cannot be queried or have @Id property
- Supports limited associations

**2. Single Table Inheritance**
```php
#[Entity]
#[InheritanceType('SINGLE_TABLE')]
#[DiscriminatorColumn(name: 'discr', type: 'string')]
#[DiscriminatorMap(['person' => Person::class, 'employee' => Employee::class])]
class Person { }

#[Entity]
class Employee extends Person { }
```
- All classes in single table
- Discriminator column identifies types
- Efficient querying, no joins
- Requires nullable columns for subclasses

**3. Class Table Inheritance**
```php
#[Entity]
#[InheritanceType('JOINED')]
#[DiscriminatorColumn(name: 'discr', type: 'string')]
#[DiscriminatorMap(['person' => Person::class, 'employee' => Employee::class])]
class Person { }
```
- Separate linked tables per class
- Foreign key constraints required
- Flexible schema modifications
- Performance overhead from joins

### Overrides
```php
#[AttributeOverride(name: 'name', column: new Column(name: 'fullname'))]
class Employee extends Person { }
```

## Working with Objects

### Entity Management

**Persisting Entities:**
```php
$entity = new User();
$entity->setName('John');
$em->persist($entity);  // Mark for persistence
$em->flush();           // Execute SQL
```

**Removing Entities:**
```php
$em->remove($entity);   // Mark for deletion
$em->flush();           // Execute deletion
```

**Detaching Entities:**
```php
$em->detach($entity);   // Disconnect from EntityManager
```

### Querying Strategies

**By Primary Key:**
```php
$user = $em->find(User::class, $id);
```

**By Conditions:**
```php
$users = $repository->findBy(['status' => 'active']);
$user = $repository->findOneBy(['email' => 'user@example.com']);
```

**Repository Methods:**
```php
$repository = $em->getRepository(User::class);
$users = $repository->findAll();
$user = $repository->find($id);
```

### Unit of Work Pattern
- Started when EntityManager created or after flush()
- Tracks all entity changes in memory
- Committed by calling `flush()`
- Not automatically triggered

### Entity State Transitions
- **New** → `persist()` → **Managed**
- **Managed** → `remove()` → **Removed**
- **Managed** → `detach()` → **Detached**
- **Detached** → `merge()` → **Managed**

## Doctrine Query Language (DQL)

### DQL Overview
Object-oriented query language similar to SQL but operates on object models rather than database schemas. Case-insensitive except for namespaces, classes, and fields.

### Query Types
1. **SELECT**: Retrieve objects and scalar values
2. **UPDATE**: Bulk entity updates
3. **DELETE**: Bulk entity deletions

### Basic Syntax
```php
// Simple query
$query = $em->createQuery('SELECT u FROM App\Entity\User u WHERE u.age > 20');
$users = $query->getResult();

// Join query
$query = $em->createQuery("SELECT u, a FROM User u JOIN u.address a WHERE a.city = 'Berlin'");
```

### Parameter Binding
```php
// Named parameters
$query = $em->createQuery('SELECT u FROM User u WHERE u.name = :name');
$query->setParameter('name', 'John');

// Positional parameters
$query = $em->createQuery('SELECT u FROM User u WHERE u.age > ?1');
$query->setParameter(1, 18);
```

### Hydration Modes
- **getResult()**: Collection of objects
- **getArrayResult()**: Nested array structure
- **getScalarResult()**: Flat scalar array
- **getSingleResult()**: Single object
- **getSingleScalarResult()**: Single scalar value

### Advanced DQL Features
- Complex joins (INNER, LEFT, with conditions)
- Aggregate functions (COUNT, SUM, AVG, etc.)
- Subqueries in SELECT, WHERE, and HAVING
- Custom functions registration
- Inheritance querying with INSTANCE OF

### DQL Query Examples
```php
// Aggregate query
$query = $em->createQuery('SELECT COUNT(u.id) FROM User u WHERE u.active = true');
$count = $query->getSingleScalarResult();

// Complex join with conditions
$dql = "SELECT u, a FROM User u 
        LEFT JOIN u.address a WITH a.country = 'US'
        WHERE u.status = 'active'
        ORDER BY u.createdAt DESC";
```

## QueryBuilder

### QueryBuilder Overview
Provides programmatic and fluent API for constructing DQL queries dynamically.

### Basic Usage
```php
$qb = $em->createQueryBuilder();
$users = $qb->select('u')
    ->from('User', 'u')
    ->where('u.age > :age')
    ->orderBy('u.name', 'ASC')
    ->setParameter('age', 18)
    ->getQuery()
    ->getResult();
```

### Key Methods
- **select()**: Define SELECT clause
- **from()**: Specify entity and alias
- **where()**: Add WHERE conditions
- **join()**: Add JOIN clauses
- **orderBy()**: Define ORDER BY
- **groupBy()**: Add GROUP BY
- **having()**: Add HAVING conditions
- **setParameter()**: Bind parameters

### Parameter Binding Styles
```php
// Named parameters (recommended)
$qb->where('u.name = :name')
   ->setParameter('name', 'John');

// Positional parameters
$qb->where('u.age > ?1')
   ->setParameter(1, 18);
```

### Expression Builder
```php
$expr = $qb->expr();
$qb->where($expr->eq('u.id', ':id'))
   ->orWhere($expr->like('u.name', ':name'))
   ->setParameter('id', 1)
   ->setParameter('name', 'John%');
```

### Complex QueryBuilder Example
```php
$qb = $em->createQueryBuilder()
    ->select('u', 'a', 'p')
    ->from('User', 'u')
    ->leftJoin('u.address', 'a')
    ->leftJoin('u.posts', 'p')
    ->where('u.status = :status')
    ->andWhere($qb->expr()->isNotNull('a.id'))
    ->orderBy('u.createdAt', 'DESC')
    ->setParameter('status', 'active')
    ->setMaxResults(10);
```

## Caching

### Cache Types
1. **Metadata Cache**: Entity mapping information
2. **Query Cache**: Parsed DQL queries
3. **Result Cache**: Query result sets

### Cache Configuration
```php
use Symfony\Component\Cache\Adapter\PhpFilesAdapter;

$cache = new PhpFilesAdapter('doctrine_cache');
$config->setMetadataCache($cache);
$config->setQueryCache($cache);
```

### Result Cache Usage
```php
$query = $em->createQuery('SELECT u FROM User u WHERE u.status = :status');
$query->setParameter('status', 'active');
$query->useResultCache(true, 3600, 'users_active'); // TTL: 1 hour
$users = $query->getResult();
```

### Cache Adapters (Production)
- **APCu**: In-memory cache
- **Redis**: Distributed cache server
- **Memcache**: Distributed memory caching
- **PhpFiles**: File-based cache

## Performance Optimization

### Lazy Loading
Associations are loaded on-demand when accessed. Configure fetch modes:
```php
#[OneToMany(targetEntity: Comment::class, fetch: 'EAGER')]
private Collection $comments;
```

### Batch Processing
For large datasets, use batch processing:
```php
$batchSize = 20;
for ($i = 0; $i < 1000; $i++) {
    $user = new User();
    $user->setName('User ' . $i);
    $em->persist($user);
    
    if (($i % $batchSize) === 0) {
        $em->flush();
        $em->clear();
    }
}
$em->flush();
$em->clear();
```

### Query Optimization
- Use joins instead of separate queries
- Limit result sets with `setMaxResults()`
- Use partial objects for specific fields only
- Avoid N+1 query problems with fetch joins

### Change Tracking Policies
- **DEFERRED_IMPLICIT**: Default, automatic change detection
- **DEFERRED_EXPLICIT**: Manual change notification
- **NOTIFY**: Notify on property changes

## Events

### Lifecycle Events
- **prePersist**: Before entity insert
- **postPersist**: After entity insert
- **preUpdate**: Before entity update
- **postUpdate**: After entity update
- **preRemove**: Before entity removal
- **postRemove**: After entity removal
- **postLoad**: After entity loaded from database

### Event Listener Example
```php
#[Entity]
#[HasLifecycleCallbacks]
class User {
    #[PrePersist]
    public function prePersist(): void {
        $this->createdAt = new DateTime();
    }
    
    #[PreUpdate]
    public function preUpdate(): void {
        $this->updatedAt = new DateTime();
    }
}
```

### Entity Listeners
```php
#[Entity]
#[EntityListeners([UserListener::class])]
class User { }

class UserListener {
    public function prePersist(User $user, PrePersistEventArgs $event): void {
        // Custom logic
    }
}
```

## Native SQL

### ResultSetMapping
```php
$rsm = new ResultSetMapping();
$rsm->addEntityResult(User::class, 'u');
$rsm->addFieldResult('u', 'id', 'id');
$rsm->addFieldResult('u', 'name', 'name');

$query = $em->createNativeQuery('SELECT id, name FROM users WHERE active = ?', $rsm);
$query->setParameter(1, true);
$users = $query->getResult();
```

### Scalar Results
```php
$rsm = new ResultSetMapping();
$rsm->addScalarResult('cnt', 'count');

$query = $em->createNativeQuery('SELECT COUNT(*) as cnt FROM users', $rsm);
$count = $query->getSingleScalarResult();
```

## Transactions and Concurrency

### Transaction Management
```php
$em->getConnection()->beginTransaction();
try {
    // Entity operations
    $em->flush();
    $em->getConnection()->commit();
} catch (Exception $e) {
    $em->getConnection()->rollBack();
    throw $e;
}
```

### Optimistic Locking
```php
#[Entity]
class User {
    #[Version]
    #[Column(type: 'integer')]
    private int $version;
}

// Usage
try {
    $em->flush();
} catch (OptimisticLockException $e) {
    // Handle version conflict
}
```

### Pessimistic Locking
```php
$user = $em->find(User::class, 1, LockMode::PESSIMISTIC_WRITE);
// User is locked until transaction ends
```

## Tools and Utilities

### Schema Generation
```bash
# Generate database schema
php vendor/bin/doctrine orm:schema-tool:create

# Update existing schema
php vendor/bin/doctrine orm:schema-tool:update --force

# Drop schema
php vendor/bin/doctrine orm:schema-tool:drop --force
```

### Proxy Generation
```bash
# Generate proxy classes
php vendor/bin/doctrine orm:generate-proxies
```

### Schema Validation
```bash
# Validate mapping
php vendor/bin/doctrine orm:validate-schema
```

### Entity Generation
```bash
# Generate entities from database
php vendor/bin/doctrine orm:convert-mapping --from-database annotation ./src
```

## Best Practices

### Entity Design
- Keep entities simple and focused
- Use value objects for complex data types
- Implement proper encapsulation
- Avoid public properties

### Performance
- Always use metadata and query caching in production
- Implement proper indexing strategies
- Use batch processing for bulk operations
- Monitor and optimize slow queries

### Configuration
- Use different configurations for development/production
- Pre-generate proxy classes in production
- Configure appropriate cache adapters
- Set proper memory limits for batch processing

### Testing
- Use separate test databases
- Implement proper fixtures
- Test entity relationships thoroughly
- Use transactions for test isolation