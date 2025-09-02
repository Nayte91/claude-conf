## Header
- **Source**: https://symfony.com/doc/current/components/event_dispatcher.html
- **Processed Date**: 2025-08-31
- **Domain**: symfony.com
- **Version**: v7.3
- **Weight Reduction**: 42%
- **Key Sections**: Event Architecture, Listener Registration, Event Subscribers, Event Dispatching, Immutable/Traceable Dispatchers

## Body

### Core Architecture

The EventDispatcher component implements Mediator and Observer design patterns, enabling application components to communicate through event-driven mechanisms. It solves extensibility challenges by allowing behavior modification without direct code changes or complex inheritance.

**Key Components:**
1. Event Dispatcher - Central registry managing listeners
2. Events - Named occurrences with associated data
3. Listeners - Callables responding to events  
4. Subscribers - Classes defining multiple event subscriptions

### Installation

```bash
$ composer require symfony/event-dispatcher
```

### Event Creation

Events are identified by unique names and can include custom Event objects containing contextual data:

```php
namespace Acme\Store\Event;

use Acme\Store\Order;
use Symfony\Contracts\EventDispatcher\Event;

final class OrderPlacedEvent extends Event
{
    public function __construct(private Order $order) {}

    public function getOrder(): Order
    {
        return $this->order;
    }
}
```

### Event Dispatching

```php
use Symfony\Component\EventDispatcher\EventDispatcher;

$dispatcher = new EventDispatcher();
$order = new Order();
$event = new OrderPlacedEvent($order);
$dispatcher->dispatch($event);
```

### Listener Registration

#### Direct Listener Registration
```php
$dispatcher->addListener('acme.foo.action', [$listener, 'onFooAction']);
$dispatcher->addListener('event_name', function(Event $event) {
    // Event handling logic
}, $priority);
```

#### Closure-based Registration
```php
$dispatcher->addListener('event_name', function(Event $event) {
    // Handle event
});
```

### Event Subscribers

Subscribers implement `EventSubscriberInterface` to define multiple event subscriptions:

```php
use Symfony\Component\EventDispatcher\EventSubscriberInterface;

class StoreSubscriber implements EventSubscriberInterface
{
    public static function getSubscribedEvents(): array
    {
        return [
            // Multiple methods with priorities
            KernelEvents::RESPONSE => [
                ['onKernelResponsePre', 10],
                ['onKernelResponsePost', -10],
            ],
            // Single method
            OrderPlacedEvent::class => 'onPlacedOrder',
            // Alternative syntax
            'event_name' => ['methodName', priority]
        ];
    }
    
    public function onKernelResponsePre($event): void {}
    public function onKernelResponsePost($event): void {}
    public function onPlacedOrder(OrderPlacedEvent $event): void {}
}
```

**Subscriber Registration:**
```php
$dispatcher->addSubscriber(new StoreSubscriber());
```

### Event Propagation Control

Listeners can stop further event processing:

```php
public function onPlacedOrder(OrderPlacedEvent $event): void
{
    // Stop further listener execution
    $event->stopPropagation();
}
```

### Event Name Introspection

Listeners can access event metadata:

```php
public function myEventListener(
    Event $event, 
    string $eventName, 
    EventDispatcherInterface $dispatcher
): void {
    // Access event name and dispatcher context
}
```

### Priority-based Execution

Listeners execute based on priority (higher numbers = earlier execution):

```php
// High priority listener executes first
$dispatcher->addListener('event_name', $listener1, 100);
// Lower priority executes later  
$dispatcher->addListener('event_name', $listener2, 50);
```

### Specialized Dispatchers

#### Immutable Event Dispatcher
Prevents runtime listener modifications:

```php
use Symfony\Component\EventDispatcher\ImmutableEventDispatcher;

$immutableDispatcher = new ImmutableEventDispatcher($dispatcher);
// Cannot add/remove listeners after creation
```

#### Traceable Event Dispatcher
Provides debugging and profiling capabilities:

```php
use Symfony\Component\EventDispatcher\Debug\TraceableEventDispatcher;

$traceableDispatcher = new TraceableEventDispatcher($dispatcher, $stopwatch);
// Tracks event execution times and call patterns
```

### Advanced Features

- **Lazy Loading**: Listeners can be loaded on-demand
- **Event Chaining**: Events can trigger other events
- **Dynamic Registration**: Runtime listener modification
- **Event Context**: Access to dispatcher and event name within listeners
- **Flexible Priorities**: Fine-grained execution control

### Implementation Patterns

**Plugin Architecture:**
```php
// Enable plugin system through event dispatching
$dispatcher->dispatch(new PluginInitEvent($context));
```

**Middleware Pattern:**
```php
// Chain processing through prioritized listeners
$dispatcher->addListener('process.request', $middleware1, 100);
$dispatcher->addListener('process.request', $middleware2, 50);
```

**Observer Pattern:**
```php
// Multiple observers reacting to state changes
$dispatcher->dispatch(new StateChangedEvent($oldState, $newState));
```

### Debugging Events

Use TraceableEventDispatcher for development:
- Monitor event execution
- Profile listener performance  
- Track event propagation flow
- Identify bottlenecks

### Event Name Constants

Define event names as constants for consistency:

```php
final class OrderEvents
{
    public const PLACED = 'order.placed';
    public const SHIPPED = 'order.shipped';
    public const CANCELLED = 'order.cancelled';
}
```

The EventDispatcher component provides a robust foundation for creating loosely coupled, event-driven applications with flexible extension mechanisms and comprehensive debugging capabilities.