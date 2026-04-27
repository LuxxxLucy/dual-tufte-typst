# Limitations

Documented HTML-target rendering limitations. Each case here demonstrates a
known broken pattern; the PDF target renders the same source correctly.

These cases are built and surfaced in the test index next to passing cases
and reproductions, so a reviewer can see the current state of broken
patterns at a glance — not silently dropped or hidden.

The smoke test (`tests/_smoke.py`) treats `tests/limitations/` separately:
each case is **expected to fail** an invariant; passing here would mean the
limitation was fixed (rejoice and graduate it back into `tests/cases/`).

## Current limitations

- `multi-paragraph-sidenote/`  — sidenote body spans multiple paragraphs.
  `<p>` inside `<span class="sidenote">` is reparented by browsers.
- `multi-paragraph-marginnote/` — same root cause, marginnote variant.
  This is what hits the bezierlogue reproductions.

## Graduating a limitation

1. Fix the underlying emit (most likely in `src/html.typ`).
2. Re-run `tests/_smoke.py`; the limitation case should pass.
3. Move the directory from `tests/limitations/<name>/` to
   `tests/cases/<group>/<name>/`.
4. Update the smoke test's expectations in `_smoke.py` if needed.
