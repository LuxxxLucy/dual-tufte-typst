// All three heading levels in one document — verify hierarchy rendering
// (h1 > h2 > h3) and consistent extralight italic styling.
#import "../../../../src/lib.typ": tufte
#show: tufte.with(style: "jialin", title: [Heading hierarchy])

Body intro paragraph.

= First-level heading

A paragraph under the first-level heading.

== Second-level heading

A paragraph under the second-level heading.

=== Third-level heading

A paragraph under the third-level heading.
