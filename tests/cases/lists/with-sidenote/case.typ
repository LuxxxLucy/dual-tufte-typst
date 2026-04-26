// List item containing an inline sidenote — checks that the sidenote
// triplet folds inside <li> without breaking list structure.
#import "../../../../src/lib.typ": tufte, sidenote
#show: tufte.with(title: [List with inline sidenote])

A short list with a sidenote on the second item:

- first item
- second item with a sidenote#sidenote[Note attached to the second list item.]
- third item

Body paragraph after the list.
