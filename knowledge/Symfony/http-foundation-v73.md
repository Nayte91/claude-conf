## Header
- **Source**: https://symfony.com/doc/current/components/http_foundation.html
- **Processed Date**: 2025-08-31
- **Domain**: symfony.com
- **Version**: v7.3
- **Weight Reduction**: 65%
- **Key Sections**: Request/Response Classes, Session Management, File Uploads, HTTP Headers, Cookies, Security

## Body

### Core Architecture

**Request Class**
- Object-oriented HTTP request abstraction
- Factory method: `Request::createFromGlobals()`
- Data access via property bags:
  - `$request->request`: POST parameters (ParameterBag)
  - `$request->query`: GET parameters (InputBag)
  - `$request->cookies`: Cookies (InputBag)
  - `$request->files`: Uploaded files (FileBag)
  - `$request->server`: Server/environment (ServerBag)
  - `$request->headers`: HTTP headers (HeaderBag)

**Response Class**
- HTTP response representation with status, headers, content
- Constructor: `new Response($content, $status, $headers)`
- Fluent interface for method chaining

### Request Implementation Patterns

**Creating Requests**
```php
// From globals (standard web)
$request = Request::createFromGlobals();

// Manual creation
$request = new Request($get, $post, $attributes, $cookies, $files, $server, $content);

// From URI
$request = Request::create('/path', 'GET', ['param' => 'value']);
```

**Data Access Methods**
```php
$request->query->get('name', 'default');           // GET parameter
$request->request->get('field');                   // POST parameter
$request->headers->get('User-Agent');              // Header
$request->getPathInfo();                           // Path component
$request->getMethod();                             // HTTP method
$request->getClientIp();                          // Client IP
```

**Request Information**
- `getScheme()`: http/https
- `getHost()`: domain name
- `getPort()`: port number
- `getUri()`: complete URI
- `getRequestUri()`: URI with query string
- `getBaseUrl()`: base path
- `isSecure()`: HTTPS check
- `isXmlHttpRequest()`: AJAX check

### Response Implementation Patterns

**Basic Response Types**
```php
// Text response
$response = new Response('Content');

// JSON response
$response = new JsonResponse(['data' => $value]);

// File download
$response = new BinaryFileResponse('/path/to/file');

// Redirect
$response = new RedirectResponse('/new-url');

// Streamed response
$response = new StreamedResponse(function() {
    echo 'streaming content';
});
```

**Response Configuration**
```php
$response->setStatusCode(404);
$response->headers->set('Content-Type', 'application/json');
$response->headers->setCookie(Cookie::create('name', 'value'));
$response->setMaxAge(3600);                        // Cache control
$response->setPublic();                            // Public cache
$response->setPrivate();                           // Private cache
```

### Session Management

**Session Interface**
- `SessionInterface` for session operations
- Storage backends: native PHP, database, Redis, etc.
- Flash messages for one-time notifications

**Session Operations**
```php
$session = $request->getSession();
$session->set('key', 'value');
$value = $session->get('key', 'default');
$session->remove('key');
$session->clear();
$session->invalidate();                            // Destroy session
```

**Flash Messages**
```php
$session->getFlashBag()->add('notice', 'Profile updated');
$messages = $session->getFlashBag()->get('notice');
```

### File Upload Handling

**UploadedFile Class**
- Represents uploaded files with validation
- Move uploaded files securely
- File information and validation methods

**File Operations**
```php
$file = $request->files->get('upload');
if ($file->isValid()) {
    $file->move('/upload/dir', $file->getClientOriginalName());
}

// File information
$file->getClientOriginalName();                    // Original name
$file->getClientMimeType();                       // MIME type
$file->getSize();                                 // File size
$file->getError();                                // Upload error code
```

### HTTP Headers Management

**HeaderBag Operations**
```php
$headers = $request->headers;
$headers->get('Accept');                          // Single header
$headers->all();                                  // All headers
$headers->has('Authorization');                   // Header exists check
$headers->contains('Accept', 'application/json'); // Value check
```

**Accept Header Parsing**
```php
$acceptHeader = $request->headers->get('Accept');
$accept = AcceptHeader::fromString($acceptHeader);
foreach ($accept as $item) {
    $mimeType = $item->getValue();
    $quality = $item->getQuality();
}
```

### Cookie Management

**Cookie Creation and Configuration**
```php
$cookie = Cookie::create('name')
    ->withValue('value')
    ->withExpires(time() + 3600)
    ->withPath('/')
    ->withDomain('.example.com')
    ->withSecure(true)
    ->withHttpOnly(true)
    ->withSameSite(Cookie::SAMESITE_STRICT);

$response->headers->setCookie($cookie);
```

**Cookie Access**
```php
$value = $request->cookies->get('name', 'default');
$allCookies = $request->cookies->all();
```

### Advanced HTTP Features

**Content Negotiation**
```php
$request->getPreferredLanguage(['en', 'fr']);     // Language negotiation
$request->getAcceptableContentTypes();            // Accept types
$request->isMethodSafe();                         // GET, HEAD, OPTIONS
$request->isMethodIdempotent();                   // Safe + PUT, DELETE
```

**IP Address Handling**
```php
$ip = $request->getClientIp();                    // Real client IP
$ips = $request->getClientIps();                  // IP chain (proxies)

// IP anonymization
Request::setTrustedProxies(['192.168.1.1'], Request::HEADER_X_FORWARDED_FOR);
```

### Security Considerations

**Trusted Proxies Configuration**
```php
Request::setTrustedProxies(
    ['10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16'],
    Request::HEADER_X_FORWARDED_FOR | Request::HEADER_X_FORWARDED_HOST
);
```

**Input Filtering**
- All parameter bags provide filtered access
- XSS protection through proper output escaping
- CSRF protection via tokens (separate component)

**HTTPS Enforcement**
```php
if (!$request->isSecure()) {
    $url = 'https://' . $request->getHost() . $request->getRequestUri();
    return new RedirectResponse($url, 301);
}
```

### Request Matching

**RequestMatcher Class**
```php
$matcher = new RequestMatcher();
$matcher->matchPath('/admin/.*');
$matcher->matchHost('example\.com');
$matcher->matchMethod(['GET', 'POST']);
$matcher->matchScheme('https');

if ($matcher->matches($request)) {
    // Handle matched request
}
```

### Error Handling

**HTTP Exceptions**
- `HttpException`: Base HTTP error
- `NotFoundHttpException`: 404 errors
- `AccessDeniedHttpException`: 403 errors
- `BadRequestHttpException`: 400 errors

### Performance Optimization

**Response Caching**
```php
$response->setEtag(md5($content));
$response->setLastModified(new \DateTime());
if ($response->isNotModified($request)) {
    return $response;
}
```

**Streaming for Large Responses**
```php
$response = new StreamedResponse(function() use ($data) {
    foreach ($data as $item) {
        echo json_encode($item) . "\n";
        flush();
    }
});
```