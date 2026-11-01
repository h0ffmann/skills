---
name: maps
description: "Show areas, points and data fields on a web map with MapLibre and free tiles first, or Mapbox GL when a project already uses it. Covers CAP alert areas to GeoJSON, data-driven styling, performance and token safety. Use for any map on a page, an app or an image."
---

# maps

A map shows where a fact applies. It never adds an area, a time or a severity that the source
does not state. The page must stay complete without the map.

## Stack

- **Default: MapLibre GL JS** (BSD-3-Clause) with free tiles and no key: OpenFreeMap styles, or
  one self-hosted Protomaps PMTiles file. Pin the version (`maplibre-gl@<x.y.z>`).
- **Mapbox GL JS** only where the project already uses it. Use only a public `pk.` token,
  restricted to the site's URLs. Write it into the page at deploy time. The committed file stays
  empty. Never put an `sk.` token in a page. With no token, the page says so and shows the list.
- Never add a paid tile service without the owner's approval.
- Always show the attribution: "© OpenStreetMap contributors" and the tile provider.

## CAP 1.2 areas to GeoJSON

1. **Polygon.** CAP writes `lat,lon`. GeoJSON writes `[lon, lat]`. Swap each pair. Check one
   point by hand. A swapped polygon draws in the ocean.
2. **Close the ring.** The first and the last point are equal.
3. **Circle.** CAP writes `lat,lon radius` in km. Make a 64-point polygon. Keep the centre and
   the radius in the properties.
4. **Geocode.** Get the shape from the official source (for Brazil, the IBGE malhas API) and
   cache it. Never draw a guessed shape.
5. **No area.** Draw no shape. Show the area text.

## Style

- Colour by severity or by the data value, with one fixed palette for all channels.
- Fill at 30% opacity with a 2 px outline, so the base map stays readable.
- Put the value in text too: a label and a legend. Colour is never the only signal.
- Fit the view to the data bounds, with padding. Never zoom past the precision of the source.
- A field that is estimated between measured points says so in the legend.

## Performance

- Use GeoJSON sources and layers for many features. Use DOM markers only for a few points that
  need focus and an `aria-label`.
- Start the map after the page's text renders. Load a layer only when the visitor selects it.
- Remove sources, layers and listeners when a view closes.
- `prefers-reduced-motion` stops animated layers.

## Check before a PR

1. One real record from each source draws in the correct place.
2. The attribution shows.
3. No request goes to a paid service (examine the network tab).
4. The page works without the map.
