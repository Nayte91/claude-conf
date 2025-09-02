# PHP Patterns & Idioms Reference

This comprehensive reference consolidates essential PHP patterns and Symfony conventions for modern development.

## Table of Contents
1. [Control Flow Patterns](#control-flow-patterns)
2. [Null Handling](#null-handling)
3. [Object Creation](#object-creation)
4. [Data Objects](#data-objects)
5. [Collections & Iteration](#collections--iteration)
6. [Functional Programming](#functional-programming)
7. [Behavioral Patterns](#behavioral-patterns)
8. [Architecture Patterns](#architecture-patterns)
9. [Modern PHP Features](#modern-php-features)
10. [Symfony Conventions](#symfony-conventions)

---

## Control Flow Patterns

### Guard Clause
**Purpose:** Exit early from function if conditions are invalid
**Usage:** Avoid deep nesting and make intentions clear
```php
function processUser(User $user): void {
    if (!$user->isActive()) return;
    if (!$user->hasPermissions()) return;
    
    $user->performAction();
}
```

### Early Return
**Purpose:** Return result immediately when it's determined
**Usage:** Simplify conditional logic
```php
function getDiscount(string $tier): float {
    if ($tier === 'premium') return 0.20;
    if ($tier === 'gold') return 0.15;
    return 0.05;
}
```

### Fail Fast
**Purpose:** Throw exceptions immediately when detecting invalid state
**Usage:** Make errors visible early in development
```php
function setAge(int $age): void {
    if ($age < 0) throw new \InvalidArgumentException('Age cannot be negative');
    $this->age = $age;
}
```

---

## Null Handling

### Null Coalesce
**Purpose:** Provide default values for null variables
**Usage:** Avoid verbose null checks
```php
$username = $user->nickname ?? $user->email ?? 'Anonymous';
```

### Nullsafe Operator
**Purpose:** Chain method calls safely without null errors
**Usage:** Access nested properties that might be null
```php
$city = $user->getAddress()?->getCity()?->getName();
```

### Null Object
**Purpose:** Replace null values with neutral objects
**Usage:** Eliminate null checks throughout codebase
```php
class NullUser implements UserInterface {
    public function getName(): string { return 'Guest'; }
    public function hasPermission(): bool { return false; }
}
```

---

## Object Creation

### Named Constructor
**Purpose:** Create objects with clear intent
**Usage:** Multiple ways to instantiate the same class
```php
class User {
    private function __construct(string $name, string $email) {}
    
    public static function fromRegistration(string $name, string $email): self {
        return new self($name, $email);
    }
    
    public static function fromJson(string $json): self {
        $data = json_decode($json, true);
        return new self($data['name'], $data['email']);
    }
}
```

### Static Factory
**Purpose:** Centralize object creation logic
**Usage:** Complex instantiation scenarios
```php
class DatabaseConnection {
    public static function mysql(string $host): self {
        return new self("mysql:host=$host");
    }
    
    public static function sqlite(string $path): self {
        return new self("sqlite:$path");
    }
}
```

### Lazy Initialization
**Purpose:** Create expensive objects only when needed
**Usage:** Optimize memory and performance
```php
class Service {
    private ?ExpensiveResource $resource = null;
    
    private function getResource(): ExpensiveResource {
        return $this->resource ??= new ExpensiveResource();
    }
}
```

### Singleton
**Purpose:** Ensure single instance of a class
**Usage:** Shared resources or state management
```php
class Logger {
    private static ?self $instance = null;
    
    public static function getInstance(): self {
        return self::$instance ??= new self();
    }
}
```

### Builder Pattern
**Purpose:** Construct complex objects step by step
**Usage:** Objects with many optional parameters
```php
class QueryBuilder {
    public function select(string $fields): self { /* ... */ return $this; }
    public function from(string $table): self { /* ... */ return $this; }
    public function where(string $condition): self { /* ... */ return $this; }
    public function build(): Query { return new Query($this->parts); }
}
```

---

## Data Objects

### Value Object
**Purpose:** Represent values with behavior, ensure immutability
**Usage:** Domain concepts like Money, Email, etc.
```php
final class Email {
    public function __construct(private string $value) {
        if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
            throw new \InvalidArgumentException('Invalid email');
        }
    }
    
    public function getValue(): string { return $this->value; }
}
```

### DTO (Data Transfer Object)
**Purpose:** Simple data containers for transferring data
**Usage:** API responses, form data, inter-layer communication
```php
readonly class UserDto {
    public function __construct(
        public string $name,
        public string $email,
        public int $age
    ) {}
}
```

### Hydration Pattern
**Purpose:** Populate objects from arrays/external data
**Usage:** Form processing, API data mapping
```php
class UserHydrator {
    public function hydrate(array $data): User {
        return new User(
            name: $data['name'],
            email: $data['email'],
            age: $data['age']
        );
    }
}
```

### Immutability
**Purpose:** Prevent object modification after creation
**Usage:** Thread safety, predictable behavior
```php
class ImmutableUser {
    public function __construct(
        private string $name,
        private int $age
    ) {}
    
    public function withAge(int $newAge): self {
        return new self($this->name, $newAge);
    }
}
```

---

## Collections & Iteration

### Collection Wrapper
**Purpose:** Add domain-specific methods to arrays
**Usage:** Encapsulate collection behavior
```php
class UserCollection {
    public function __construct(private array $users) {}
    
    public function getActive(): self {
        return new self(array_filter($this->users, fn($u) => $u->isActive()));
    }
    
    public function averageAge(): float {
        return array_sum(array_map(fn($u) => $u->getAge(), $this->users)) / count($this->users);
    }
}
```

### Iterator Implementation
**Purpose:** Make objects iterable with foreach
**Usage:** Custom iteration logic
```php
class UserCollection implements \IteratorAggregate {
    public function getIterator(): \Traversable {
        yield from $this->users;
    }
}
```

### Array Access
**Purpose:** Make objects behave like arrays
**Usage:** Convenient array-like syntax
```php
class Configuration implements \ArrayAccess {
    private array $data = [];
    
    public function offsetGet($key) { return $this->data[$key] ?? null; }
    public function offsetSet($key, $value) { $this->data[$key] = $value; }
    // ... other ArrayAccess methods
}
```

---

## Functional Programming

### Pipeline
**Purpose:** Chain transformations in sequence
**Usage:** Data processing workflows
```php
$result = collect($data)
    ->map(fn($item) => strtoupper($item))
    ->filter(fn($item) => strlen($item) > 3)
    ->unique()
    ->toArray();
```

### Callback Strategy
**Purpose:** Pass behavior as parameters
**Usage:** Flexible algorithms
```php
class Processor {
    public function process(array $items, callable $transformer): array {
        return array_map($transformer, $items);
    }
}

$processor->process($users, fn($user) => $user->getName());
```

### First-Class Callable
**Purpose:** Use method references directly
**Usage:** Cleaner callback syntax (PHP 8.1+)
```php
$names = array_map($user->getName(...), $users);
```

### Functional Composition
**Purpose:** Combine simple functions into complex operations
**Usage:** Reusable data transformations
```php
$processedData = array_map(
    'strtoupper',
    array_filter($data, fn($item) => strlen($item) > 2)
);
```

---

## Behavioral Patterns

### Method Chaining / Fluent Interface
**Purpose:** Enable method call chains
**Usage:** Configuration, building complex operations
```php
class QueryBuilder {
    public function where(string $field, $value): self {
        $this->conditions[] = [$field, $value];
        return $this;
    }
    
    public function orderBy(string $field): self {
        $this->order = $field;
        return $this;
    }
}

$query = $builder->where('status', 'active')->orderBy('created_at');
```

### Method Proxy / Magic Forwarding
**Purpose:** Delegate method calls to another object
**Usage:** Decorators, adapters
```php
class ProxyService {
    public function __call(string $method, array $args) {
        return $this->realService->$method(...$args);
    }
}
```

### Command Pattern
**Purpose:** Encapsulate requests as objects
**Usage:** Queue operations, undo functionality
```php
class SendEmailCommand {
    public function __construct(
        private string $to,
        private string $subject,
        private string $body
    ) {}
    
    public function execute(): void {
        // Send email logic
    }
}
```

### Observer Pattern
**Purpose:** Notify multiple objects about events
**Usage:** Event systems, model changes
```php
class EventDispatcher {
    private array $listeners = [];
    
    public function addListener(string $event, callable $listener): void {
        $this->listeners[$event][] = $listener;
    }
    
    public function dispatch(string $event, $data = null): void {
        foreach ($this->listeners[$event] ?? [] as $listener) {
            $listener($data);
        }
    }
}
```

### Retry Pattern
**Purpose:** Automatically retry failed operations
**Usage:** Network calls, external services
```php
function retry(callable $operation, int $maxAttempts = 3): mixed {
    for ($i = 0; $i < $maxAttempts; $i++) {
        try {
            return $operation();
        } catch (Exception $e) {
            if ($i === $maxAttempts - 1) throw $e;
            usleep(100000 * $i); // Exponential backoff
        }
    }
}
```

---

## Architecture Patterns

### Repository
**Purpose:** Encapsulate data access logic
**Usage:** Abstract database operations
```php
interface UserRepositoryInterface {
    public function find(int $id): ?User;
    public function save(User $user): void;
    public function findByEmail(string $email): ?User;
}

class DatabaseUserRepository implements UserRepositoryInterface {
    public function find(int $id): ?User {
        // Database query logic
    }
}
```

### Active Record
**Purpose:** Combine data and behavior in domain objects
**Usage:** Simple CRUD operations
```php
class User {
    public static function find(int $id): ?self {
        // Database query
    }
    
    public function save(): void {
        // Persist to database
    }
    
    public function delete(): void {
        // Remove from database
    }
}
```

### Data Mapper
**Purpose:** Separate data access from business logic
**Usage:** Complex data transformations
```php
class UserMapper {
    public function mapToEntity(array $row): User {
        return new User(
            id: $row['id'],
            name: $row['name'],
            email: $row['email']
        );
    }
    
    public function mapToArray(User $user): array {
        return [
            'id' => $user->getId(),
            'name' => $user->getName(),
            'email' => $user->getEmail()
        ];
    }
}
```

### CQRS (Command Query Responsibility Segregation)
**Purpose:** Separate read and write operations
**Usage:** Complex domains, scalable architectures
```php
// Command side (writes)
$commandBus->dispatch(new RegisterUser('John', 'john@example.com'));

// Query side (reads)
$user = $queryBus->ask(new FindUserByEmail('john@example.com'));
```

### Event Sourcing
**Purpose:** Store state changes as events
**Usage:** Audit trails, complex business rules
```php
$events = [
    new UserRegistered('john@example.com'),
    new UserEmailVerified(),
    new UserProfileUpdated(['name' => 'John Doe'])
];

$user = User::fromEvents($events);
```

### Transaction Script
**Purpose:** Simple procedural approach for business logic
**Usage:** Simple applications, quick prototypes
```php
function processOrder(OrderData $orderData): void {
    startTransaction();
    try {
        $order = createOrder($orderData);
        updateInventory($order);
        sendConfirmation($order);
        commit();
    } catch (Exception $e) {
        rollback();
        throw $e;
    }
}
```

---

## Modern PHP Features

### Match Expression (PHP 8.0)
**Purpose:** Improved switch statements
**Usage:** Value-based branching
```php
$result = match($status) {
    'pending' => 'Waiting for approval',
    'approved', 'active' => 'Ready to go',
    'rejected' => 'Access denied',
    default => 'Unknown status'
};
```

### Readonly Properties (PHP 8.1)
**Purpose:** Prevent property modification after initialization
**Usage:** Immutable data structures
```php
class User {
    public function __construct(
        public readonly string $name,
        public readonly string $email
    ) {}
}
```

### Enums (PHP 8.1)
**Purpose:** Define sets of named constants
**Usage:** Type-safe constants, state representation
```php
enum Status: string {
    case PENDING = 'pending';
    case APPROVED = 'approved';
    case REJECTED = 'rejected';
    
    public function isActive(): bool {
        return $this === self::APPROVED;
    }
}
```

### Attributes (PHP 8.0)
**Purpose:** Add metadata to classes, methods, properties
**Usage:** Frameworks, annotations replacement
```php
#[Entity(table: 'users')]
class User {
    #[Column(type: 'string')]
    public string $name;
    
    #[Route('/api/users/{id}')]
    public function show(int $id): Response {
        // Controller logic
    }
}
```

### Named Arguments (PHP 8.0)
**Purpose:** Pass arguments by parameter name
**Usage:** Improve readability, skip optional parameters
```php
$user = new User(
    name: 'John Doe',
    email: 'john@example.com',
    active: true
);
```

### Union Types (PHP 8.0)
**Purpose:** Accept multiple types for parameters
**Usage:** Flexible APIs, gradual typing
```php
function processId(int|string $id): User {
    if (is_string($id)) {
        $id = (int) $id;
    }
    return User::find($id);
}
```

### Promoted Constructor Properties (PHP 8.0)
**Purpose:** Declare and initialize properties in constructor
**Usage:** Reduce boilerplate code
```php
class User {
    public function __construct(
        private string $name,
        private string $email,
        private bool $active = true
    ) {}
}
```

---

## Symfony Conventions

### Naming Conventions

#### camelCase
**Usage:** Methods and variables
```php
$userService->processRegistration();
$firstName = 'John';
```

#### snake_case
**Usage:** Twig variables, configuration parameters
```twig
{{ user_name }} registered on {{ registration_date }}
```

#### SCREAMING_SNAKE_CASE
**Usage:** Constants
```php
class User {
    public const MAX_LOGIN_ATTEMPTS = 3;
    public const DEFAULT_ROLE = 'user';
}
```

#### UpperCamelCase
**Usage:** Classes, interfaces, traits, enums
```php
class UserService {}
interface UserRepositoryInterface {}
trait Timestampable {}
enum UserStatus {}
```

### Service Configuration

#### Service Naming
**Convention:** Use fully qualified class names as service IDs
```yaml
services:
    App\Service\UserRegistrationService: ~
    App\Repository\UserRepository: ~
```

#### Private Services
**Convention:** Services are private by default unless explicitly public
```yaml
services:
    App\Service\EmailService:
        public: false
    
    App\Controller\ApiController:
        public: true  # Controllers must be public
```

### Form Conventions

#### Form Types as Classes
**Purpose:** Reusable form definitions
```php
class UserType extends AbstractType {
    public function buildForm(FormBuilderInterface $builder, array $options): void {
        $builder
            ->add('name', TextType::class)
            ->add('email', EmailType::class);
    }
}
```

#### Form Buttons in Templates
**Purpose:** Separate concerns, flexible styling
```twig
{{ form_start(form) }}
{{ form_widget(form) }}
<button type="submit" class="btn-primary">Save</button>
{{ form_end(form) }}
```

### Template Conventions

#### Partial Templates
**Convention:** Prefix partial templates with underscore
```twig
{% include '_user_profile.html.twig' %}
{% include '_navigation.html.twig' %}
```

#### Twig Variables
**Convention:** Use snake_case for template variables
```twig
{{ user_profile.first_name }}
{{ current_date|date('Y-m-d') }}
```

### Translation Conventions

#### Translation Keys
**Convention:** Use keys instead of literal text
```php
$this->translator->trans('user.welcome', ['%name%' => $user->getName()]);
```

```xliff
<trans-unit id="user.welcome">
    <source>user.welcome</source>
    <target>Welcome, %name%!</target>
</trans-unit>
```

### Command Conventions

#### Command Attributes
**Convention:** Use descriptive command names and help
```php
#[AsCommand(
    name: 'app:user:cleanup',
    description: 'Remove inactive users older than specified days'
)]
class UserCleanupCommand extends Command {
    protected function execute(InputInterface $input, OutputInterface $output): int {
        // Command logic
        return Command::SUCCESS;
    }
}
```

---

## Quick Reference Index

**A**: Attributes, Active Record, Array Access  
**B**: Builder Pattern  
**C**: CQRS, Collection Wrapper, Command Pattern, Callback Strategy  
**D**: DTO, Data Mapper  
**E**: Early Return, Enums, Event Sourcing  
**F**: Fail Fast, Fluent Interface, First-Class Callable, Functional Composition  
**G**: Guard Clause  
**H**: Hydration Pattern  
**I**: Immutability, Iterator  
**L**: Lazy Initialization  
**M**: Match Expression, Method Chaining, Method Proxy  
**N**: Named Constructor, Named Arguments, Null Object, Null Coalesce, Nullsafe Operator  
**O**: Observer Pattern  
**P**: Pipeline, Promoted Properties  
**R**: Readonly Properties, Repository, Retry Pattern  
**S**: Singleton, Static Factory  
**T**: Transaction Script  
**U**: Union Types  
**V**: Value Object