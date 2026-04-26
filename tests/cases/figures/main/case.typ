// Main-figure: image in main column, caption hoisted into the margin.
#import "../../../../src/lib.typ": tufte, main-figure
#show: tufte.with(title: [Main figure])

Body text before the figure.

#main-figure(
    image("../../../../assets/images/exports-imports.png", width: 100%),
    caption: [From Edward Tufte, _The Visual Display of Quantitative Information_, page 92.],
)

Body text after the figure.
