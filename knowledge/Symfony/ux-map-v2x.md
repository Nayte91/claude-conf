## Header
- **Source URL**: https://raw.githubusercontent.com/symfony/ux/refs/heads/2.x/src/Map/doc/index.rst
- **Processed Date**: 2025-01-25
- **Domain**: symfony/ux
- **Version**: v2x
- **Weight Reduction**: ~39%
- **Key Sections**: Map Creation, Configuration, Markers, Geospatial Elements, Clustering, Rendering, Performance, Integration

## Body

### Core Components
- **Renderer-agnostic** map rendering framework
- **Providers**: Google Maps and Leaflet support
- **Integration**: PHP and JavaScript
- **Compatibility**: Live Component support

### Installation
```bash
composer require symfony/ux-map
```

### Configuration
**config/packages/ux_map.yaml**:
```yaml
ux_map:
    renderer: '%env(resolve:default::UX_MAP_DSN)%'
    google_maps:
        default_map_id: null
```

### Map Creation Patterns
```php
$map = new Map();
$map->center(new Point(48.8566, 2.3522))
    ->zoom(6)
    ->minZoom(3)
    ->maxZoom(10)
    ->fitBoundsToMarkers();
```

### Marker Management
```php
$map->addMarker(new Marker(
    position: new Point(48.8566, 2.3522),
    title: 'Paris',
    icon: Icon::url('marker.png')->width(24)->height(24)
));
```

### Advanced Geospatial Elements
- **Polygons** (with hole support)
- **Polylines**
- **Circles**
- **Rectangles**

### Clustering Strategies
```php
$algorithm = new GridClusteringAlgorithm();
$clusters = $algorithm->cluster($points, zoom: 5.0);
```

### Rendering Options
```twig
{{ ux_map(my_map, { 
    style: 'height: 300px', 
    'data-controller': 'mymap' 
}) }}
```

### Key Integration Techniques
- **Stimulus controller** event hooks
- **Live Component** trait
- **Renderer-specific** bridge options
- **Extra data** passing mechanism

### Performance Considerations
- **Clustering algorithms**
- **Zoom-level optimizations**
- **Renderer-specific** configuration

### Extensibility
- **Custom marker icons**
- **Bridge-specific** low-level options
- **Event-driven** customization

### Recommended Practices
- Use **environment-based** configuration
- Leverage **clustering** for large datasets
- Implement **custom Stimulus controllers** for advanced interactions