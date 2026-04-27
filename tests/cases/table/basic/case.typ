// Body table — verifies Typst's html target emits a usable <table> with
// headers and data rows. tufte-css applies .table-wrapper / column-aware
// styling at 760px and below; on wider viewports the table just sits at
// section width.

A short table with three columns and four rows:

#table(
    columns: 3,
    align: (left, right, right),
    [*Item*],         [*Count*], [*Share*],
    [Sidenotes],      [12],       [40%],
    [Marginnotes],    [9],        [30%],
    [Figures],        [6],        [20%],
    [Other],          [3],        [10%],
)

Body paragraph after the table.
