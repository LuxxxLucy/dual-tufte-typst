// Two main-figures in sequence — verifies figure counter advances and
// margin captions stack correctly without overlap.
#import "../../../../src/lib.typ": tufte, main-figure
#show: tufte.with(title: [Numbered figures])

Body before the first figure.

#main-figure(
    image("../../../../assets/images/exports-imports.png", width: 100%),
    caption: [Playfair's exports/imports time-series, 1700–1780.],
)

Connecting body between figures.

#main-figure(
    image("../../../../assets/images/rhino.png", width: 100%),
    caption: [Dürer's rhinoceros woodcut.],
)

Body after the second figure.
