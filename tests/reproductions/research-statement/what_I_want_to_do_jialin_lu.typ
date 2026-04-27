#import "/src/lib.typ": *
#import "@preview/cetz:0.3.2"

#show: tufte.with(
  title: "What I Want to Do",
  author: "Jialin Lu",
  date: "2026-04",
)

#let venn-fig = align(center, cetz.canvas(length: 0.7cm, {
  import cetz.draw: *
  let r = 0.85
  let c-top = (0, 0.55)
  let c-bl = (-0.5, -0.29)
  let c-br = (0.5, -0.29)

  let col-top = rgb(70, 130, 200, 90)
  let col-bl = rgb(220, 130, 80, 90)
  let col-br = rgb(110, 180, 100, 90)

  circle(c-top, radius: r, fill: col-top, stroke: (paint: rgb(40, 80, 150), thickness: 0.4pt))
  circle(c-bl, radius: r, fill: col-bl, stroke: (paint: rgb(170, 90, 40), thickness: 0.4pt))
  circle(c-br, radius: r, fill: col-br, stroke: (paint: rgb(60, 130, 60), thickness: 0.4pt))

  content((0, 1.6), anchor: "south", text(size: 5pt, fill: rgb(40, 80, 150), style: "normal")[it matters])
  content((-1.55, -0.29), anchor: "east", text(size: 5pt, fill: rgb(170, 90, 40), style: "normal")[I care])
  content((1.55, -0.29), anchor: "west", text(size: 5pt, fill: rgb(60, 130, 60), style: "normal")[I can do it])

  line((0, -1.35), (0, -0.15), mark: (end: ">", size: 0.01, fill: black), stroke: (paint: black, thickness: 0.9pt))
  content((0, -1.5), anchor: "north", text(size: 5pt, style: "normal")[the important thing to do])
}))

At some point last month I began to lose joy in the work I do, and ended up spending too much time scrolling on my phone during the day.
I realized that I am not working on the important things#sidenote[
  Richard Hamming, _You and Your Research_ (1986)

  #venn-fig
]. I grilled myself on what then is the important thing to do,
and after some research (and countless chats with friends and LLMs),
I think robotic construction is the one:

1. planning with all the available information and assets,
2. designing physical objects and their assembly plans,
3. executing the task reliably.

= What I want to do

I think in general we have two kinds of research:
idea-driven research and goal-driven research.
The former picks a more well-scoped question for incremental and tangible progress.
The latter is a sustained long-term push.

For the long-term goal, I want to build general planning and execution systems that adapt to real-world scenarios and use all available knowledge and context.
#sidenote[
especially in places with poor conditions, where human labour is not easily accessible or economically viable, including
  - dangerous or remote places: high altitudes, offshore sites, disaster zones.
  - tasks where automation is cheaper, more precise, or more reliable than human labour.

  Also, I think in two decades we will have construction sites on the moon.
  It might sound naive and too far away, but two decades is long enough.
]
That requires expertise and resources I do not have yet.
So for the RA (and, if it works out, the doctoral programme and career after),
I want to do well-scoped incremental work: publish, collaborate, experiment:

- Publish in venues like SIGGRAPH.
- Reliable-grade open source implementation and frameworks.
- Get ideas tested in the real world. Requires access to the lab, the school, and industrial partners, with the possibility of closing the lab-to-field gap.


I think Robotic Fabrication Lab #sidenote[
  Why RFL at HKUST specifically? Several reasons:
- I want to publish work and test ideas in the direction of robotic construction;
- I want to publish at SIGGRAPH (I attended SIGGRAPH Vancouver last summer just to look around; it seems like a good community, the vibe is great and people are doing interesting and solid things.)
- and I also want to stay in China: both to make it easy to visit home and to stay close to the research and commercial communities in the Greater Bay Area.
] at HKUST is where I can build that expertise.

= Some proposals for the idea-driven starting points

I proposed the three ideas below.

*1. VLA for household tasks.* RFL has a funded programme on VLA-based household-robot manipulation. #sidenote[
  Inferred from the RFL position openings page and a project titled _VLA-based Embodied Robots in 4S Stores_ with BYD.

  I have no robotics background, but I recently started exploring the VLA stacks, see #link("https://luxxxlucy.github.io/vla-reward/")[vla-cheap-reward] and #link("https://luxxxlucy.github.io/realtime-vla-mac/")[realtime-vla-mac].
] I think this would be a good place for me to start. I think I have some experience in engineering and shipping working solutions.

*2. Learning to scaffold* — a follow-up to the _Learning to Assemble_ line #cite(<wang2025learn2assemble>).
I think there are mainly two issues to address:
1. generalise across target structures, rather than requiring retraining per instance;
2. use generic scaffolding objects to hold partial structures stable, rather than relying on other collaborative robots for temporary support #cite(<xu2021reusablesupport>)#cite(<huang2025multitangent>).

The broader bet is that neural policies need to integrate with traditional large-scale planning systems — pure learned policies would have generalization issues and might not work on very large problem instances without more reliable, traditional planners.
I sketched a version of this idea in a blog post#sidenote[#link("https://luxxxlucy.github.io/assembly-as-synthesis/")[assembly-as-synthesis], which uses a CEGIS planner with different backbones as a simple demo.]. Maybe we can explore ideas that fuse traditional planners with neural policies #cite(<tian2024asap>).

*3. Interlocking modular components* — this continues your earlier works on interlocking assemblies #cite(<wang2018desia>)#cite(<chen2022highlevelpuzzle>)#cite(<huang2024reusablekit>). I do not know whether this is still an active direction, but I am quite interested in it.

The goal is a small library of parts that compose into as wide a variety of target structures as possible and assemble on-site with minimal reconfiguration.
The design question is not only what shape works geometrically, but what shape is easy for assembly planning and for robots to execute — so the library has to be co-designed for geometric expressiveness and robotic assembly.

These ideas are premature and would of course need more careful literature review and further refinement. That being said,
I am open to other ideas, topics, and projects.

The intent is to use this RA as the basis for a PhD application in Fall 2027 or 2028.

#pagebreak()
= References

#bibliography("refs.bib", title: none, style: "association-for-computing-machinery")
