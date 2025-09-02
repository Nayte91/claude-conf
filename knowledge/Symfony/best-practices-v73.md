## Header
- **Source**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/best_practices.rst
- **Processed Date**: 2025-09-01
- **Domain**: symfony.com
- **Version**: v7.3
- **Weight Reduction**: ~85%
- **Key Sections**: v7.3 Project Setup, Configuration Patterns, Service Architecture, New Attributes

## Body

### Symfony 7.3 Project Creation

```bash
# Create new project with v7.3
symfony new my-project --version="7.3.*"
symfony server:start
```

### Symfony 7.3 Configuration Patterns

#### Environment Variables & Secrets (v7.3)
```bash
# v7.3 secrets management
php bin/console secrets:set API_KEY
php bin/console secrets:set --env=dev API_KEY
```

#### Service Configuration (v7.3)
```yaml
# config/services.yaml
services:
    _defaults:
        autowire: true
        autoconfigure: true
        public: false

    App\:
        resource: '../src/'
        exclude:
            - '../src/DependencyInjection/'
            - '../src/Entity/'
            - '../src/Kernel.php'
```

### Symfony 7.3 Controller Patterns

#### New Attributes in v7.3
```php
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\CurrentUser;
use Symfony\Component\HttpKernel\Attribute\Cache;
use Symfony\Component\Security\Http\Attribute\IsGranted;

class BlogController extends AbstractController
{
    #[Route('/blog', name: 'blog_list')]
    #[Cache(expires: '+1 hour', public: true)]
    #[IsGranted('ROLE_USER')]
    public function list(#[CurrentUser] User $user): Response
    {
        // v7.3 attribute-based configuration
    }
}
```

#### Dependency Injection (v7.3)
```php
class BlogController extends AbstractController
{
    public function __construct(
        private BlogRepository $blogRepository,
        private EntityManagerInterface $entityManager
    ) {}
}
```

### Symfony 7.3 Security Configuration

#### Single Firewall (v7.3)
```yaml
# config/packages/security.yaml
security:
    firewalls:
        main:
            lazy: true
            provider: app_user_provider
            form_login:
                login_path: login
                check_path: login
            logout:
                path: logout

    password_hashers:
        Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface: 'auto'
```

#### Security Voters (v7.3)
```php
class PostVoter extends Voter
{
    protected function supports(string $attribute, mixed $subject): bool
    {
        return in_array($attribute, ['POST_EDIT', 'POST_DELETE']) 
               && $subject instanceof Post;
    }
    
    protected function voteOnAttribute(string $attribute, mixed $subject, TokenInterface $token): bool
    {
        return match ($attribute) {  // v7.3: match expression
            'POST_EDIT' => $this->canEdit($subject, $token->getUser()),
            'POST_DELETE' => $this->canDelete($subject, $token->getUser()),
            default => false,
        };
    }
}
```

### Symfony 7.3 Form Patterns

#### Form Type Classes (v7.3)
```php
class PostType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('title')
            ->add('content', TextareaType::class)
            ->add('publishedAt', DateTimeType::class);
    }
}
```

#### Single Action Processing (v7.3)
```php
#[Route('/post/new', name: 'admin_post_new')]
public function new(Request $request): Response
{
    $post = new Post();
    $form = $this->createForm(PostType::class, $post);
    
    $form->handleRequest($request);
    if ($form->isSubmitted() && $form->isValid()) {
        $this->entityManager->persist($post);
        $this->entityManager->flush();
        
        return $this->redirectToRoute('admin_post_list');
    }
    
    return $this->render('admin/post/new.html.twig', [
        'form' => $form,
    ]);
}
```

### Symfony 7.3 AssetMapper Integration

```bash
# v7.3 AssetMapper (recommended over Webpack)
composer require symfony/asset-mapper

# Add assets
php bin/console importmap:require bootstrap
php bin/console importmap:require @hotwired/stimulus
```

```yaml
# config/packages/asset_mapper.yaml
framework:
    asset_mapper:
        paths:
            - assets/
        excluded_patterns:
            - '*/tests/*'
```

### Symfony 7.3 Testing Patterns

#### Functional Testing (v7.3)
```php
class ApplicationAvailabilityFunctionalTest extends WebTestCase
{
    #[DataProvider('urlProvider')]  // v7.3: DataProvider attribute
    public function testPageIsSuccessful(string $url): void
    {
        $client = self::createClient();
        $client->request('GET', $url);
        
        $this->assertResponseIsSuccessful();
    }
    
    public static function urlProvider(): iterable
    {
        yield ['/'];
        yield ['/posts'];
    }
}
```

### Symfony 7.3 Performance Optimizations

```bash
# v7.3 production optimizations
composer dump-autoload --no-dev --classmap-authoritative
php bin/console cache:warmup --env=prod --no-debug
```

```yaml
# config/packages/prod/doctrine.yaml
doctrine:
    orm:
        query_cache_driver:
            type: pool
            pool: doctrine.query_cache_pool
```