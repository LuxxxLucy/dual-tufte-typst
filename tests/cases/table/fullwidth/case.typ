// Wide table — wrapped in our `full-width` helper so it emits inside
// a div.fullwidth and spans across main + margin via tufte-css's
// `div.fullwidth, table.fullwidth { width: 100% }` rule.
#import "../../../../src/lib.typ": tufte, full-width
#show: tufte.with(style: "jialin", title: [Full-width table])

Body before the table.

#full-width[
    #table(
        // 1fr columns so the table fills the wideblock; bare `columns: 6`
        // makes auto-width columns that fit content.
        columns: (1fr,) * 6,
        align: (left, right, right, right, right, right),
        [*Quarter*], [*Sidenote*], [*Marginnote*], [*Figure*], [*Quote*], [*Total*],
        [Q1], [12], [9],  [6],  [3], [30],
        [Q2], [15], [11], [8],  [4], [38],
        [Q3], [18], [13], [10], [5], [46],
        [Q4], [20], [14], [11], [6], [51],
    )
]

Body after the table.
