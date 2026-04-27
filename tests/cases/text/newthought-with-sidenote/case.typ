// Newthought opener + sidenote in the same paragraph — common Tufte
// pattern. Verify the small-caps span and the sidenote triplet coexist.
#import "../../../../src/lib.typ": tufte, new-thought, sidenote
#show: tufte.with(style: "jialin", title: [Newthought + sidenote])

#new-thought[In his later writing], Tufte often pairs a small-caps section opener with an immediate marginal aside.#sidenote[The opener uses small-caps; the aside lives in the right margin.] The remainder of the paragraph continues in body type.
