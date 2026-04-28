import { renderBody, makeFormatToggle, makeStyleLinks } from "./_panes.js";

export function mount(root, manifest) {
    const state = { format: "html" };

    const ctrls = document.createElement("div");
    ctrls.className = "view-controls";
    ctrls.append(
        Object.assign(document.createElement("label"), { textContent: "Format" }),
        makeFormatToggle(state.format, v => { state.format = v; renderRow(); }),
        Object.assign(document.createElement("span"), {
            className: "hint", textContent: "← → to page through styles",
        }),
    );
    root.append(ctrls);

    const row = document.createElement("div");
    row.className = "showcase-row";
    row.tabIndex = 0;
    root.append(row);

    function renderRow() {
        row.innerHTML = "";
        for (const s of manifest.styles) row.append(makeCard(s, state.format, manifest));
    }

    row.addEventListener("keydown", e => {
        const cards = [...row.children];
        if (!cards.length) return;
        const w = cards[0].getBoundingClientRect().width
                + parseFloat(getComputedStyle(row).columnGap || 16);
        if (e.key === "ArrowRight") { row.scrollBy({ left: w }); e.preventDefault(); }
        if (e.key === "ArrowLeft")  { row.scrollBy({ left: -w }); e.preventDefault(); }
    });

    renderRow();
    requestAnimationFrame(() => row.focus({ preventScroll: true }));
}

function makeCard(style, format, manifest) {
    const card = document.createElement("article");
    card.className = "showcase-card";

    const head = document.createElement("div");
    head.className = "head";
    head.append(
        Object.assign(document.createElement("span"), { className: "name", textContent: style }),
        makeStyleLinks(style),
    );
    card.append(head);

    const body = document.createElement("div");
    body.className = "body";
    renderBody(body, style, format, manifest);
    card.append(body);
    return card;
}
