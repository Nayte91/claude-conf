## Header
- **Source**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/security.rst, https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/security/voters.rst
- **Processed Date**: 2025-08-31
- **Domain**: symfony.com
- **Version**: v7.3
- **Weight Reduction**: ~65%
- **Key Sections**: Authentication, Authorization, User Management, Security Configuration, Best Practices

## Body

### Core Security Architecture

**Security Component Structure:**
- **Authentication**: Validates user identity
- **Authorization**: Determines user permissions
- **User Provider**: Loads user data from storage
- **Firewall**: Controls access per route/domain
- **Access Control**: Defines permission rules

### Authentication Mechanisms

**Built-in Authenticators:**
1. **Form Login**: Standard login form with CSRF protection
2. **JSON Login**: API authentication via JSON payload
3. **HTTP Basic**: Basic authentication header
4. **Login Link**: Passwordless login via secure links
5. **X.509 Client Certificates**: Certificate-based authentication
6. **Remote User**: Authentication via reverse proxy
7. **Custom Authenticators**: Custom authentication logic

**User Interface Requirements:**
```php
class User implements UserInterface
{
    public function getUserIdentifier(): string
    public function getRoles(): array
    public function getPassword(): ?string
    public function eraseCredentials(): void
}
```

### Security Configuration

**security.yaml Structure:**
```yaml
security:
    password_hashers:
        App\Entity\User: 'auto'
    
    providers:
        app_user_provider:
            entity:
                class: App\Entity\User
                property: email
    
    firewalls:
        dev:
            pattern: ^/(_(profiler|wdt)|css|images|js)/
            security: false
        main:
            lazy: true
            provider: app_user_provider
            form_login:
                login_path: app_login
                check_path: app_login
                csrf_token_generator: security.csrf.token_manager
            logout:
                path: app_logout
    
    access_control:
        - { path: ^/admin, roles: ROLE_ADMIN }
        - { path: ^/profile, roles: ROLE_USER }
```

### Authorization Patterns

**Role-Based Access Control:**
```yaml
# Role hierarchy
role_hierarchy:
    ROLE_ADMIN: ROLE_USER
    ROLE_SUPER_ADMIN: [ROLE_ADMIN, ROLE_ALLOWED_TO_SWITCH]

# Access control rules
access_control:
    - { path: ^/admin, roles: ROLE_ADMIN }
    - { path: ^/api, roles: ROLE_API_USER }
```

**Controller-Level Security:**
```php
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\Security\Http\Attribute\IsGranted;

class AdminController extends AbstractController
{
    #[IsGranted('ROLE_ADMIN')]
    public function dashboard(): Response
    {
        // Method protected by role
    }
    
    public function userProfile(): Response
    {
        $this->denyAccessUnlessGranted('ROLE_USER');
        // Programmatic access control
    }
}
```

### User Management

**Password Hashing:**
```php
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

class UserController
{
    public function createUser(UserPasswordHasherInterface $passwordHasher)
    {
        $user = new User();
        $hashedPassword = $passwordHasher->hashPassword(
            $user,
            $plaintextPassword
        );
        $user->setPassword($hashedPassword);
    }
}
```

**User Provider Configuration:**
```yaml
security:
    providers:
        # Entity provider
        app_user_provider:
            entity:
                class: App\Entity\User
                property: email
        
        # Memory provider (testing)
        in_memory:
            memory:
                users:
                    john: { password: '$2y$13$...', roles: ['ROLE_USER'] }
        
        # Custom provider
        custom_provider:
            id: App\Security\UserProvider
```

### Security Events and Customization

**Authentication Events:**
- `LoginSuccessEvent`: After successful login
- `LoginFailureEvent`: After failed login attempt
- `LogoutEvent`: During logout process

**Custom Authentication:**
```php
use Symfony\Component\Security\Http\Authentication\AuthenticationSuccessHandlerInterface;

class CustomAuthenticationSuccessHandler implements AuthenticationSuccessHandlerInterface
{
    public function onAuthenticationSuccess(Request $request, TokenInterface $token): ?Response
    {
        // Custom post-login logic
        return new RedirectResponse('/dashboard');
    }
}
```

### Security Attributes and Annotations

**Method-Level Security:**
```php
use Symfony\Component\Security\Http\Attribute\IsGranted;

class PostController
{
    #[IsGranted('ROLE_ADMIN')]
    public function adminAction(): Response
    
    #[IsGranted('ROLE_USER')]
    #[IsGranted('ROLE_MODERATOR', subject: 'post')]
    public function editPost(Post $post): Response
}
```

**Template Security:**
```twig
{% if is_granted('ROLE_ADMIN') %}
    <a href="{{ path('admin_dashboard') }}">Admin Panel</a>
{% endif %}

{% if is_granted('ROLE_USER') %}
    <p>Welcome, {{ app.user.username }}!</p>
{% endif %}
```

### Advanced Security Features

**Programmatic Authentication:**
```php
use Symfony\Component\Security\Core\Security;

class LoginService
{
    public function authenticateUser(User $user, string $firewallName = 'main')
    {
        $this->security->login($user, 'form_login', $firewallName);
    }
}
```

**CSRF Protection:**
```yaml
security:
    firewalls:
        main:
            form_login:
                csrf_token_generator: security.csrf.token_manager
                csrf_parameter: _csrf_token
                csrf_token_id: authenticate
```

**Login Throttling:**
```yaml
security:
    firewalls:
        main:
            login_throttling:
                max_attempts: 5
                interval: '15 minutes'
```

### Security Best Practices

**Configuration Guidelines:**
- Always use `lazy: true` for main firewall
- Implement proper logout handling
- Use CSRF protection for forms
- Configure appropriate password hashers
- Set up role hierarchy for permission management

**Code Security Patterns:**
- Use `denyAccessUnlessGranted()` for programmatic checks
- Implement custom voters for complex authorization logic
- Handle security events for logging and monitoring
- Use security attributes for declarative access control

**User Data Protection:**
- Hash passwords with secure algorithms
- Implement proper session management
- Use HTTPS in production
- Validate and sanitize user input
- Implement rate limiting for authentication attempts

### Security Voters

**Voter System**: Centralized authorization mechanism that standardizes access control decisions across the application through dedicated voter classes.

**Implementation Requirements**:
- Extend `Voter` abstract class or implement `VoterInterface`
- Define `supports()` method for attribute/subject type filtering
- Implement `voteOnAttribute()` for authorization logic

### Basic Voter Implementation

```php
use Symfony\Component\Security\Core\Authorization\Voter\Voter;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;

class PostVoter extends Voter
{
    public const VIEW = 'view';
    public const EDIT = 'edit';
    public const DELETE = 'delete';

    protected function supports(string $attribute, mixed $subject): bool
    {
        return in_array($attribute, [self::VIEW, self::EDIT, self::DELETE])
            && $subject instanceof Post;
    }

    protected function voteOnAttribute(string $attribute, mixed $subject, TokenInterface $token): bool
    {
        $user = $token->getUser();
        
        if (!$user instanceof User) {
            return false;
        }

        return match($attribute) {
            self::VIEW => $this->canView($subject, $user),
            self::EDIT => $this->canEdit($subject, $user),
            self::DELETE => $this->canDelete($subject, $user),
            default => false
        };
    }

    private function canView(Post $post, User $user): bool
    {
        return $post->isPublic() || $post->getAuthor() === $user;
    }

    private function canEdit(Post $post, User $user): bool
    {
        return $post->getAuthor() === $user;
    }

    private function canDelete(Post $post, User $user): bool
    {
        return $this->canEdit($post, $user) || $user->hasRole('ROLE_ADMIN');
    }
}
```

### Access Decision Strategies

**Configuration**: Set voter decision strategy in `security.yaml`:

```yaml
security:
    access_decision_manager:
        strategy: affirmative  # Default strategy
```

**Available Strategies**:
- `affirmative`: Grant access if any voter grants access
- `consensus`: Grant access based on majority decision
- `unanimous`: Grant access only if no voter denies
- `priority`: Use first non-abstaining voter's decision

### Advanced Voter Patterns

**Hierarchical Voting**:
```php
class DocumentVoter extends Voter
{
    protected function voteOnAttribute(string $attribute, mixed $subject, TokenInterface $token): bool
    {
        $user = $token->getUser();
        
        // Check ownership first
        if ($subject->getOwner() === $user) {
            return true;
        }
        
        // Check team membership
        if ($subject->getTeam()->hasUser($user)) {
            return in_array($attribute, ['view', 'comment']);
        }
        
        // Check organization access
        if ($subject->getOrganization()->hasUser($user)) {
            return $attribute === 'view';
        }
        
        return false;
    }
}
```

**Role-Based Voting**:
```php
class AdminVoter extends Voter
{
    protected function supports(string $attribute, mixed $subject): bool
    {
        return str_starts_with($attribute, 'ADMIN_');
    }

    protected function voteOnAttribute(string $attribute, mixed $subject, TokenInterface $token): bool
    {
        $user = $token->getUser();
        
        return match($attribute) {
            'ADMIN_VIEW' => $user->hasRole('ROLE_ADMIN'),
            'ADMIN_EDIT' => $user->hasRole('ROLE_SUPER_ADMIN'),
            'ADMIN_DELETE' => $user->hasRole('ROLE_SUPER_ADMIN'),
            default => false
        };
    }
}
```

### Performance Optimization

**Cacheable Voters**: Implement `CacheableVoterInterface` for performance:

```php
use Symfony\Component\Security\Core\Authorization\Voter\CacheableVoterInterface;

class PostVoter extends Voter implements CacheableVoterInterface
{
    public function supportsAttribute(string $attribute): bool
    {
        return in_array($attribute, [self::VIEW, self::EDIT, self::DELETE]);
    }

    public function supportsType(string $subjectType): bool
    {
        return $subjectType === Post::class;
    }
}
```

### Usage in Controllers

**Direct Authorization Check**:
```php
class PostController extends AbstractController
{
    #[Route('/post/{id}', methods: ['GET'])]
    public function show(Post $post): Response
    {
        $this->denyAccessUnlessGranted('view', $post);
        
        return $this->render('post/show.html.twig', [
            'post' => $post,
            'canEdit' => $this->isGranted('edit', $post),
        ]);
    }
    
    #[Route('/post/{id}/edit', methods: ['GET', 'POST'])]
    public function edit(Post $post): Response
    {
        $this->denyAccessUnlessGranted('edit', $post);
        
        // Edit logic
    }
}
```

**Service Layer Authorization**:
```php
class PostService
{
    public function __construct(
        private Security $security
    ) {}
    
    public function deletePost(Post $post): void
    {
        if (!$this->security->isGranted('delete', $post)) {
            throw new AccessDeniedException();
        }
        
        // Delete logic
    }
}
```

### Twig Integration

**Template Authorization Checks**:
```twig
{% if is_granted('view', post) %}
    <h1>{{ post.title }}</h1>
{% endif %}

{% if is_granted('edit', post) %}
    <a href="{{ path('post_edit', {id: post.id}) }}">Edit</a>
{% endif %}

{% if is_granted('delete', post) %}
    <button onclick="deletePost({{ post.id }})">Delete</button>
{% endif %}
```

### Voter Registration

**Automatic Registration**: Voters implementing `VoterInterface` are auto-registered with `voter` tag.

**Manual Registration** (if needed):
```yaml
services:
    App\Security\PostVoter:
        tags: [security.voter]
```

### Testing Voters

**Unit Testing**:
```php
use PHPUnit\Framework\TestCase;
use Symfony\Component\Security\Core\Authentication\Token\UsernamePasswordToken;

class PostVoterTest extends TestCase
{
    private PostVoter $voter;

    public function testUserCanViewOwnPost(): void
    {
        $user = new User();
        $post = new Post();
        $post->setAuthor($user);
        
        $token = new UsernamePasswordToken($user, 'memory');
        
        $this->assertTrue(
            $this->voter->vote($token, $post, ['view']) === VoterInterface::ACCESS_GRANTED
        );
    }
}
```

### Best Practices

**Voter Design**:
- Keep voters focused on single entity types
- Use constants for attribute names
- Implement clear, readable authorization logic
- Handle null users appropriately
- Use dependency injection for external services

**Performance Considerations**:
- Implement `CacheableVoterInterface` for frequently used voters
- Avoid expensive operations in `supports()` method
- Cache complex authorization calculations
- Use efficient database queries for permission checks

**Security Guidelines**:
- Default to deny access (return false)
- Validate user authentication before authorization
- Log authorization decisions for security auditing
- Test edge cases and access scenarios thoroughly