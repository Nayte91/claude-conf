## Header
- **Source**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/components/dependency_injection.rst
- **Processed Date**: 2025-09-01
- **Domain**: symfony.com
- **Version**: v7.3
- **Weight Reduction**: ~85%
- **Key Sections**: v7.3 Container Architecture, Service Configuration, Compiler Passes, Advanced Patterns

## Body

### Symfony 7.3 DI Installation

```bash
composer require symfony/dependency-injection
composer require symfony/config  # For configuration loaders
composer require symfony/yaml    # For YAML support
```

### Symfony 7.3 Container Building

```php
use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Reference;

$container = new ContainerBuilder();

// Service registration (v7.3)
$container->register('mailer', 'Mailer')
          ->addArgument('sendmail');

$container->register('newsletter_manager', 'NewsletterManager')
          ->addArgument(new Reference('mailer'));

// Compile for production (v7.3)
$container->compile();
```

### Symfony 7.3 Configuration Loaders

```php
use Symfony\Component\Config\FileLocator;
use Symfony\Component\DependencyInjection\Loader\{XmlFileLoader, YamlFileLoader, PhpFileLoader};

// v7.3 configuration loading
$loader = new YamlFileLoader($container, new FileLocator(__DIR__));
$loader->load('services.yaml');

$loader = new XmlFileLoader($container, new FileLocator(__DIR__));
$loader->load('services.xml');

$loader = new PhpFileLoader($container, new FileLocator(__DIR__));
$loader->load('services.php');
```

### Symfony 7.3 YAML Configuration

```yaml
# config/services.yaml (v7.3 format)
parameters:
    mailer.transport: sendmail

services:
    mailer:
        class: Mailer
        arguments:
            - '%mailer.transport%'
    
    newsletter_manager:
        class: NewsletterManager
        arguments:
            - '@mailer'
        lazy: true              # v7.3: Lazy loading
        shared: false           # v7.3: Prototype pattern
```

### Symfony 7.3 XML Configuration

```xml
<!-- config/services.xml (v7.3 format) -->
<services>
    <parameters>
        <parameter key="mailer.transport">sendmail</parameter>
    </parameters>
    
    <services>
        <service id="mailer" class="Mailer">
            <argument>%mailer.transport%</argument>
        </service>
        
        <service id="newsletter_manager" class="NewsletterManager" lazy="true">
            <argument type="service" id="mailer"/>
        </service>
    </services>
</services>
```

### Symfony 7.3 Reference Behaviors

```php
use Symfony\Component\DependencyInjection\ContainerInterface;

// v7.3 reference types
new Reference('service', ContainerInterface::EXCEPTION_ON_INVALID_REFERENCE);
new Reference('service', ContainerInterface::RUNTIME_EXCEPTION_ON_INVALID_REFERENCE);
new Reference('service', ContainerInterface::NULL_ON_INVALID_REFERENCE);
new Reference('service', ContainerInterface::IGNORE_ON_INVALID_REFERENCE);
new Reference('service', ContainerInterface::IGNORE_ON_UNINITIALIZED_REFERENCE);
```

### Symfony 7.3 Service Factories

```php
// v7.3 factory patterns
$container->register('logger', Logger::class)
          ->setFactory([Logger::class, 'createLogger'])
          ->addArgument('/var/log/app.log');

// Service factory
$container->register('logger_factory', LoggerFactory::class);
$container->register('logger', Logger::class)
          ->setFactory([new Reference('logger_factory'), 'create']);
```

### Symfony 7.3 Service Decoration

```php
// v7.3 decoration pattern
$container->register('original_service', OriginalService::class);

$container->register('decorated_service', DecoratedService::class)
          ->setDecoratedService('original_service')
          ->addArgument(new Reference('decorated_service.inner'));
```

### Symfony 7.3 Tagged Services

```yaml
# v7.3 service tagging
services:
    app.handler.foo:
        class: FooHandler
        tags:
            - { name: app.handler, priority: 10 }
    
    app.handler.bar:
        class: BarHandler
        tags:
            - { name: app.handler, priority: 5 }
```

### Symfony 7.3 Compiler Pass

```php
use Symfony\Component\DependencyInjection\Compiler\CompilerPassInterface;
use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Reference;

// v7.3 compiler pass implementation
class HandlerPass implements CompilerPassInterface
{
    public function process(ContainerBuilder $container): void
    {
        if (!$container->has('app.handler_collection')) {
            return;
        }
        
        $definition = $container->findDefinition('app.handler_collection');
        $taggedServices = $container->findTaggedServiceIds('app.handler');
        
        foreach ($taggedServices as $id => $tags) {
            $definition->addMethodCall('addHandler', [new Reference($id)]);
        }
    }
}
```

### Symfony 7.3 Performance Features

```php
// v7.3 performance optimizations
$container->compile(true); // Remove unused definitions

// Lazy services
$container->register('expensive_service', ExpensiveService::class)
          ->setLazy(true);

// Prototype services
$container->register('prototype_service', Service::class)
          ->setShared(false);
```

### Symfony 7.3 Parameter Management

```php
// v7.3 parameter handling
$container->setParameter('app.name', 'My Application');
$container->setParameter('app.config', ['debug' => true, 'locale' => 'en']);
$container->setParameter('database.host', '%env(DATABASE_HOST)%');

// Parameter resolution
$appName = $container->getParameter('app.name');
$hasParam = $container->hasParameter('optional.param');
```

### Symfony 7.3 Service Aliasing

```php
// v7.3 service aliases
$container->setAlias('app.mailer', 'mailer');

// Public alias
$container->setAlias('public_service', 'private_service')
          ->setPublic(true);
```

### Symfony 7.3 Error Handling

```php
use Symfony\Component\DependencyInjection\Exception\{ServiceNotFoundException, InvalidArgumentException};

// v7.3 exception handling
try {
    $service = $container->get('non_existent_service');
} catch (ServiceNotFoundException $e) {
    // Handle missing service
}

try {
    $container->setParameter('', 'value');
} catch (InvalidArgumentException $e) {
    // Handle invalid parameter
}
```

### Symfony 7.3 Debug Information

```php
// v7.3 introspection methods
$serviceIds = $container->getServiceIds();
$parameters = $container->getParameterBag()->all();
$isPublic = $container->findDefinition('service_id')->isPublic();
```