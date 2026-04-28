// Inter-on-tufte HTML overlay. Shared by orange-happy and bluewhite —
// both swap tufte-css's serif body for Inter and recolour link / page,
// differing only in palette and heading weight.

#let _inter-stack = "'Inter', 'Helvetica Neue', Helvetica, Arial, sans-serif"

#let inter-overlay(bg: "#ffffff", fg: "#0d0d0d", link: "#0066cc",
                   heading-weight: 600, link-underline: false) = (
    "@import url('https://rsms.me/inter/inter.css');"
    + "html { background-color: " + bg + "; }"
    + "body { background-color: " + bg + "; color: " + fg + ";"
    + " font-family: " + _inter-stack + "; }"
    + "h1, h2, h3, h4, h5, h6, .subtitle, .newthought {"
    + " font-family: " + _inter-stack + ";"
    + " font-style: normal; font-weight: " + str(heading-weight) + "; }"
    + ".sidenote, .marginnote, .sidenote-number, figcaption {"
    + " font-family: " + _inter-stack + "; font-style: normal; }"
    + "a:link, a:visited { color: " + link + "; text-shadow: none;"
    + " background-image: none; text-decoration: "
    + (if link-underline { "underline" } else { "none" }) + ";"
    + " text-decoration-skip-ink: auto; text-underline-offset: 0.15em; }"
    + (if not link-underline { "a:hover { text-decoration: underline; }" } else { "" })
    // tufte-css ships block quotes at 2.2rem (italic ETBembo); Inter at the
    // same size reads heavier than the surrounding sans body.
    + " article blockquote, article blockquote p { font-size: 1.4rem; line-height: 2rem; }"
)
