// Sidenote whose body mixes emph + strong + raw.
#import "../../../../src/lib.typ": tufte, sidenote
#show: tufte.with(style: "jialin", title: [Sidenote with emphasis])

The body claim#sidenote[A note with _emphasis_, *strong*, and a `code-snippet` — all should render in the margin span.] continues here.
