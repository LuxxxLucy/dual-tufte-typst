// Sidenote attached to a heading — exercises the triplet folding
// inside <h2> rather than <p>.
#import "../../../../src/lib.typ": tufte, sidenote
#show: tufte.with(title: [Sidenote in heading])

Intro paragraph.

== Section title with aside#sidenote[A note keyed to the section heading.]

Body paragraph under the section.
