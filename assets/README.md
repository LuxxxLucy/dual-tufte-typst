# Assets Directory

This directory contains resources used in examples and tests.

## Images

The `images/` subdirectory contains classic Tufte-style visualizations downloaded from [tufte-css](https://edwardtufte.github.io/tufte-css/):

- **exports-imports.png** - William Playfair's time-series chart showing exports and imports between Denmark and Norway (1700-1780), from his _Commercial and Political Atlas_ (1786). One of the earliest known time-series charts.

- **napoleons-march.png** - Charles Joseph Minard's famous flow map of Napoleon's Russian campaign of 1812. Shows the size of the army, location, direction, and temperature. Tufte calls this "probably the best statistical graphic ever drawn."

- **rhino.png** - Albrecht Dürer's iconic _Rhinoceros_ woodcut (1515). A famous example of early scientific illustration, created from written descriptions despite Dürer never seeing a living rhinoceros.

These images are used to demonstrate the three figure types in Tufte-style layouts:
- Standard figures (image in text, caption in margin)
- Margin figures (entire figure in margin)
- Full-width figures (spanning text area and margin)

## Usage

Reference images from test files using relative paths:

```typst
#figure(
  image("../../assets/images/rhino.png", width: 100%),
  caption: [Albrecht Dürer's Rhinoceros (1515)],
)
```

## License

These images are historical works in the public domain.
