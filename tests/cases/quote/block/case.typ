// Block quote with attribution.
#import "../../../../src/lib.typ": tufte
#show: tufte.with(title: [Block quote])

Lead-in prose.

#quote(block: true, attribution: [Edward Tufte, _Visual Display of Quantitative Information_])[
    Graphical excellence is that which gives to the viewer the greatest number of ideas in the shortest time with the least ink in the smallest space.
]

Trailing prose.
