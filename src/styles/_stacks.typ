// Shared font stacks. Imported by individual style files so each style
// only declares the *intentional* font choice (not the fallback chain).

#let etbembo = ("ETBembo", "Palatino", "Georgia")
#let gillsans = ("Gill Sans", "Helvetica")

// Söhne is paid; Inter (bundled via assets/fonts/fetch.sh) is the free
// fallback. JetBrains Mono is bundled too.
#let sohne = ("Söhne", "Inter", "Helvetica Neue", "Helvetica", "Arial")
#let sohne-mono = ("Söhne Mono", "JetBrains Mono", "Menlo", "Monaco")

// Roboto Condensed renamed in-place to "RobotoCondensed" by fetch.sh
// because Typst 0.14 strips axis-suffix words (turning "Roboto
// Condensed" into "Roboto"). The no-space form survives.
#let roboto-condensed = ("RobotoCondensed", "Roboto", "Helvetica Neue", "Helvetica", "Arial")
