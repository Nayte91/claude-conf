## Header
- **Source**: Multiple Doctrine ORM v3.5 cookbook sources
- **Processed Date**: 2025-09-01
- **Domain**: Doctrine ORM
- **Version**: v3.5
- **Weight Reduction**: ~55%
- **Key Sections**: Custom Types, Field Conversions, Aggregate Fields, Decorators, DQL Extensions, Entity Sessions, Database Features, Validation, DateTime Handling

## Body

# Doctrine ORM Cookbook v3.5

## Advanced Field Value Conversion Using Custom Mapping Types

Custom mapping types allow transforming field values before database storage. Implementation demonstrated through MySQL `Point` spatial data type.

### Entity Structure
```php
class Location {
    #[Column(type: 'point')]
    private Point $point;
    #[Column]
    private string $address;
}

class Point {
    public function __construct(
        private float $latitude,
        private float $longitude
    ) {}
}
```

### Custom Type Implementation
Extends `Doctrine\DBAL\Types\Type` with conversion methods:
- `convertToPHPValue()`: Database value → PHP object
- `convertToDatabaseValue()`: PHP object → Database value  
- `convertToPHPValueSQL()`: SQL conversion for SELECT clauses
- `convertToDatabaseValueSQL()`: SQL conversion for database storage

### Type Registration
```php
Type::addType('point', 'Geo\Types\PointType');
$em->getConnection()->getDatabasePlatform()->registerDoctrineTypeMapping('point', 'point');
```

## Aggregate Fields

Aggregate fields demonstrate handling computed values like account balances with data consistency strategies.

### Technical Approaches

**1. DQL Aggregation**
```php
SELECT SUM(e.amount) AS balance
```
- Requires separate query for each balance retrieval
- Simple but performance-limited

**2. Persistent Aggregate Field**
```php
class Account {
    private int $balance = 0;
    private Collection $entries;

    public function addEntry(int $amount): void {
        $this->assertAcceptEntryAllowed($amount);
        $this->entries[] = new Entry($this, $amount);
        $this->balance += $amount;
    }

    private function assertAcceptEntryAllowed(int $amount): void {
        $futureBalance = $this->getBalance() + $amount;
        $allowedMinimalBalance = ($this->maxCredit * -1);
        if ($futureBalance < $allowedMinimalBalance) {
            throw new Exception("Credit Limit exceeded");
        }
    }
}
```

**3. Race Condition Mitigation**
- Optimistic locking: Add version column, prevent concurrent modifications
- Pessimistic locking: Use database-level write locks

## Custom Mapping Types

### Creation Process
1. Subclass `Doctrine\DBAL\Types\Type`
2. Implement key methods:
   - `getSQLDeclaration()`: Define SQL column type
   - `convertToPHPValue()`: Database → PHP conversion
   - `convertToDatabaseValue()`: PHP → Database conversion
   - `getName()`: Return unique type name

### Registration
```php
Type::addType('mytype', 'My\Project\Types\MyType');
$conn->getDatabasePlatform()->registerDoctrineTypeMapping('db_mytype', 'mytype');
```

### Usage
```php
class MyPersistentClass
{
    /** @Column(type="mytype") */
    private $field;
}
```

## Decorator Pattern Persistence

Uses Single Table Inheritance strategy for persisting decorator pattern classes.

### Class Hierarchy
- Abstract `Component` (base entity)
- `ConcreteComponent` (concrete implementation)  
- Abstract `Decorator` (mapped superclass)
- `ConcreteDecorator` (specific decorator)

### Persistence Configuration
- `#[InheritanceType('SINGLE_TABLE')]`
- Discriminator column distinguishes component types
- One-to-one association between Decorator and Component
- Cascade persistence for automatic saving

### Example Workflow
```php
$component = new ConcreteComponent();
$component->setName('Test Component');

$decorator = new ConcreteDecorator($component);
$decorator->setSpecial('Really');

$entityManager->persist($decorator);
$entityManager->flush();
```

## DQL Custom Walkers

DQL queries are parsed into Abstract Syntax Tree (AST) before SQL generation.

### Walker Types
1. **Output Walker**: Generates final SQL (only one allowed)
2. **Tree Walker**: Modifies AST before SQL rendering (multiple allowed)

### Use Cases
- Generate count queries for pagination
- Create vendor-specific SQL
- Add dynamic WHERE clauses
- Debug SQL generation

### Example: Pagination Count Walker
Uses `CountSqlWalker` to transform original query into count query, replacing select expressions with distinct count of root entity's primary key.

### Example: MySQL-Specific Output Walker
Extends default `SqlWalker` to add MySQL-specific query hints like `SQL_NO_CACHE`.

## DQL User-Defined Functions

Extends DQL with custom functions in three categories: numeric, string, datetime.

### Function Registration
```php
$config = new \Doctrine\ORM\Configuration();
$config->addCustomStringFunction($name, $class);
$config->addCustomNumericFunction($name, $class);
$config->addCustomDatetimeFunction($name, $class);
```

### Implementation Requirements
Extend `Doctrine\ORM\Query\Node\FunctionNode` with two methods:
1. `parse()`: Handle function parsing
2. `getSql()`: Generate SQL representation

### Example: DateDiff Function
```php
class DateDiff extends FunctionNode
{
    public $firstDateExpression = null;
    public $secondDateExpression = null;

    public function parse(\Doctrine\ORM\Query\Parser $parser)
    {
        $parser->match(TokenType::T_IDENTIFIER);
        $parser->match(TokenType::T_OPEN_PARENTHESIS);
        $this->firstDateExpression = $parser->ArithmeticPrimary();
        $parser->match(TokenType::T_COMMA);
        $this->secondDateExpression = $parser->ArithmeticPrimary();
        $parser->match(TokenType::T_CLOSE_PARENTHESIS);
    }

    public function getSql(\Doctrine\ORM\Query\SqlWalker $sqlWalker)
    {
        return 'DATEDIFF(' .
            $this->firstDateExpression->dispatch($sqlWalker) . ', ' .
            $this->secondDateExpression->dispatch($sqlWalker) .
        ')';
    }
}
```

## Entities in Session

Entities lose "managed" status when serialized in sessions.

### Recommended Approaches

**1. Scalar Value Approach**
```php
session_start();
if (isset($_SESSION['userId']) && is_int($_SESSION['userId'])) {
    $userId = $_SESSION['userId'];
    $em = GetEntityManager();
    $user = $em->find(User::class, $userId);
    $user->setValue($_SESSION['storedValue']);
    $em->flush();
}
```

**2. DTO Approach**
```php
session_start();
if (isset($_SESSION['user']) && $_SESSION['user'] instanceof UserDto) {
    $userDto = $_SESSION['user'];
    $em = GetEntityManager();
    $userEntity = $em->find(User::class, $userDto->getId());
    $userEntity->populateFromDto($userDto);
    $em->flush();
}
```

### Best Practices
- Store only necessary scalar values or DTOs
- Re-fetch and update entities using stored session data
- Avoid serializing entity relationships

## Generated Columns

Database columns automatically populated by the database engine for performance optimization.

### Configuration Attributes
- `insertable` and `updatable`: Set to `false` to prevent manual writes
- `columnDefinition`: Specifies full DDL column creation
- `generated`: Instructs Doctrine to update field after write operations

### Example Configuration
```php
/**
 * @ORM\Column(
 *   insertable=false, 
 *   updatable=false, 
 *   columnDefinition="...",
 *   generated="ALWAYS"
 * )
 */
```

### Use Cases
- JSON field extraction for efficient querying
- Computed values based on other columns
- Performance optimization for complex calculations

## ArrayAccess Implementation

Two primary approaches for implementing ArrayAccess in domain objects:

### Option 1: Direct Property Access
```php
public function offsetGet($offset) {
    return $this->$offset;
}
```
Limitations: Doesn't work with private fields, bypasses getters/setters

### Option 2: Getter/Setter Method Invocation
Dynamic method invocation based on naming conventions.
Limitations: Depends on method naming, challenges with type-hinted setters

### Read-only Variant
Implement `offsetSet` and `offsetUnset` to throw `BadMethodCallException`

## MySQL Enums

### Challenges
- Doctrine doesn't natively support enums
- Adding values requires table rebuilds
- Default validation can silently accept invalid values

### Solution 1: Mapping to Varchars
```php
public function setStatus(string $status): void {
    if (!in_array($status, [self::STATUS_VISIBLE, self::STATUS_INVISIBLE], true)) {
        throw new \InvalidArgumentException("Invalid status");
    }
    $this->status = $status;
}
```

### Solution 2: Custom Enum Type
```php
abstract class EnumType extends Type {
    protected $name;
    protected $values = [];

    public function convertToDatabaseValue(mixed $value, AbstractPlatform $platform): mixed {
        if (!in_array($value, $this->values, true)) {
            throw new \InvalidArgumentException("Invalid '".$this->name."' value.");
        }
        return $value;
    }
}
```

## ResolveTargetEntityListener

Creates independent modules with loose coupling by replacing interface references with concrete entities at runtime.

### Configuration
```php
$evm = new \Doctrine\Common\EventManager;
$rtel = new \Doctrine\ORM\Tools\ResolveTargetEntityListener;

$rtel->addResolveTargetEntity(
    'InvoiceSubjectInterface', 
    'CustomerEntity', 
    array()
);

$evm->addEventListener(
    Doctrine\ORM\Events::loadClassMetadata, 
    $rtel
);
```

### Benefits
- Modular design
- Reduced direct dependencies
- Runtime entity mapping flexibility

### Constraints
- Only one concrete implementation per interface
- Must be configured before EntityManager creation

## SQL Table Prefixes

Implements table prefix listener for separating entities within the same database.

### Implementation
```php
class TablePrefix {
    protected $prefix = '';

    public function __construct($prefix) {
        $this->prefix = (string) $prefix;
    }

    public function loadClassMetadata(LoadClassMetadataEventArgs $eventArgs) {
        $classMetadata = $eventArgs->getClassMetadata();

        $classMetadata->setPrimaryTable([
            'name' => $this->prefix . $classMetadata->getTableName()
        ]);

        foreach ($classMetadata->getAssociationMappings() as $fieldName => $mapping) {
            if ($mapping['type'] == ClassMetadata::MANY_TO_MANY && $mapping['isOwningSide']) {
                $mappedTableName = $mapping['joinTable']['name'];
                $classMetadata->associationMappings[$fieldName]['joinTable']['name'] = $this->prefix . $mappedTableName;
            }
        }
    }
}
```

### Configuration
```php
$evm = new EventManager();
$tablePrefix = new DoctrineExtensions\TablePrefix('prefix_');
$evm->addEventListener(Events::loadClassMetadata, $tablePrefix);
$em = new EntityManager($connection, $config, $evm);
```

## Strategy Pattern Implementation

Design pattern for flexible CMS block/panel structures avoiding expensive inheritance.

### Key Components

**1. BlockStrategyInterface**
- setConfig(), getConfig()
- setView(), renderFrontend(), renderBackend()
- getRequiredPanelTypes(), canUsePanelType()
- setBlockEntity()

**2. AbstractBlock**
- Base class storing strategy class name
- Manages strategy instance
- Methods: getStrategyClassName(), getStrategyInstance(), setStrategy()

**3. BlockStrategyEventListener**
- Doctrine ORM event subscriber
- Initializes block strategies after loading
- Handles strategy instantiation and configuration

### Benefits
- Modular design
- Avoid complex inheritance hierarchies
- Dynamic strategy selection
- Easy extensibility

## Entity Validation

Doctrine ORM supports custom validation through lifecycle event hooks.

### Validation Methods
Triggered during `PrePersist` and `PreUpdate` events:

```php
class Order {
    public function assertCustomerAllowedBuying() {
        $orderLimit = $this->customer->getOrderLimit();
        $amount = 0;
        foreach ($this->orderLines as $line) {
            $amount += $line->getAmount();
        }
        if ($amount > $orderLimit) {
            throw new CustomerOrderLimitExceededException();
        }
    }
}
```

### Complex Validation Example
```php
class Order {
    public function validate() {
        if (!($this->plannedShipDate instanceof DateTime)) {
            throw new ValidateException();
        }
        if ($this->plannedShipDate->format('U') < time()) {
            throw new ValidateException();
        }
        if ($this->customer == null) {
            throw new OrderRequiresCustomerException();
        }
    }
}
```

### Benefits
- Flexible validation approach
- Methods reusable across domain
- Multiple validation methods per event
- Automatic transaction rollback on exceptions

## Working with DateTime

### Key Challenges

**1. Change Detection**
Doctrine detects DateTime changes by reference. Modifying existing DateTime objects won't trigger database updates. Create new DateTime instances to update.

**2. Timezone Considerations**
- Default timezone set by PHP configuration
- Most databases don't fully support timezone storage
- Recommended: Convert all DateTimes to UTC

### UTC Conversion Solution
```php
class UTCDateTimeType extends DateTimeType {
    public function convertToDatabaseValue($value, AbstractPlatform $platform) {
        if ($value instanceof \DateTime) {
            $value->setTimezone(self::getUtc());
        }
        return parent::convertToDatabaseValue($value, $platform);
    }
}

// Register custom type
Type::overrideType('datetime', UTCDateTimeType::class);
```

### Timezone Persistence Example
```php
class Event {
    #[Column(type: 'datetime')]
    private $created;

    #[Column(type: 'string')]
    private $timezone;

    public function __construct(\DateTime $createDate) {
        $this->created = $createDate;
        $this->timezone = $createDate->getTimeZone()->getName();
    }
}
```

### Recommendations
- Always convert DateTime to UTC for storage
- Set timezones only for display purposes
- Store timezone information separately when needed