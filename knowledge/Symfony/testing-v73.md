## Header
- **Source URL**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/testing.rst
- **Processed Date**: 2025-01-25
- **Domain**: symfony/symfony-docs
- **Version**: v73
- **Weight Reduction**: ~46%
- **Key Sections**: Test Types, PHPUnit Configuration, Database Testing, Authentication, HTTP Testing, Performance, Fixtures

## Body

### Test Types and Architecture

#### 1. Unit Tests
- **Validate individual code units** (classes/methods)
- **Isolated testing** of specific functionality
- **Location**: matching directory structure (e.g. `tests/Form/` mirrors `src/Form/`)

#### 2. Integration Tests
- **Test service interactions** and container dependencies
- **Use `KernelTestCase`** for kernel bootstrapping
- **Access services** via `static::getContainer()`

#### 3. Functional/Application Tests
- **Simulate complete application** workflow
- **Use `WebTestCase`** for browser simulation
- **Test routing, controllers**, and full request/response cycles

### Core Testing Configuration
- **Install**: `composer require --dev symfony/test-pack`
- **PHPUnit configured** through `phpunit.dist.xml`
- **Test environment isolated** via `.env.test`

### Database Testing Strategies

#### 1. Dedicated Test Database
- **Create separate database** for tests
- **Configure** via `DATABASE_URL` in `.env.test.local`
- **Use**: `doctrine:database:create --env=test`

#### 2. Transaction Isolation
- **Use `DAMADoctrineTestBundle`** for automatic rollbacks
- **Prevents test interdependencies**

#### 3. Fixtures Management
- **Load test data** using `doctrine/doctrine-fixtures-bundle`
- **Create fixture classes** to populate test database

### Authentication Testing
- **Use `$client->loginUser()`** for simulated authentication
- **Create dedicated test users**
- **Support**: in-memory and repository-based user loading

### Request/Response Testing

#### Key Assertions
- **`assertResponseIsSuccessful()`**
- **`assertResponseStatusCodeSame()`**
- **`assertResponseRedirects()`**
- **`assertSelectorExists()`**
- **`assertSelectorTextContains()`**

### Advanced Testing Techniques

#### 1. Mocking Dependencies
- **Replace service implementations** dynamically
- **Use `$this->createMock()`** for dependency substitution

#### 2. HTTP Client Testing
- **Enable profiler** with `$client->enableProfiler()`
- **Assert HTTP request characteristics**
- **Validate external service** interactions

### Performance Optimization
- **Disable kernel reboot** for multi-request tests
- **Use compiler passes** to optimize service reset
- **Configure test environment** for optimal performance