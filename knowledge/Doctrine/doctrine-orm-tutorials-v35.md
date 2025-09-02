## Header
- **Source**: Multiple Doctrine ORM v3.5 tutorial sources
- **Processed Date**: 2025-09-01
- **Domain**: Doctrine ORM
- **Version**: v3.5
- **Weight Reduction**: ~52%
- **Key Sections**: Getting Started, Development Approaches, Embeddables, Composite Keys, Lazy Loading, Associations, Pagination, Overrides

## Body

# Doctrine ORM Tutorials v3.5

## Getting Started

### Technical Overview
Doctrine ORM is an object-relational mapper for PHP using the Data Mapper pattern to separate domain logic from database persistence. Supports multiple metadata configuration methods (Attributes, XML).

### Project Setup Requirements
- PHP (latest stable version)
- Composer package manager
- Doctrine ORM and DBAL packages

### Core Configuration
```php
$config = ORMSetup::createAttributeMetadataConfig(
    paths: [__DIR__ . '/src'],
    isDevMode: true,
);

$connection = DriverManager::getConnection([
    'driver' => 'pdo_sqlite',
    'path' => __DIR__ . '/db.sqlite',
], $config);

$entityManager = new EntityManager($connection, $config);
```

### Fundamental Concepts

**1. Entities**
- PHP objects identifiable by unique identifier
- Persistable properties mapped to database tables
- Configured using attributes or XML metadata

**2. Entity Relationships**
- Supports: ManyToOne, OneToMany, ManyToMany
- Distinguishes owning vs inverse sides
- Uses collections for managing related entities

**3. Query Methods**
- DQL (Doctrine Query Language)
- Multiple result hydration modes
- Repository pattern for query encapsulation

### Main Workflow
1. Define entities with metadata
2. Create EntityManager
3. Persist and manage entities
4. Query using repositories or DQL

### Recommended Practices
- Use rich entities with behavior
- Implement proper relationship management
- Leverage repository pattern for complex queries

## Development Approaches

### Code First (Standard)
- Start with PHP objects
- Map objects to database schema
- Generate database from entity definitions

### Model First
- Start with high-level model description using:
  - UML diagrams
  - Excel spreadsheets
  - XML files
  - CSV files
- Generate both PHP code and database schema from model
- Workflow: Modify model → Regenerate code → Regenerate schema

### Database First
- Start with existing database schema
- Generate PHP code from pre-existing database structure
- Uses Doctrine CodeGenerator subproject
- Workflow: Modify database → Regenerate PHP code

## Embeddables

### Overview
Embeddables are classes embedded in entities that can be queried. Primary use: reduce code duplication and separate concerns.

### Key Features
- Contains only properties with basic `@Column` mapping
- Columns automatically inlined into parent entity's table
- Supports attribute and XML configuration

### Column Naming
- Default: Columns prefixed with embeddable name (e.g., `address_street`)
- Customizable via `columnPrefix` attribute
- Option to disable prefix entirely

### Implementation Example
```php
#[Entity]
class User {
    #[Embedded(class: Address::class)]
    private Address $address;
    
    public function __construct() {
        $this->address = new Address(); // Prevent null issues
    }
}

#[Embeddable]
class Address {
    #[Column(type: "string")]
    private string $street;
    
    #[Column(type: "string")]
    private string $city;
    
    #[Column(type: "string")]
    private string $zipCode;
}
```

### Query Capabilities
```php
// DQL queries on embedded fields
$query = $em->createQuery('SELECT u FROM User u WHERE u.address.city = :myCity');
$query->setParameter('myCity', 'Berlin');
$users = $query->getResult();
```

### Best Practices
- Initialize nullable embeddable fields in constructor
- Use for value objects and complex data types
- Keep embeddables simple and focused

## Composite Primary Keys

### Technical Constraints
- Only primitive types (integer, string) supported
- Cannot use ID generators other than "NONE"
- Requires manual ID assignment before `persist()`

### Supported Scenarios
1. Primitive type composite keys
2. Foreign entity-based composite keys
3. Many-to-One and One-to-One associations as key components

### Implementation Patterns

**A. Primitive Type Composite Key**
```php
#[Entity]
class Car {
    #[Id, Column]
    private string $name;
    
    #[Id, Column]
    private int $year;
    
    public function __construct(string $name, int $year) {
        $this->name = $name;
        $this->year = $year;
    }
}
```

**B. Dynamic Attributes with Composite Key**
```php
#[Entity]
class ArticleAttribute {
    #[Id, ManyToOne(targetEntity: Article::class)]
    private Article $article;

    #[Id, Column]
    private string $attribute;
    
    #[Column]
    private string $value;
}
```

**C. Derived Identity (One-to-One)**
```php
#[Entity]
class Address {
    #[Id, OneToOne(targetEntity: User::class)]
    private User|null $user = null;
    
    #[Column]
    private string $street;
}
```

### Querying Composite Keys
```php
// Array-based find
$car = $em->find(Car::class, ['name' => 'Audi', 'year' => 2010]);

// DQL with positional parameters
$dql = "SELECT c FROM Car c WHERE c.name = ?1 AND c.year = ?2";
$query = $em->createQuery($dql);
$query->setParameter(1, 'Audi');
$query->setParameter(2, 2010);
```

### Performance Considerations
- Introduces PHP-side processing overhead
- Minimal SQL query performance impact
- Consider alternatives for high-performance scenarios

## Extra Lazy Associations

### Overview
Performance optimization for large entity collections without loading entire collections into memory.

### Optimized Methods (No Full Load)
- `contains()`: Check if collection contains element
- `containsKey()`: Check if key exists
- `count()`: Get collection count
- `first()`: Get first element
- `get()`: Get element by key
- `isEmpty()`: Check if collection is empty
- `slice()`: Get subset of collection

### Non-Loading Methods
- `add()`: Add element to collection
- `offsetSet()`: Set element (no specific key)

### Configuration
```php
#[Entity]
class User {
    #[ManyToMany(
        targetEntity: Group::class, 
        mappedBy: 'users', 
        fetch: 'EXTRA_LAZY'
    )]
    private Collection $groups;
}
```

### XML Configuration
```xml
<many-to-many 
    field="groups" 
    target-entity="Group" 
    mapped-by="users" 
    fetch="EXTRA_LAZY" 
/>
```

### Behavior
- **Collection not loaded**: Execute direct SELECT statement
- **Collection already loaded**: Use default lazy collection functionality

### Use Cases
- Large collections (thousands of items)
- Pagination scenarios
- Performance-critical applications
- Memory-constrained environments

## Ordered Associations

### Overview
Use `#[OrderBy]` attribute to sort collections retrieved from database.

### Configuration
```php
#[Entity]
class User {
    #[ManyToMany(targetEntity: Group::class)]
    #[OrderBy(["name" => "ASC"])]
    private Collection $groups;
}
```

### Multiple Field Ordering
```php
#[Entity]
class Post {
    #[OneToMany(targetEntity: Comment::class, mappedBy: 'post')]
    #[OrderBy(["priority" => "DESC", "createdAt" => "ASC"])]
    private Collection $comments;
}
```

### Behavior
- Implicit ORDER BY clause appended to queries
- Only applied when collection is fetch-joined
- Explicit ORDER BY can override default sorting

### Constraints
- Only unqualified, unquoted field names allowed
- Referenced fields must exist on target entity
- Works with DQL queries involving associated collections

### Query Transformations
```php
// Without fetch join - no ordering applied
$dql = "SELECT u FROM User u";

// With fetch join - automatic ordering applied
$dql = "SELECT u, g FROM User u JOIN u.groups g";
// Becomes: SELECT u, g FROM User u JOIN u.groups g ORDER BY g.name ASC

// Explicit ORDER BY override
$dql = "SELECT u, g FROM User u JOIN u.groups g ORDER BY g.name DESC";
```

## Pagination

### Overview
Provides a Paginator for DQL queries implementing SPL interfaces `Countable` and `IteratorAggregate`.

### Pagination Process
1. Count query using `DISTINCT`
2. Limit subquery to find page entity IDs  
3. Execute WHERE IN query for page results

### Basic Usage
```php
$dql = "SELECT p, c FROM BlogPost p JOIN p.comments c";
$query = $entityManager->createQuery($dql)
                       ->setFirstResult(0)
                       ->setMaxResults(100);

$paginator = new Paginator($query, fetchJoinCollection: true);

foreach ($paginator as $post) {
    echo $post->getHeadline();
}

$totalCount = count($paginator);
```

### Configuration Options

**fetchJoinCollection (default: true)**
- `true`: Performs full 3-query pagination
- `false`: Reduces to 2 queries (less accurate for collections)

**HINT_ENABLE_DISTINCT**
```php
$query->setHint(Query::HINT_ENABLE_DISTINCT, false);
$paginator = new Paginator($query);
```

### Performance Optimization
```php
// For to-one relations only, optimize with DISTINCT hint
$dql = "SELECT u, a FROM User u JOIN u.address a";
$query = $em->createQuery($dql)
    ->setHint(Query::HINT_ENABLE_DISTINCT, false)
    ->setFirstResult(20)
    ->setMaxResults(10);

$paginator = new Paginator($query, fetchJoinCollection: false);
```

### Complex Scenarios
```php
// Many-to-many with additional filtering
$dql = "SELECT p, c FROM BlogPost p JOIN p.comments c WHERE c.approved = true";
$query = $em->createQuery($dql)
    ->setFirstResult($offset)
    ->setMaxResults($limit);

$paginator = new Paginator($query, fetchJoinCollection: true);
```

### Important Notes
- Default pagination is complex for many-to-many associations
- `fetchJoinCollection: true` might impact aggregation queries
- Consider memory usage with large result sets
- Performance varies based on query complexity

## Indexed Associations

### Overview
Allow collections to be keyed by a specific entity field for direct access.

### Configuration
```php
#[Entity]
class Market {
    #[OneToMany(targetEntity: Stock::class, mappedBy: 'market', indexBy: 'symbol')]
    private Collection $stocks;
}

#[Entity]
class Stock {
    #[Column]
    private string $symbol;
    
    #[ManyToOne(targetEntity: Market::class, inversedBy: 'stocks')]
    private Market $market;
}
```

### XML Configuration
```xml
<one-to-many field="stocks" target-entity="Stock" mapped-by="market" index-by="symbol" />
```

### Usage Examples
```php
// Direct access via index
$stock = $market->getStocks()['AAPL'];

// Collection methods
$appleStock = $market->getStock('AAPL');
$hasGoogle = $market->getStocks()->containsKey('GOOGL');

// Slice with preserved indices
$topStocks = $market->getStocks()->slice(0, 10);
```

### Key Features
- Regenerates keys on each request
- Keys are for access purposes only
- Does not persist index key values
- Provides consistent collection access
- Indexed fields must be unique in database

### DQL Querying
```php
// DQL maintains indexing
$dql = "SELECT m, s FROM Market m JOIN m.stocks s WHERE m.name = :market";
$query = $em->createQuery($dql)->setParameter('market', 'NYSE');
$result = $query->getResult();

// Stocks collection will be indexed by symbol
foreach ($result as $market) {
    $appleStock = $market->getStocks()['AAPL'];
}
```

### Limitations
- Must manage both key and field values
- Undefined behavior with non-unique index fields
- No persistence of keys for one-to-many associations
- Future support planned for persisting keys in many-to-many join tables

### Best Practices
- Use for frequently accessed collections
- Ensure indexed field uniqueness
- Consider memory usage for large collections
- Validate index field existence before access

## Override Field and Association Mappings

### Overview
Allows overriding mapping metadata in subclasses or classes using traits using `#[AttributeOverrides]` and `#[AssociationOverrides]`.

### Base Trait Example
```php
trait ExampleTrait {
    #[Id, Column(type: 'integer')]
    private int|null $id = null;

    #[Column(name: 'trait_foo', type: 'integer', length: 100, nullable: true, unique: true)]
    protected int $foo;

    #[OneToOne(targetEntity: Bar::class, cascade: ['persist'])]
    #[JoinColumn(name: 'example_trait_bar_id', referencedColumnName: 'id')]
    protected Bar|null $bar = null;
}
```

### Overriding Implementation
```php
#[Entity]
#[AttributeOverrides([
    new AttributeOverride('foo', new Column(
        name: 'foo_overridden',
        type: 'integer',
        length: 140,
        nullable: false,
        unique: false,
    )),
])]
#[AssociationOverrides([
    new AssociationOverride('bar', [
        new JoinColumn(
            name: 'example_entity_overridden_bar_id',
            referencedColumnName: 'id',
        ),
    ]),
])]
class ExampleEntityWithOverride {
    use ExampleTrait;
}
```

### XML Alternative
```xml
<entity name="ExampleEntityWithOverride">
    <attribute-overrides>
        <attribute-override name="foo">
            <column name="foo_overridden" 
                    type="integer" 
                    length="140" 
                    nullable="false" 
                    unique="false" />
        </attribute-override>
    </attribute-overrides>
    
    <association-overrides>
        <association-override name="bar">
            <join-column name="example_entity_overridden_bar_id" 
                        referenced-column-name="id" />
        </association-override>
    </association-overrides>
</entity>
```

### Override Methods
1. **Via Traits**: Override properties from traits
2. **Via Class Extension**: Override inherited properties
3. **Multiple Overrides**: Combine attribute and association overrides

### Use Cases
- Modifying column names in different contexts
- Changing column properties (length, nullable, unique)
- Adjusting association mappings and join columns
- Customizing inherited metadata from traits or parent classes
- Database table customization per environment

### Best Practices
- Use sparingly to maintain code clarity
- Document override reasons clearly
- Consider composition over inheritance when possible
- Test overrides thoroughly in different contexts
- Validate that overridden fields maintain data integrity