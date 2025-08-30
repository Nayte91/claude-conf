## Header
- **Source URL**: https://raw.githubusercontent.com/symfony/symfony-docs/refs/heads/7.3/best_practices.rst
- **Processed Date**: 2025-01-25
- **Domain**: symfony/symfony-docs
- **Version**: v73
- **Weight Reduction**: ~44%
- **Key Sections**: Project Structure, Configuration, Services, Controllers, Forms, Security, Testing, Assets, i18n, Architecture

## Body

### Project Structure
- **Use default** Symfony directory structure
- **Flat, self-explanatory** organization
- **Key directories**:
  - `src/`: Core application logic
  - `config/`: Configuration files
  - `public/`: Web entry point
  - `templates/`: Twig templates
  - `tests/`: Test suite

### Configuration Management
- **Environment variables** for infrastructure configuration
- **Secrets management** for sensitive data
- **Application parameters** in `services.yaml`
- **Use `app.` prefix** for parameters to avoid namespace collisions
- **PHP constants** for rarely changing configuration options

### Service Design
- **Prefer autowiring** for service configuration
- **Make services private** by default
- **Use YAML** for service configuration
- **Implement dependency injection** systematically

### Controller Patterns
- **Extend `AbstractController`**
- **Use attributes** for routing, caching, security
- **Inject dependencies** via constructor/method arguments
- **Minimize controller logic** complexity

### Form Handling
- **Define forms as PHP classes**
- **Add form buttons** in templates
- **Attach validation constraints** to domain objects
- **Use single action** for rendering and processing forms

### Security Practices
- **Define single firewall** when possible
- **Use `auto` password hasher**
- **Implement security voters** for complex authorization logic

### Testing Strategies
- **Implement smoke tests** for URL availability
- **Hard-code URLs** in functional tests
- **Use PHPUnit data providers** for comprehensive testing

### Frontend Asset Management
- **Utilize AssetMapper** for modern web asset handling
- **Simplify JavaScript and CSS** processing

### Internationalization
- **Prefer XLIFF** translation format
- **Use descriptive** translation keys
- **Focus on translation** context

### Key Architectural Principles
- **Minimize bundle usage**
- **Prioritize PHP namespaces** for code organization
- **Maintain separation** of concerns
- **Optimize for maintainability** and flexibility