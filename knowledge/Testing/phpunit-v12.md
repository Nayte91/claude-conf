## Header
- **Source URL**: https://docs.phpunit.de/en/12.3/
- **Processed Date**: 2025-01-25
- **Domain**: docs.phpunit.de
- **Version**: v12.3
- **Weight Reduction**: ~47%
- **Key Sections**: Installation, Test Writing, Assertions, Attributes, Test Doubles, Fixtures, Configuration, Code Coverage

## Body

### Installation and Requirements

#### Requirements
- **PHP 8.3** (recommended latest version)
- **Required Extensions**: json, mbstring, xml
- **Coverage Extensions**: pcov or xdebug

#### Installation Methods

**PHP Archive (PHAR) - Recommended:**
```bash
wget -O phpunit.phar https://phar.phpunit.de/phpunit-10.phar
chmod +x phpunit.phar
./phpunit.phar --version
```

**Composer:**
```bash
composer require --dev phpunit/phpunit
./vendor/bin/phpunit --version
```

**Phive:**
```bash
phive install phpunit
./tools/phpunit --version
```

#### Configuration Recommendations
```ini
display_errors=On
display_startup_errors=On
error_reporting=-1
xdebug.mode=coverage
zend.assertions=1
assert.exception=1
memory_limit=-1
```

### Test Class Structure

#### Basic Structure
```php
use PHPUnit\Framework\TestCase;

final class [ClassName]Test extends TestCase {
    public function testSpecificBehavior(): void {
        // Test implementation
    }
    
    #[Test]
    public function alternativeTestMethod(): void {
        // Alternative with attribute
    }
}
```

### Core Assertions Reference

#### Boolean Assertions
```php
assertTrue(bool $condition[, string $message])
assertFalse(bool $condition[, string $message])
```

#### Identity Assertions
```php
assertSame(mixed $expected, mixed $actual[, string $message])  // Uses ===
```

#### Equality Assertions
```php
assertEquals(mixed $expected, mixed $actual[, string $message])           // Uses ==
assertEqualsCanonicalizing(mixed $expected, mixed $actual[, string $message])  // Sorts before comparison
assertEqualsIgnoringCase(mixed $expected, mixed $actual[, string $message])    // Case-insensitive
assertEqualsWithDelta(mixed $expected, mixed $actual, float $delta[, string $message])  // Float tolerance
```

#### Exception Testing
```php
public function testException(): void {
    $this->expectException(SpecificException::class);
    $this->expectExceptionMessage('Expected message');
    // Code expected to throw exception
}
```

### Data Providers

#### Static Data Provider
```php
public static function dataProvider(): array {
    return [
        'descriptive_name' => [arg1, arg2, expected],
        'another_case' => [arg3, arg4, expected2]
    ];
}

#[DataProvider('dataProvider')]
public function testMethod($arg1, $arg2, $expected): void {
    $this->assertSame($expected, actualResult);
}
```

#### Inline Data Provider
```php
#[TestWith([0, 0, 0])]
#[TestWith([1, 2, 3])]
public function testAddition(int $a, int $b, int $expected): void {
    $this->assertSame($expected, $a + $b);
}
```

### Test Dependencies

```php
public function testProducerMethod(): array {
    // Prepare and return fixture
    return ['fixture_data'];
}

#[Depends('testProducerMethod')]
public function testConsumerMethod(array $fixture): void {
    // Use fixture from previous test
    $this->assertNotEmpty($fixture);
}
```

### Key Attributes Reference

#### Test Configuration
- **`#[Test]`** - Marks method as test
- **`#[TestDox('Custom description')]`** - Customizes test description
- **`#[Group('integration')]`** - Assigns tests to groups
- **`#[Small]`, `#[Medium]`, `#[Large]`** - Performance classification

#### Data Providers
- **`#[DataProvider('methodName')]`** - Specifies data source
- **`#[TestWith([arg1, arg2])]`** - Inline data
- **`#[TestWithJson('{"key": "value"}')]`** - JSON data

#### Conditional Execution
- **`#[RequiresPhp('>=8.1')]`** - PHP version requirement
- **`#[RequiresPhpExtension('extension_name')]`** - Extension requirement
- **`#[RequiresOperatingSystem('Linux')]`** - OS requirement

#### Code Coverage
- **`#[CoversClass(ClassName::class)]`** - Coverage target
- **`#[CoversNothing]`** - Exclude from coverage
- **`#[UsesClass(ClassName::class)]`** - Acknowledge usage

### Test Doubles (Mocks & Stubs)

#### Stub Creation
```php
// Basic stub
$stub = $this->createStub(SomeClass::class);

// Configured stub
$stub = $this->createConfiguredStub(SomeClass::class, [
    'methodName' => 'returnValue'
]);

// Method configuration
$stub->method('methodName')
     ->willReturn('value');
     
$stub->method('methodName')
     ->willThrowException(new Exception('message'));
```

#### Mock Creation and Expectations
```php
// Basic mock
$mock = $this->createMock(SomeClass::class);

// Method expectations
$mock->expects($this->once())
     ->method('methodName')
     ->with('expectedArg')
     ->willReturn('returnValue');

// Configured mock
$mock = $this->createConfiguredMock(SomeClass::class, [
    'methodName' => 'returnValue'
]);
```

#### Expectation Matchers
- **`$this->any()`** - Any number of invocations
- **`$this->never()`** - Never invoked
- **`$this->once()`** - Exactly one invocation
- **`$this->atLeastOnce()`** - One or more invocations

### Fixtures and Setup

#### Setup Methods
```php
protected function setUp(): void {
    parent::setUp();
    // Runs before each test method
}

protected function tearDown(): void {
    // Runs after each test method
    parent::tearDown();
}

public static function setUpBeforeClass(): void {
    parent::setUpBeforeClass();
    // Runs once before all tests in class
}

public static function tearDownAfterClass(): void {
    // Runs once after all tests in class
    parent::tearDownAfterClass();
}
```

#### Test Isolation Attributes
- **`#[BackupGlobals]`** - Backup/restore globals
- **`#[RunInSeparateProcess]`** - Process isolation
- **`#[PreserveGlobalState]`** - Control global state

### XML Configuration

#### Basic Configuration
```xml
<phpunit bootstrap="vendor/autoload.php"
         colors="true"
         stopOnFailure="false">
    <testsuites>
        <testsuite name="unit">
            <directory>tests/unit</directory>
        </testsuite>
    </testsuites>
    <source>
        <include>
            <directory suffix=".php">src</directory>
        </include>
    </source>
</phpunit>
```

#### Key Configuration Attributes
- **`bootstrap`** - Initialization script
- **`colors`** - Console color output
- **`stopOnFailure`** - Halt on first failure
- **`processIsolation`** - Separate processes
- **`cacheDirectory`** - Cache location

### Code Coverage

#### Requirements
- **Extensions**: PCOV or Xdebug
- **Xdebug needed** for branch/path coverage

#### Coverage Metrics
- **Line Coverage** - Executable lines executed
- **Branch Coverage** - Boolean expressions evaluation
- **Path Coverage** - Unique execution paths
- **Method Coverage** - Function invocations
- **CRAP Index** - Complexity and coverage risk

#### Reporting Formats
- **HTML** - Interactive web reports
- **XML** - Clover, Cobertura, Crap4J
- **Text** - Console output

#### Ignore Mechanisms
```php
// @codeCoverageIgnore
public function debugMethod() {
    // Excluded from coverage
}

// @codeCoverageIgnoreStart
public function legacyMethod() {
    // Block excluded from coverage
}
// @codeCoverageIgnoreEnd
```

### Test Management

#### Skipping Tests
```php
$this->markTestSkipped('Requires external service');
$this->markTestIncomplete('Not yet implemented');
```

#### Output Testing
```php
public function testOutput(): void {
    $this->expectOutputString('expected output');
    echo 'expected output';
}
```

### Best Practices

#### Test Design
- **Use descriptive test method names**
- **Follow Arrange-Act-Assert pattern**
- **One assertion per test when possible**
- **Prefer dependency injection over global state**

#### Mock Usage
- **Mock interfaces over classes**
- **Use test doubles to isolate system under test**
- **Verify indirect outputs and interactions**

#### Performance
- **Use appropriate test size attributes**
- **Avoid shared fixtures between tests**
- **Prefer unit tests over integration tests**