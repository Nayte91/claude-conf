## Header
- **Source**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/controller.rst
- **Processed Date**: 2025-09-01
- **Domain**: symfony-docs
- **Version**: v7.3
- **Weight Reduction**: ~75%
- **Key Sections**: v7.3 Attributes, Parameter Mapping, Response Types, Service Injection

## Body

### Symfony 7.3 Controller Attributes

```php
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\HttpKernel\Attribute\MapQueryParameter;
use Symfony\Component\HttpKernel\Attribute\MapRequestPayload;
use Symfony\Component\HttpKernel\Attribute\Cache;
use Symfony\Component\Security\Http\Attribute\CurrentUser;
use Symfony\Component\Security\Http\Attribute\IsGranted;

class ExampleController extends AbstractController
{
    #[Route('/path/{id}', name: 'route_name')]
    #[Cache(expires: '+1 hour', public: true)]
    #[IsGranted('ROLE_USER')]
    public function method(int $id, #[CurrentUser] User $user): Response
    {
        // v7.3 attribute-based configuration
    }
}
```

### Symfony 7.3 Parameter Mapping

#### Query Parameter Mapping (v7.3)
```php
public function search(
    #[MapQueryParameter] string $query,
    #[MapQueryParameter] int $page = 1
): Response {
    // Automatic query parameter mapping
}
```

#### Request Payload Mapping (v7.3)
```php
class CreateUserRequest
{
    public string $email;
    public string $name;
}

public function create(
    #[MapRequestPayload] CreateUserRequest $request
): Response {
    // Automatic JSON/form deserialization to DTO
}
```

### Symfony 7.3 Response Types

#### JSON Response (v7.3)
```php
return $this->json(['data' => $value], 200, ['Custom-Header' => 'value']);
```

#### Binary File Response (v7.3)
```php
use Symfony\Component\HttpFoundation\BinaryFileResponse;

return new BinaryFileResponse('/path/to/file.pdf');
```

#### Streamed Response (v7.3)
```php
use Symfony\Component\HttpFoundation\StreamedResponse;

return new StreamedResponse(function() {
    echo 'Stream content...';
});
```

### Symfony 7.3 Service Injection

#### Constructor Injection (v7.3)
```php
class MyController extends AbstractController
{
    public function __construct(
        private EntityManagerInterface $entityManager,
        private LoggerInterface $logger
    ) {}
}
```

#### Method Injection (v7.3)
```php
public function method(
    EntityManagerInterface $entityManager,
    Request $request
): Response {
    // Services automatically injected
}
```

### Symfony 7.3 Error Handling

```php
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Security\Core\Exception\AccessDeniedException;

// 404 Error
if (!$entity) {
    throw $this->createNotFoundException('Entity not found');
}

// Access Denied
if (!$this->isGranted('ROLE_ADMIN')) {
    throw new AccessDeniedException();
}
```

### Symfony 7.3 Route Configuration

```php
#[Route(
    '/path/{id}',
    name: 'route_name',
    requirements: ['id' => '\d+'],
    methods: ['GET', 'POST'],
    defaults: ['id' => 1],
    priority: 10,
    condition: "request.headers.get('User-Agent') matches '/firefox/i'"
)]
```

### Symfony 7.3 AbstractController Methods

```php
// Template rendering
$this->render('template.html.twig', ['data' => $value]);

// URL generation
$this->generateUrl('route_name', ['param' => $value]);

// Redirects
$this->redirectToRoute('route_name', ['param' => $value]);

// Flash messages
$this->addFlash('success', 'Message');

// Security
$this->isGranted('ROLE_ADMIN');
$this->getUser();

// Parameters
$this->getParameter('app.secret');
```

### Symfony 7.3 Session Handling

```php
public function method(SessionInterface $session): Response
{
    // Flash messages
    $this->addFlash('success', 'Operation completed');
    
    // Session data
    $session->set('key', 'value');
    $value = $session->get('key');
}
```

### Symfony 7.3 File Upload

```php
use Symfony\Component\HttpFoundation\File\UploadedFile;

public function upload(Request $request): Response
{
    /** @var UploadedFile $file */
    $file = $request->files->get('upload');
    
    if ($file) {
        $filename = $file->getClientOriginalName();
        $file->move('/upload/directory', $filename);
    }
}
```