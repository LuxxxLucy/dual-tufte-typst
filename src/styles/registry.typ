// Style registry. A style is any record with the same shape as
// `src/config.typ:default-config`; partial dicts work because `merge-config`
// deep-merges over the defaults. Add a new style by creating a file here
// and adding it to `registry` below.
//
// `tufte()` reads `style: "<name>"` (registry lookup) or `style: <record>`
// (literal) and merges: default-config → style → user `config:`.

#import "jialin.typ": jialin
#import "tufte-original.typ": tufte-original
#import "envision.typ": envision
#import "terpret.typ": terpret
#import "claude-tufte.typ": claude-tufte
#import "openai-tufte.typ": openai-tufte

#let registry = (
    jialin: jialin,
    tufte-original: tufte-original,
    envision: envision,
    terpret: terpret,
    claude-tufte: claude-tufte,
    openai-tufte: openai-tufte,
)

#let names = registry.keys()

#let resolve(name) = {
    if name in registry { registry.at(name) }
    else { panic("unknown style: " + name + "  (known: " + names.join(", ") + ")") }
}
