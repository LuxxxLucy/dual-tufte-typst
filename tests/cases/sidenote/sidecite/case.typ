// sidecite — bibliography citation rendered as a numbered margin note.
#import "../../../../src/lib.typ": tufte, sidecite
#show: tufte.with(style: "jialin", title: [Side citation])

A claim that needs a source#sidecite(<tufte2001>) appears with the full reference in the margin instead of jumping to a bibliography.

#bibliography("../../../../refs.bib", style: "chicago-author-date")
