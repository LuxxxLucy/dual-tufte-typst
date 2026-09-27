#import "/src/lib.typ": *
#show: tufte

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
