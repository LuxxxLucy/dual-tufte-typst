// LIMITATION (HTML target only): Typst's HTML export drops math equations
// with a warning. Inline `$x^2$` and display `$ ... $` both come out as
// empty `<span>` placeholders. Upstream Typst issue; revisit periodically.
//
// PDF target renders math correctly.
#import "../../../src/lib.typ": tufte
#show: tufte.with(title: [Math dropped in HTML (limitation)])

Inline math like $x^2 + y^2 = z^2$ should appear in this sentence — the HTML
target emits an empty span instead.

A numbered display equation:
$ integral_(-infinity)^infinity e^(-x^2) dif x = sqrt(pi) $ <gauss>

Reference @gauss.
