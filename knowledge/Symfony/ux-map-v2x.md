## Header
- **Source**: https://raw.githubusercontent.com/symfony/ux/refs/heads/2.x/src/Map/doc/index.rst
- **Processed Date**: 2025-01-25
- **Domain**: symfony/ux
- **Version**: v2x
- **Weight Reduction**: ~39%
- **Key Sections**: Map Creation, Configuration, Markers, Geospatial Elements, Clustering, Rendering, Performance, Integration

## Body

### UX Map 2.x Configuration

```yaml
# config/packages/ux_map.yaml
ux_map:
    renderer: '%env(UX_MAP_DSN)%'  # e.g., 'google', 'leaflet'
    google_maps:
        api_key: '%env(GOOGLE_MAPS_API_KEY)%'
        default_map_id: 'my_map_id'
    leaflet:
        tile_layer: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
```

### Map Object Construction (2.x)

```php
use Symfony\UX\Map\Map;
use Symfony\UX\Map\Point;

$map = (new Map())
    ->center(new Point(latitude: 48.8566, longitude: 2.3522))
    ->zoom(10)
    ->fitBoundsToMarkers();
```

### Marker Implementation (2.x)

```php
use Symfony\UX\Map\Marker;
use Symfony\UX\Map\Icon;

$marker = new Marker(
    position: new Point(48.8566, 2.3522),
    title: 'Paris',
    infoWindow: '<h3>Paris</h3><p>Capital of France</p>',
    icon: Icon::url('/images/marker.png')->size(32, 32)
);

$map->addMarker($marker);
```

### Geospatial Shapes (2.x)

```php
use Symfony\UX\Map\Polygon;
use Symfony\UX\Map\Polyline;

// Polygon with holes
$polygon = new Polygon(
    points: [/* outer boundary points */],
    holes: [/* hole points arrays */],
    strokeColor: '#FF0000',
    fillColor: '#FF000055'
);

// Polyline
$polyline = new Polyline(
    points: [/* line points */],
    strokeColor: '#0000FF',
    strokeWeight: 3
);

$map->addPolygon($polygon);
$map->addPolyline($polyline);
```

### Clustering Configuration (2.x)

```php
use Symfony\UX\Map\Clustering\GridClusteringAlgorithm;

$algorithm = new GridClusteringAlgorithm(gridSize: 60);
$clusters = $algorithm->cluster($points, zoom: 10);
```

### Twig Rendering (2.x)

```twig
{{ ux_map(map, {
    'style': 'height: 400px; width: 100%',
    'data-controller': 'my-map',
    'data-my-map-api-key-value': google_maps_api_key
}) }}
```

### LiveComponent Integration (2.x)

```php
use Symfony\UX\LiveComponent\Attribute\AsLiveComponent;
use Symfony\UX\Map\Bridge\Twig\MapRuntime;

#[AsLiveComponent]
class MapComponent
{
    public function __construct(
        private MapRuntime $mapRuntime
    ) {}

    public function getMap(): Map
    {
        return $this->mapRuntime->createMap();
    }
}
```

### JavaScript Bridge Options (2.x)

```php
$map->setBridgeOptions([
    'gestureHandling' => 'cooperative',
    'disableDefaultUI' => false,
    'styles' => [/* custom map styles */]
]);
```