## Header
- **Source**: https://stimulus.hotwired.dev/reference
- **Processed Date**: 2025-01-25
- **Domain**: stimulus.hotwired.dev
- **Version**: Latest
- **Weight Reduction**: ~45%
- **Key Sections**: Controllers, Lifecycle, Targets, Actions, Values, Events, Data Attributes

## Body

### Controller Structure

#### Basic Controller Definition
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Controller implementation
}
```

#### Controller Properties
- **`this.application`** - Access to Stimulus application instance
- **`this.element`** - Associated HTML element  
- **`this.identifier`** - Controller's unique identifier

#### Controller Registration
```javascript
// Automatic (Rails/Webpack)
// Manual registration:
application.register("reference", ReferenceController)
```

### Naming Conventions

#### File to Identifier Mapping
- **`clipboard_controller.js`** → `clipboard`
- **`date_picker_controller.js`** → `date-picker`  
- **`users/list_item_controller.js`** → `users--list-item`

#### HTML Usage
```html
<div data-controller="clipboard">
<div data-controller="date-picker">
<div data-controller="users--list-item">
```

### Lifecycle Callbacks

#### Core Lifecycle Methods
```javascript
export default class extends Controller {
  initialize() {
    // Called once when controller is first instantiated
    // Initial setup before DOM connection
  }

  connect() {
    // Triggered when controller connects to document
    // DOM-ready setup operations
  }

  disconnect() {
    // Called when controller disconnects from document
    // Cleanup operations
  }
}
```

#### Target-Specific Callbacks
```javascript
// Called when specific target connects/disconnects
[name]TargetConnected(target) {
  // Target connection handling
}

[name]TargetDisconnected(target) {
  // Target disconnection handling  
}
```

### Targets

#### Target Declaration
```javascript
export default class extends Controller {
  static targets = ["query", "errorMessage", "results"]
}
```

#### Target Access Patterns
```javascript
// Singular target (throws error if missing)
this.queryTarget

// Plural targets (returns array)
this.queryTargets

// Existence check (returns boolean)
this.hasQueryTarget
```

#### HTML Target Markup
```html
<div data-controller="search">
  <input data-search-target="query">
  <div data-search-target="errorMessage"></div>
  <div data-search-target="results"></div>
</div>
```

#### Target Callbacks
```javascript
queryTargetConnected(element) {
  // Handle target connection
}

queryTargetDisconnected(element) {
  // Handle target disconnection
}
```

### Actions

#### Action Declaration
```html
<!-- Basic action -->
<button data-action="click->search#submit">Search</button>

<!-- Event can be omitted for default events -->
<button data-action="search#submit">Search</button>

<!-- Multiple actions -->
<input data-action="keyup->search#filter input->search#submit">
```

#### Action Descriptor Components
- **Event name** (e.g., "click", "keyup")
- **Controller identifier** (e.g., "search")  
- **Method name** (e.g., "submit")

#### Event Modifiers
```html
<!-- Keyboard modifiers -->
<input data-action="keydown.esc->modal#close">
<input data-action="keydown.enter->form#submit">

<!-- Global event targets -->
<div data-action="resize@window->layout#resize">
<div data-action="scroll@document->navbar#update">

<!-- Event options -->
<div data-action="scroll:passive@window->parallax#update">
<div data-action="click:capture->dropdown#close">
```

#### Action Parameters
```html
<button data-action="gallery#next"
        data-gallery-id-param="123"
        data-gallery-direction-param="forward">
```

```javascript
next(event) {
  const id = event.params.id        // 123 (Number)
  const direction = event.params.direction  // "forward" (String)
}
```

### Values

#### Value Declaration
```javascript
export default class extends Controller {
  static values = {
    url: String,
    interval: Number,
    params: Object,
    enabled: Boolean,
    items: Array
  }
}
```

#### Value Access Patterns
```javascript
// Getter (reads data attribute)
this.urlValue

// Setter (writes data attribute)  
this.urlValue = "/new-endpoint"

// Existence check
this.hasUrlValue
```

#### Default Values
```javascript
static values = {
  url: { type: String, default: "/default" },
  interval: { type: Number, default: 5000 },
  enabled: { type: Boolean, default: true }
}
```

#### HTML Value Attributes
```html
<div data-controller="slideshow" 
     data-slideshow-url-value="/slides"
     data-slideshow-interval-value="3000"
     data-slideshow-enabled-value="true">
```

#### Value Change Callbacks
```javascript
urlValueChanged(value, previousValue) {
  // React to URL value changes
}

intervalValueChanged(value, previousValue) {
  // React to interval value changes  
}
```

### Event Handling

#### Custom Event Dispatch
```javascript
export default class extends Controller {
  notify() {
    // Basic event dispatch
    this.dispatch("success")
    
    // With custom data
    this.dispatch("success", { 
      detail: { id: 123, message: "Operation completed" }
    })
    
    // With options
    this.dispatch("success", { 
      detail: { result: "data" },
      bubbles: true,
      cancelable: true 
    })
  }
}
```

#### Listening to Custom Events
```html
<div data-action="slideshow:success->notification#show">
```

### Data Attributes Reference

#### Core Attributes
- **`data-controller="identifier"`** - Controller registration
- **`data-[controller]-target="name"`** - Target declaration
- **`data-action="event->controller#method"`** - Action binding
- **`data-[controller]-[name]-value="data"`** - Value storage
- **`data-[controller]-[name]-param="data"`** - Action parameters

#### Attribute Naming Rules
- **Controller identifier**: kebab-case
- **Target names**: camelCase → kebab-case  
- **Value names**: camelCase → kebab-case
- **Parameter names**: camelCase → kebab-case

### Advanced Features

#### Controller Scoping
- Controllers manage their element and children
- Nested controllers have isolated scopes  
- Multiple controllers per element supported

#### Cross-Controller Communication
```javascript
// Preferred: Event-based communication
this.dispatch("selection-changed", { detail: { id: this.selectedId } })

// Direct access (use sparingly)
const otherController = this.application.getControllerForElementAndIdentifier(
  element, "other-controller"
)
```

#### Conditional Loading
```javascript
export default class extends Controller {
  static shouldLoad() {
    // Return boolean for conditional registration
    return window.matchMedia("(min-width: 768px)").matches
  }
  
  static afterLoad(identifier, application) {
    // Post-registration setup
  }
}
```

### CSS Classes

#### CSS Class Declaration
```javascript
export default class extends Controller {
  static classes = ["loading", "error", "success"]
}
```

#### CSS Class Usage
```javascript
// Apply/remove classes
this.element.classList.add(this.loadingClass)
this.element.classList.remove(this.loadingClass)

// Check class existence
if (this.hasLoadingClass) {
  // Class is defined
}
```

#### HTML CSS Class Definition
```html
<div data-controller="form"
     data-form-loading-class="spinner"
     data-form-error-class="text-red-500"
     data-form-success-class="text-green-500">
```

### Best Practices

#### Controller Design
- **Single responsibility** per controller
- **Descriptive naming** for methods and targets
- **Event-based communication** between controllers
- **Cleanup resources** in disconnect()

#### Performance
- **Use lifecycle callbacks** appropriately
- **Avoid DOM queries** outside of targets
- **Leverage event delegation** 
- **Clean up timers/listeners** in disconnect()

#### Code Organization
```javascript
export default class extends Controller {
  static targets = ["input", "output"]
  static values = { apiUrl: String }
  static classes = ["loading", "error"]
  
  initialize() { /* Setup */ }
  connect() { /* Connect */ }
  disconnect() { /* Cleanup */ }
  
  // Action methods
  submit(event) { /* Handle submission */ }
  
  // Target callbacks
  inputTargetConnected(element) { /* Setup input */ }
  
  // Value callbacks  
  apiUrlValueChanged(value, previousValue) { /* Handle change */ }
  
  // Private methods
  #validateInput() { /* Internal logic */ }
}
```