// Full-width figure: spans across main column and right margin.
#import "../../../../src/lib.typ": tufte, full-width-figure
#show: tufte.with(style: "jialin", title: [Full-width figure])

Body text before.

#full-width-figure(
    image("../../../../assets/images/napoleons-march.png", width: 100%),
    caption: [Charles Joseph Minard's flow map of Napoleon's 1812 Russian campaign, showing army size, location, direction, and temperature.],
)

Body text after.
