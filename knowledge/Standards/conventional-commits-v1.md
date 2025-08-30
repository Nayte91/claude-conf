## Header
- **Source URL**: https://www.conventionalcommits.org/en/v1.0.0/
- **Processed Date**: 2025-01-25
- **Domain**: conventionalcommits.org
- **Version**: v1.0.0
- **Weight Reduction**: ~42%
- **Key Sections**: Message Structure, Types, Scopes, Breaking Changes, SemVer Mapping, Examples

## Body

### Commit Message Structure

#### Basic Format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Components
- **Type**: Required prefix indicating commit category
- **Scope**: Optional context in parentheses
- **Description**: Required summary of changes
- **Body**: Optional detailed explanation
- **Footer**: Optional metadata (breaking changes, references)

### Core Types

#### Required Types
- **`fix:`** - Patches a bug (correlates with PATCH in SemVer)
- **`feat:`** - Introduces new feature (correlates with MINOR in SemVer)

#### Recommended Additional Types
- **`build:`** - Changes to build system or dependencies
- **`chore:`** - Maintenance tasks, no production code change
- **`ci:`** - Changes to CI configuration and scripts
- **`docs:`** - Documentation only changes
- **`style:`** - Code style changes (formatting, semicolons)
- **`refactor:`** - Code change that neither fixes bug nor adds feature
- **`perf:`** - Code change that improves performance
- **`test:`** - Adding or correcting tests

### Scope Usage

#### Scope Format
```
feat(parser): add array parsing capability
fix(api): handle null responses correctly
```

#### Scope Guidelines
- **Optional context** in parentheses after type
- **Describes section** of codebase affected
- **Examples**: `api`, `parser`, `cli`, `auth`, `database`

### Breaking Changes

#### Indication Methods

**Method 1: Footer**
```
feat: add new authentication system

BREAKING CHANGE: Authentication tokens now require refresh mechanism
```

**Method 2: Type/Scope Suffix**
```
feat!: add new authentication system
feat(api)!: change response format
```

#### Breaking Change Rules
- **MUST indicate** breaking changes
- **Can use either method** or both
- **Footer format**: `BREAKING CHANGE: <description>`
- **Suffix format**: Append `!` after type/scope

### SemVer Version Mapping

#### Version Correlation
- **`fix:`** → **PATCH** (x.y.Z)
- **`feat:`** → **MINOR** (x.Y.z)  
- **`BREAKING CHANGE`** → **MAJOR** (X.y.z)

#### Version Impact Examples
```
fix: resolve memory leak          # 1.0.1
feat: add user preferences        # 1.1.0
feat!: change API response format # 2.0.0
```

### Footer Formats

#### Footer Types
- **Breaking Changes**: `BREAKING CHANGE: <description>`
- **References**: `Refs: #123`, `Closes #456`
- **Co-authored**: `Co-authored-by: Name <email>`
- **Custom**: `Reviewed-by: Name`

#### Footer Rules
- **Use `-` tokens** instead of whitespace
- **Multiple footers** allowed
- **Case sensitive** for BREAKING CHANGE

### Specification Rules

#### MUST Requirements
1. **Commits MUST** have type prefix with colon and space
2. **Description MUST** immediately follow type/scope colon-space
3. **Type MUST** be lowercase (except BREAKING CHANGE footer)
4. **Breaking changes MUST** be indicated appropriately

#### MAY Requirements
1. **Body MAY** be provided after blank line
2. **Scope MAY** be provided in parentheses
3. **Footer(s) MAY** be provided after blank line
4. **Additional types MAY** be used beyond fix/feat

### Examples

#### Basic Examples
```
fix: prevent racing of requests
feat: add request timeout configuration
docs: update API documentation
style: format code according to style guide
```

#### With Scope
```
feat(lang): add Polish language support
fix(parser): handle edge case in URL parsing
perf(core): improve startup time by 40%
test(api): add integration tests for auth
```

#### With Body
```
feat: add user preference system

Allow users to customize their experience through
a comprehensive preference system including themes,
notifications, and accessibility options.
```

#### With Breaking Changes
```
feat!: drop Node.js 14 support

BREAKING CHANGE: Node.js 14 is no longer supported.
Minimum required version is now Node.js 16.
```

#### Complex Example
```
feat(auth)!: implement OAuth 2.0 integration

Add OAuth 2.0 authentication flow with support for
multiple providers including Google, GitHub, and Microsoft.

BREAKING CHANGE: The previous basic auth system has been
replaced with OAuth 2.0. Users will need to re-authenticate.

Closes #123
Refs #456
Co-authored-by: John Doe <john@example.com>
```

### Implementation Best Practices

#### Commit Strategy
- **Make atomic commits** when possible
- **Use consistent style** across project
- **Write descriptive descriptions** 
- **Include context** in scope when helpful

#### Automation Integration
- **Use with semantic-release** for automated versioning
- **Integrate with changelog generators**
- **Configure linting** to enforce format
- **Set up commit hooks** for validation

#### Team Guidelines
- **Establish scope conventions** for project
- **Document additional types** used
- **Train team members** on format
- **Use tooling** to assist adoption

### Validation Rules

#### Format Validation
```regex
^(build|chore|ci|docs|feat|fix|perf|refactor|style|test)(\(.+\))?!?: .{1,50}
```

#### Required Elements
- **Type present** and valid
- **Colon and space** after type/scope
- **Description provided** and under 50 chars
- **Proper case** for type (lowercase)

#### Optional Elements  
- **Scope format** matches `([a-z]+)`
- **Body separated** by blank line
- **Footer format** follows token rules
- **Breaking change** properly indicated