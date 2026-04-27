// Title block with author + email + date — handout-style meta row.
#import "../../../../src/lib.typ": tufte
#show: tufte.with(
    style: "jialin", title: [Title block with email],
    author: "Jialin Lu",
    email: "luxxxlucy@gmail.com",
    date: datetime(year: 2026, month: 4, day: 24),
)

Body paragraph follows the title block.
