// Two sidenotes in one paragraph — counter advances, vertical anchoring distinct.
#import "../../../../src/lib.typ": tufte, sidenote
#show: tufte.with(style: "jialin", title: [Two sidenotes])

A paragraph with two markers.#sidenote[First note. Anchored to the first marker.] Continued prose to push the second marker further down.#sidenote[Second note. Anchored below the first.] After both.
