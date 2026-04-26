// Math — inline + numbered display + labeled reference.
// Note: HTML target ignores equations (warning).
#import "../../../../src/lib.typ": tufte
#show: tufte.with(title: [Math])

Inline math like $E = m c^2$ flows in the text.

A numbered display equation:

$ integral_0^infinity e^(-x^2) dif x = sqrt(pi) / 2 $ <gauss>

Reference @gauss from prose.
