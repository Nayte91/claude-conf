# Diàtaxis Documentation System Framework

## Four Documentation Types

Documentation organized into four distinct types with specific implementation requirements:

### 1. Tutorials (Learning-Oriented)
Step-by-step guided learning for beginners.

**Implementation Requirements**:
- Focus on "learning how" over "learning what"
- Provide immediate, visible results at each step
- Ensure repeatability and consistency
- Progress from simple to complex operations
- Minimize abstract explanations
- Take full responsibility for user's success

**Quality Criteria**:
- Every action produces comprehensible results
- Steps work reliably across environments
- Builds confidence through achievable goals
- Covers range of essential tools/operations

### 2. How-to Guides (Goal-Oriented)
Direct solutions for specific problems.

**Implementation Requirements**:
- Address specific "How do I...?" questions
- Assume basic knowledge exists
- Focus on practical results over explanation
- Provide clear sequence of steps
- Allow implementation flexibility
- Use descriptive, action-oriented titles

**Quality Criteria**:
- Solves particular, well-defined problems
- Prioritizes usability over completeness
- Avoids teaching fundamental concepts
- Delivers practical, actionable solutions

### 3. Reference (Information-Oriented)
Technical specifications and operational details.

**Implementation Requirements**:
- Mirror codebase structure for navigation alignment
- Maintain consistent format, tone, and structure
- Focus solely on accurate description
- Include basic usage and precautions
- Link to other documentation types for context
- Avoid instruction, explanation, or opinion

**Quality Criteria**:
- Code-determined organization
- Lists functions, fields, attributes, methods
- Simple, precise, up-to-date descriptions
- Dictionary/encyclopedia-like consistency

### 4. Explanation (Understanding-Oriented)
Contextual understanding and design rationale.

**Implementation Requirements**:
- Provide context and background information
- Discuss alternatives and perspectives
- Explore design decisions and rationale
- Avoid instructional or reference content
- Support leisurely, away-from-code reading

**Quality Criteria**:
- Broadens understanding beyond immediate tasks
- Explores "why" rather than "how" or "what"
- Offers multiple viewpoints on topics
- Deepens conceptual comprehension

## Implementation Strategy
- Maintain strict separation between documentation types
- Mirror system architecture in organization
- Prevent content mixing across types

## Agent Optimization Principles

### Content Efficiency
- Remove human-oriented elements (anecdotes, historical context)
- Eliminate redundant explanations across types
- Focus on actionable information and specifications
- Maintain technical accuracy while reducing verbosity

### Navigation Optimization
- Align reference structure with codebase organization
- Create clear type distinctions for agent routing
- Minimize cross-reference overhead
- Support direct access to specific information types

### Implementation Guidelines
- Each documentation type requires unique writing approach
- Clear structure benefits both content creators and consumers
- Systematic organization improves maintenance efficiency
- Type-specific focus enhances information retrieval accuracy

## Quality Assurance Framework

### Content Validation
- Tutorials must work reliably across environments
- How-to guides must solve stated problems effectively
- Reference documentation must match actual implementation
- Explanations must provide genuine understanding value

### Maintenance Requirements
- Regular testing of tutorial procedures
- Validation of how-to guide effectiveness
- Synchronization of reference with code changes
- Review of explanation relevance and accuracy


## Anti-patterns to Avoid
- Mixing tutorials with explanations
- Converting how-to guides to tutorials
- Including explanations in reference documentation
- Omitting context in explanations

## Technical Integration
- Automate code/documentation synchronization
- Validate documented procedures with tests
- Separate emergency procedures from explanations
- Maintain API references with complete interfaces