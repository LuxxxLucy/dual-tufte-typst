// Scroll mode — `height: auto` produces a single tall page, no
// pagination, and the running header is suppressed.
#import "../../../../src/lib.typ": tufte, sidenote
#show: tufte.with(
    style: "jialin", title: [Scroll mode],
    config: (page: (width: 6in, height: auto)),
)

A short body to verify the page grows to fit#sidenote[Sidenote on a tall page.] without paginating. Header is suppressed because a running header on a 200cm page is meaningless.

A second paragraph keeps the layout honest; nothing about scroll mode should require the document to fill a fixed page.
