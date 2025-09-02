## Header
- **Source**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/testing.rst
- **Processed Date**: 2025-01-25
- **Domain**: symfony/symfony-docs
- **Version**: v73
- **Weight Reduction**: ~46%
- **Key Sections**: Test Types, PHPUnit Configuration, Database Testing, Authentication, HTTP Testing, Performance, Fixtures

## Body

### Symfony 7.3 Test Classes

#### KernelTestCase (7.3)
```php
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;

class ServiceTest extends KernelTestCase
{
    protected function setUp(): void
    {
        self::bootKernel();
        $this->container = static::getContainer();
    }
}
```

#### WebTestCase (7.3)
```php
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;

class ControllerTest extends WebTestCase
{
    public function testRoute(): void
    {
        $client = static::createClient();
        $client->request('GET', '/path');
        $this->assertResponseIsSuccessful();
    }
}
```

### Database Testing (Symfony 7.3)

#### DAMA Doctrine Bundle
```yaml
# config/packages/test/dama_doctrine_test_bundle.yaml
dama_doctrine_test_bundle:
    enable_static_connection: true
    enable_static_meta_data_cache: true
```

#### Test Database Configuration
```env
# .env.test
DATABASE_URL="sqlite:///%kernel.project_dir%/var/test.db"
```

### Authentication Testing (7.3)

```php
public function testAuthenticatedUser(): void
{
    $client = static::createClient();
    $user = $this->entityManager->find(User::class, 1);
    $client->loginUser($user);
    
    $client->request('GET', '/profile');
    $this->assertResponseIsSuccessful();
}
```

### HTTP Testing Assertions (7.3)

```php
// Response status
$this->assertResponseIsSuccessful();
$this->assertResponseStatusCodeSame(404);
$this->assertResponseRedirects('/login');

// DOM content
$this->assertSelectorExists('form[name="user"]');
$this->assertSelectorTextContains('h1', 'Welcome');

// JSON responses
$this->assertJsonContains(['status' => 'ok']);
$this->assertJsonEquals(['data' => []]);
```

### Service Container Testing (7.3)

```php
protected function setUp(): void
{
    self::bootKernel();
    $this->service = static::getContainer()->get(MyService::class);
}

// Service mocking
$mockService = $this->createMock(ExternalService::class);
static::getContainer()->set(ExternalService::class, $mockService);
```

### Profiler Integration (7.3)

```php
$client = static::createClient();
$client->enableProfiler();
$client->request('GET', '/send-email');

$mailCollector = $client->getProfile()->getCollector('swiftmailer');
$this->assertEmailCount(1);
```

### Test Environment Configuration

```yaml
# config/packages/test/framework.yaml
framework:
    test: true
    session:
        storage_factory_id: session.storage.factory.mock_file
    profiler:
        enabled: false
```