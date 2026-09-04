// Two figures in sequence: the counter advances, @ref resolves in both
// targets, and a label inside full-width still lands on the figure.

Body before the first figure. See @playfair and @minard.

#figure(
    image("../../../../assets/images/exports-imports.png", width: 100%),
    caption: [Playfair's exports/imports time-series, 1700–1780.],
) <playfair>

Connecting body between figures.

#full-width[#figure(
    image("../../../../assets/images/napoleons-march.png", width: 100%),
    caption: [Minard's map of the 1812 campaign.],
) <minard>]

Body after the second figure.
