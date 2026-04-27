// Sidenote whose body contains an inline link — the link must render
// inside the margin span, not break paragraph flow.
#import "../../../../src/lib.typ": tufte, sidenote
#show: tufte.with(style: "jialin", title: [Sidenote with link])

A claim worth a citation#sidenote[See #link("https://example.com/")[the example post] for context.] in body. The sidenote in the right margin should contain a working link.
