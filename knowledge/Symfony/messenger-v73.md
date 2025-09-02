## Header
- **Source**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/messenger.rst, https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/messenger/custom-transport.rst
- **Processed Date**: 2025-08-31
- **Domain**: symfony.com
- **Version**: v73
- **Weight Reduction**: ~35%
- **Key Sections**: Core Architecture, Messages & Handlers, Transport Configuration, Middleware, Worker Management, Serialization, Custom Transport Implementation

## Body

### Core Architecture

Symfony Messenger implements Command and Message Bus patterns for decoupled, scalable application architecture. Messages represent actions or events as PHP objects. Message handlers process these messages either synchronously (immediate) or asynchronously (queued).

### Message Definition

Messages are simple PHP classes without specific interface requirements:

```php
class SmsNotification
{
    public function __construct(
        private string $content,
        private string $phoneNumber
    ) {}

    public function getContent(): string { return $this->content; }
    public function getPhoneNumber(): string { return $this->phoneNumber; }
}

class CreateUser
{
    public function __construct(
        private string $email,
        private string $password
    ) {}

    // getters...
}
```

### Message Handlers

Handle messages using `#[AsMessageHandler]` attribute or interface implementation:

```php
use Symfony\Component\Messenger\Attribute\AsMessageHandler;

#[AsMessageHandler]
class SmsNotificationHandler
{
    public function __invoke(SmsNotification $message): void
    {
        // SMS sending logic
        $this->smsService->send(
            $message->getPhoneNumber(),
            $message->getContent()
        );
    }
}

// Multiple handlers for same message
#[AsMessageHandler]
class CreateUserHandler
{
    public function __invoke(CreateUser $message): void
    {
        // User creation logic
    }
}

#[AsMessageHandler] 
class SendWelcomeEmailHandler
{
    public function __invoke(CreateUser $message): void
    {
        // Welcome email logic
    }
}
```

### Message Bus Usage

Inject MessageBusInterface to dispatch messages:

```php
use Symfony\Component\Messenger\MessageBusInterface;

class UserController
{
    public function __construct(
        private MessageBusInterface $messageBus
    ) {}

    public function register(Request $request): Response
    {
        // Create user message
        $message = new CreateUser(
            $request->get('email'),
            $request->get('password')
        );

        // Dispatch synchronously or asynchronously based on routing
        $this->messageBus->dispatch($message);

        return new Response('User registration initiated');
    }
}
```

### Transport Configuration

Configure transports in `config/packages/messenger.yaml`:

```yaml
framework:
    messenger:
        # Failure transport for failed messages
        failure_transport: failed

        transports:
            # Synchronous processing (default)
            sync: 'sync://'

            # Doctrine DBAL transport
            async:
                dsn: 'doctrine://default?queue_name=default'
                retry_strategy:
                    max_retries: 3
                    multiplier: 2
                    delay: 1000

            # Redis transport
            redis_transport:
                dsn: 'redis://localhost:6379/messages'
                options:
                    stream_max_entries: 10000

            # AMQP transport
            rabbitmq:
                dsn: 'amqp://guest:guest@localhost:5672/%2f/messages'
                options:
                    exchange:
                        name: messages
                        type: direct

            # Amazon SQS
            sqs:
                dsn: 'sqs://ACCESS_KEY:SECRET_KEY@default/region?queue=messages'

            # Failed message handling
            failed: 'doctrine://default?queue_name=failed'

        routing:
            # Route specific messages to transports
            'App\Message\CreateUser': async
            'App\Message\SmsNotification': rabbitmq
            # Default synchronous processing
            '*': sync
```

### Multiple Message Buses

Configure separate buses for different message types:

```yaml
framework:
    messenger:
        default_bus: command.bus
        buses:
            command.bus: ~
            event.bus:
                default_middleware: allow_no_handlers
            query.bus:
                middleware:
                    - validation
                    - doctrine_transaction
```

Usage with specific buses:

```php
use Symfony\Component\Messenger\MessageBusInterface;

class OrderController
{
    public function __construct(
        #[Autowire(service: 'command.bus')]
        private MessageBusInterface $commandBus,
        #[Autowire(service: 'event.bus')]
        private MessageBusInterface $eventBus,
        #[Autowire(service: 'query.bus')]
        private MessageBusInterface $queryBus
    ) {}

    public function createOrder(): void
    {
        // Command
        $this->commandBus->dispatch(new CreateOrder(...));
        
        // Event
        $this->eventBus->dispatch(new OrderCreated(...));
        
        // Query
        $result = $this->queryBus->dispatch(new FindOrderQuery(...));
    }
}
```

### Middleware Configuration

Customize message processing pipeline:

```yaml
framework:
    messenger:
        buses:
            command.bus:
                middleware:
                    - validation
                    - doctrine_transaction
                    - 'App\Messenger\CustomMiddleware'
```

Custom middleware implementation:

```php
use Symfony\Component\Messenger\Envelope;
use Symfony\Component\Messenger\Middleware\MiddlewareInterface;
use Symfony\Component\Messenger\Middleware\StackInterface;

class CustomMiddleware implements MiddlewareInterface
{
    public function handle(Envelope $envelope, StackInterface $stack): Envelope
    {
        // Pre-processing
        $envelope = $envelope->with(new CustomStamp());
        
        try {
            // Continue to next middleware
            $envelope = $stack->next()->handle($envelope, $stack);
            
            // Post-processing
            return $envelope;
        } catch (\Throwable $exception) {
            // Error handling
            throw $exception;
        }
    }
}
```

### Message Worker Management

Start workers to consume async messages:

```bash
# Consume from specific transport
php bin/console messenger:consume async

# Consume from multiple transports
php bin/console messenger:consume async redis_transport

# Limit memory/time/messages
php bin/console messenger:consume async --memory-limit=128M --time-limit=3600 --limit=100

# Stop workers gracefully
php bin/console messenger:stop-workers
```

Worker supervision with systemd:

```ini
# /etc/systemd/system/messenger-worker@.service
[Unit]
Description=Symfony Messenger Worker %i

[Service]
Type=simple
User=www-data
ExecStart=/usr/bin/php /path/to/app/bin/console messenger:consume async --time-limit=3600
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
```

### Envelope and Stamps

Enrich messages with metadata using stamps:

```php
use Symfony\Component\Messenger\Stamp\DelayStamp;
use Symfony\Component\Messenger\Stamp\DispatchAfterCurrentBusStamp;

// Delay message processing
$this->messageBus->dispatch(
    new SmsNotification('Hello'),
    [new DelayStamp(5000)] // 5 seconds delay
);

// Dispatch after current bus completes
$this->messageBus->dispatch(
    new SendEmail(),
    [new DispatchAfterCurrentBusStamp()]
);
```

Custom stamp implementation:

```php
use Symfony\Component\Messenger\Stamp\StampInterface;

class PriorityStamp implements StampInterface
{
    public function __construct(
        private int $priority
    ) {}

    public function getPriority(): int
    {
        return $this->priority;
    }
}
```

### Serialization Configuration

Configure message serialization for transports:

```yaml
framework:
    messenger:
        transports:
            async:
                dsn: 'doctrine://default'
                serializer: messenger.transport.symfony_serializer
                options:
                    use_notify: true
                    check_delayed_interval: 60000

        serializer:
            default_serializer: messenger.transport.native_php_serializer
            symfony_serializer:
                format: json
                context: { }
```

Custom serializer:

```php
use Symfony\Component\Messenger\Transport\Serialization\SerializerInterface;
use Symfony\Component\Messenger\Envelope;

class CustomSerializer implements SerializerInterface
{
    public function decode(array $encodedEnvelope): Envelope
    {
        // Decode logic
    }

    public function encode(Envelope $envelope): array
    {
        // Encode logic
    }
}
```

### Error Handling and Retry Strategy

Configure comprehensive error handling:

```yaml
framework:
    messenger:
        transports:
            async:
                dsn: 'doctrine://default'
                retry_strategy:
                    max_retries: 3
                    delay: 1000
                    multiplier: 2
                    max_delay: 10000
                    # Custom retry decision
                    service: App\Messenger\CustomRetryStrategy

            failed: 'doctrine://default?queue_name=failed'

        routing:
            '*': async
```

Custom retry strategy:

```php
use Symfony\Component\Messenger\Retry\RetryStrategyInterface;
use Symfony\Component\Messenger\Envelope;

class CustomRetryStrategy implements RetryStrategyInterface
{
    public function isRetryable(Envelope $message, \Throwable $throwable = null): bool
    {
        return $throwable instanceof RetryableException;
    }

    public function getWaitingTime(Envelope $message, \Throwable $throwable = null): int
    {
        // Custom delay calculation
        return 1000 * (2 ** $this->getRetryCount($message));
    }
}
```

### Event Handling Integration

Dispatch domain events automatically:

```php
use Symfony\Component\Messenger\MessageBusInterface;
use Symfony\Contracts\EventDispatcher\Event;

class OrderPlaced extends Event
{
    public function __construct(
        private string $orderId
    ) {}

    public function getOrderId(): string
    {
        return $this->orderId;
    }
}

#[AsMessageHandler]
class OrderPlacedHandler
{
    public function __invoke(OrderPlaced $event): void
    {
        // Handle order placed logic
        $this->emailService->sendOrderConfirmation($event->getOrderId());
    }
}
```

### Message Handler Priorities

Control handler execution order:

```php
#[AsMessageHandler(priority: 10)]
class HighPriorityHandler
{
    public function __invoke(MyMessage $message): void
    {
        // Executes first
    }
}

#[AsMessageHandler(priority: -10)]
class LowPriorityHandler
{
    public function __invoke(MyMessage $message): void
    {
        // Executes last
    }
}
```

### Testing Message Handlers

Test message handling in isolation:

```php
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;
use Symfony\Component\Messenger\MessageBusInterface;

class SmsNotificationHandlerTest extends KernelTestCase
{
    public function testHandlerProcessesMessage(): void
    {
        self::bootKernel();
        $container = static::getContainer();

        $messageBus = $container->get(MessageBusInterface::class);
        
        $message = new SmsNotification('Test message', '+1234567890');
        
        // For sync transports, this will execute immediately
        $envelope = $messageBus->dispatch($message);
        
        // Assert expected side effects
        $this->assertTrue($this->smsWasSent());
    }
}
```

### Performance Optimization

Optimize message processing performance:

```yaml
framework:
    messenger:
        transports:
            high_volume:
                dsn: 'redis://localhost:6379'
                options:
                    # Redis-specific optimizations
                    serializer: 2 # Use faster serialization
                    stream_max_entries: 50000
                    
        # Use separate buses for different performance requirements
        buses:
            high_throughput.bus:
                middleware:
                    # Minimal middleware for speed
                    - send_message
                    - handle_message
```

Batch processing for high volumes:

```php
#[AsMessageHandler]
class BatchedEmailHandler
{
    private array $batch = [];
    private int $batchSize = 100;

    public function __invoke(SendEmail $message): void
    {
        $this->batch[] = $message;
        
        if (count($this->batch) >= $this->batchSize) {
            $this->processBatch();
            $this->batch = [];
        }
    }

    private function processBatch(): void
    {
        // Process all emails in batch
        $this->emailService->sendBatch($this->batch);
    }
}
```

### Security Considerations

Validate and authorize messages:

```php
use Symfony\Component\Security\Core\Security;

#[AsMessageHandler]
class SensitiveOperationHandler
{
    public function __construct(
        private Security $security
    ) {}

    public function __invoke(SensitiveOperation $message): void
    {
        // Security validation
        if (!$this->security->isGranted('ROLE_ADMIN')) {
            throw new AccessDeniedException();
        }

        // Process sensitive operation
    }
}
```

Message content validation:

```php
use Symfony\Component\Validator\Validator\ValidatorInterface;

#[AsMessageHandler]
class ValidatedMessageHandler
{
    public function __construct(
        private ValidatorInterface $validator
    ) {}

    public function __invoke(UserInput $message): void
    {
        $violations = $this->validator->validate($message);
        
        if (count($violations) > 0) {
            throw new ValidationException($violations);
        }

        // Process valid message
    }
}
```

### Custom Transport Implementation

Create custom transports for specialized message handling requirements. Custom transports integrate with Messenger's core architecture while providing domain-specific message delivery mechanisms.

#### Transport Factory

Implement `TransportFactoryInterface` to create transport instances:

```php
use Symfony\Component\Messenger\Transport\TransportFactoryInterface;
use Symfony\Component\Messenger\Transport\TransportInterface;
use Symfony\Component\Messenger\Transport\Serialization\SerializerInterface;

class CustomTransportFactory implements TransportFactoryInterface
{
    public function createTransport(
        string $dsn, 
        array $options, 
        SerializerInterface $serializer
    ): TransportInterface {
        // Parse DSN and options
        $parsedUrl = parse_url($dsn);
        
        // Initialize transport with dependencies
        return new CustomTransport($serializer, $options);
    }

    public function supports(string $dsn, array $options): bool
    {
        return str_starts_with($dsn, 'custom://');
    }
}
```

#### Transport Interface Implementation

Implement `TransportInterface` combining sender and receiver capabilities:

```php
use Symfony\Component\Messenger\Envelope;
use Symfony\Component\Messenger\Transport\TransportInterface;
use Symfony\Component\Messenger\Transport\Receiver\ReceiverInterface;
use Symfony\Component\Messenger\Transport\Sender\SenderInterface;
use Symfony\Component\Messenger\Transport\Serialization\SerializerInterface;
use Symfony\Component\Messenger\Stamp\TransportMessageIdStamp;

class CustomTransport implements TransportInterface
{
    private array $queue = [];
    private SerializerInterface $serializer;

    public function __construct(SerializerInterface $serializer, array $options = [])
    {
        $this->serializer = $serializer;
        // Initialize transport-specific configuration
    }

    // Sender implementation
    public function send(Envelope $envelope): Envelope
    {
        $encodedMessage = $this->serializer->encode($envelope);
        
        // Generate unique message ID
        $messageId = uniqid('msg_', true);
        
        // Store message in transport (queue, database, API, etc.)
        $this->queue[$messageId] = $encodedMessage;
        
        // Add transport message ID stamp
        return $envelope->with(new TransportMessageIdStamp($messageId));
    }

    // Receiver implementation
    public function get(): iterable
    {
        foreach ($this->queue as $messageId => $encodedMessage) {
            try {
                $envelope = $this->serializer->decode($encodedMessage);
                
                // Add transport message ID for acknowledgment
                $envelope = $envelope->with(new TransportMessageIdStamp($messageId));
                
                yield $envelope;
            } catch (\Throwable $exception) {
                // Handle decoding errors
                $this->reject($messageId);
            }
        }
    }

    public function ack(Envelope $envelope): void
    {
        $stamp = $envelope->last(TransportMessageIdStamp::class);
        if ($stamp) {
            // Remove successfully processed message
            unset($this->queue[$stamp->getId()]);
        }
    }

    public function reject(Envelope $envelope): void
    {
        $stamp = $envelope->last(TransportMessageIdStamp::class);
        if ($stamp) {
            $messageId = $stamp->getId();
            
            // Move to dead letter queue or retry logic
            $this->handleFailedMessage($messageId);
            unset($this->queue[$messageId]);
        }
    }

    private function handleFailedMessage(string $messageId): void
    {
        // Implement failure handling strategy
        // - Move to dead letter queue
        // - Log for manual intervention
        // - Implement retry with backoff
    }
}
```

#### Advanced Transport with External Service

Integrate with external messaging services:

```php
class ApiTransport implements TransportInterface
{
    private HttpClientInterface $httpClient;
    private SerializerInterface $serializer;
    private string $apiEndpoint;
    private array $headers;

    public function __construct(
        HttpClientInterface $httpClient,
        SerializerInterface $serializer,
        string $apiEndpoint,
        array $headers = []
    ) {
        $this->httpClient = $httpClient;
        $this->serializer = $serializer;
        $this->apiEndpoint = $apiEndpoint;
        $this->headers = $headers;
    }

    public function send(Envelope $envelope): Envelope
    {
        $encodedMessage = $this->serializer->encode($envelope);
        
        $response = $this->httpClient->request('POST', $this->apiEndpoint, [
            'headers' => array_merge($this->headers, [
                'Content-Type' => 'application/json'
            ]),
            'json' => $encodedMessage
        ]);

        $responseData = $response->toArray();
        $messageId = $responseData['message_id'] ?? uniqid();
        
        return $envelope->with(new TransportMessageIdStamp($messageId));
    }

    public function get(): iterable
    {
        $response = $this->httpClient->request('GET', $this->apiEndpoint . '/messages');
        $messages = $response->toArray();

        foreach ($messages as $messageData) {
            try {
                $envelope = $this->serializer->decode($messageData['content']);
                $envelope = $envelope->with(
                    new TransportMessageIdStamp($messageData['id'])
                );
                
                yield $envelope;
            } catch (\Throwable $exception) {
                $this->handleDecodingError($messageData['id'], $exception);
            }
        }
    }

    public function ack(Envelope $envelope): void
    {
        $stamp = $envelope->last(TransportMessageIdStamp::class);
        if ($stamp) {
            $this->httpClient->request(
                'DELETE', 
                $this->apiEndpoint . '/messages/' . $stamp->getId()
            );
        }
    }

    public function reject(Envelope $envelope): void
    {
        $stamp = $envelope->last(TransportMessageIdStamp::class);
        if ($stamp) {
            $this->httpClient->request('POST', $this->apiEndpoint . '/messages/' . $stamp->getId() . '/reject');
        }
    }
}
```

#### Transport Configuration

Configure custom transport in messenger configuration:

```yaml
framework:
    messenger:
        transports:
            # Custom transport with options
            custom_api:
                dsn: 'custom://api.example.com'
                options:
                    api_key: '%env(API_KEY)%'
                    timeout: 30
                    retry_attempts: 3
                serializer: messenger.transport.symfony_serializer

            # Alternative configuration
            custom_queue:
                dsn: 'custom://localhost'
                options:
                    queue_name: 'priority_messages'
                    max_retries: 5

        routing:
            'App\Message\ApiMessage': custom_api
            'App\Message\QueuedTask': custom_queue
```

#### Transport Factory Registration

Register transport factory automatically or manually:

```yaml
# config/services.yaml
services:
    App\Messenger\Transport\CustomTransportFactory:
        tags: [messenger.transport_factory]
        
    # Manual configuration with dependencies
    App\Messenger\Transport\ApiTransportFactory:
        arguments:
            $httpClient: '@http_client'
        tags: [messenger.transport_factory]
```

#### Serializer Integration

Custom serializer for transport-specific requirements:

```php
use Symfony\Component\Messenger\Transport\Serialization\SerializerInterface;
use Symfony\Component\Messenger\Envelope;
use Symfony\Component\Messenger\Stamp\StampInterface;

class CustomTransportSerializer implements SerializerInterface
{
    private SerializerInterface $fallbackSerializer;

    public function __construct(SerializerInterface $fallbackSerializer)
    {
        $this->fallbackSerializer = $fallbackSerializer;
    }

    public function decode(array $encodedEnvelope): Envelope
    {
        // Custom decoding logic
        if (!isset($encodedEnvelope['body']) || !isset($encodedEnvelope['headers'])) {
            throw new \InvalidArgumentException('Invalid message format');
        }

        $message = unserialize(base64_decode($encodedEnvelope['body']));
        $stamps = $this->decodeStamps($encodedEnvelope['headers']);
        
        return new Envelope($message, $stamps);
    }

    public function encode(Envelope $envelope): array
    {
        // Custom encoding logic
        return [
            'body' => base64_encode(serialize($envelope->getMessage())),
            'headers' => $this->encodeStamps($envelope->all()),
            'timestamp' => time(),
            'message_type' => get_class($envelope->getMessage())
        ];
    }

    private function decodeStamps(array $headers): array
    {
        $stamps = [];
        
        foreach ($headers['stamps'] ?? [] as $stampData) {
            $stampClass = $stampData['class'];
            $stamps[] = unserialize($stampData['data']);
        }
        
        return $stamps;
    }

    private function encodeStamps(array $stamps): array
    {
        $headers = ['stamps' => []];
        
        foreach ($stamps as $stampType => $stampList) {
            foreach ($stampList as $stamp) {
                $headers['stamps'][] = [
                    'class' => get_class($stamp),
                    'data' => serialize($stamp)
                ];
            }
        }
        
        return $headers;
    }
}
```

#### Connection Management

Implement connection pooling and management:

```php
class PooledTransport implements TransportInterface
{
    private array $connectionPool = [];
    private int $maxConnections = 10;
    private SerializerInterface $serializer;

    public function send(Envelope $envelope): Envelope
    {
        $connection = $this->getConnection();
        
        try {
            $encodedMessage = $this->serializer->encode($envelope);
            $messageId = $connection->send($encodedMessage);
            
            return $envelope->with(new TransportMessageIdStamp($messageId));
        } finally {
            $this->releaseConnection($connection);
        }
    }

    public function get(): iterable
    {
        $connection = $this->getConnection();
        
        try {
            $messages = $connection->receive();
            
            foreach ($messages as $messageData) {
                $envelope = $this->serializer->decode($messageData['content']);
                $envelope = $envelope->with(
                    new TransportMessageIdStamp($messageData['id'])
                );
                
                yield $envelope;
            }
        } finally {
            $this->releaseConnection($connection);
        }
    }

    private function getConnection(): ConnectionInterface
    {
        if (count($this->connectionPool) > 0) {
            return array_pop($this->connectionPool);
        }
        
        if ($this->getActiveConnections() < $this->maxConnections) {
            return $this->createConnection();
        }
        
        // Wait for available connection or throw exception
        throw new \RuntimeException('Connection pool exhausted');
    }

    private function releaseConnection(ConnectionInterface $connection): void
    {
        if ($connection->isHealthy()) {
            $this->connectionPool[] = $connection;
        }
    }
}
```

#### Testing Custom Transports

Test transport implementation thoroughly:

```php
use PHPUnit\Framework\TestCase;
use Symfony\Component\Messenger\Envelope;
use Symfony\Component\Messenger\Transport\Serialization\PhpSerializer;

class CustomTransportTest extends TestCase
{
    private CustomTransport $transport;
    private SerializerInterface $serializer;

    protected function setUp(): void
    {
        $this->serializer = new PhpSerializer();
        $this->transport = new CustomTransport($this->serializer);
    }

    public function testSendAndReceiveMessage(): void
    {
        $message = new TestMessage('content');
        $envelope = new Envelope($message);
        
        // Send message
        $sentEnvelope = $this->transport->send($envelope);
        $this->assertNotNull($sentEnvelope->last(TransportMessageIdStamp::class));
        
        // Receive message
        $receivedMessages = iterator_to_array($this->transport->get());
        $this->assertCount(1, $receivedMessages);
        
        $receivedEnvelope = $receivedMessages[0];
        $this->assertEquals($message->getContent(), $receivedEnvelope->getMessage()->getContent());
    }

    public function testAcknowledgeMessage(): void
    {
        $message = new TestMessage('content');
        $envelope = new Envelope($message);
        
        $sentEnvelope = $this->transport->send($envelope);
        $receivedMessages = iterator_to_array($this->transport->get());
        
        $this->transport->ack($receivedMessages[0]);
        
        // Message should be removed after acknowledgment
        $remainingMessages = iterator_to_array($this->transport->get());
        $this->assertCount(0, $remainingMessages);
    }
}
```

#### Production Considerations

Implement production-ready features:

- **Connection resilience**: Automatic reconnection and circuit breaker patterns
- **Monitoring integration**: Metrics collection for message throughput and errors
- **Security**: Authentication, encryption, and message validation
- **Performance optimization**: Connection pooling, batching, and async processing
- **Observability**: Logging, tracing, and health checks
- **Configuration validation**: Validate DSN format and required options at startup