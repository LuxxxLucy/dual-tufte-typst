// full-width body block: spans main + margin column.
#import "../../../../src/lib.typ": tufte, full-width
#show: tufte.with(title: [Full-width block])

Normal-width prose first, constrained to the main column.

#full-width[
This block spans across the main column and into the margin area. Use sparingly — research suggests 50–75 characters per line optimizes reading comfort, but tables or specifications sometimes benefit from extra width.
]

Back to normal-width prose.
