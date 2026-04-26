// Inline subscript and superscript — Typst native primitives.
#import "../../../../src/lib.typ": tufte
#show: tufte.with(title: [Sub / superscript])

Water is H#sub[2]O. Einstein's identity: E = mc#super[2]. Both should render at the correct vertical position and font size.
