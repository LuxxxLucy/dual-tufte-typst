// Shared font stacks. Imported by individual style files so each style
// only declares the *intentional* font choice (not the fallback chain).

#let etbembo = ("ETBembo", "Palatino", "Georgia")
#let gillsans = ("Gill Sans", "Helvetica")

// Inter, bundled via assets/fonts/fetch.sh. Used by orange-happy/bluewhite
// as a free sans alternative to commercial faces (Söhne, Colfax).
#let inter = ("Inter", "Helvetica Neue", "Helvetica", "Arial")
#let inter-mono = ("JetBrains Mono", "Menlo", "Monaco", "Courier")

// Roboto Condensed renamed in-place to "RobotoCondensed" by fetch.sh
// because Typst 0.14 strips axis-suffix words (turning "Roboto
// Condensed" into "Roboto"). The no-space form survives.
#let roboto-condensed = ("RobotoCondensed", "Roboto", "Helvetica Neue", "Helvetica", "Arial")
