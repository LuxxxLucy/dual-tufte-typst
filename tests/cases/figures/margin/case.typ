#import "/src/lib.typ": *
#show: tufte

Body text before the margin figure.#margin-figure(
    image("../../../../assets/images/rhino.png", width: 100%),
    caption: [Image of a Rhinoceros — Albrecht Dürer's woodcut (1515), recreated from written descriptions.],
) Continuing body, which flows uninterrupted while the figure occupies the margin.
