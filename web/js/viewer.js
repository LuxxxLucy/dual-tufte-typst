const FORMATS = {
    html: { label: "HTML",      kind: "iframe", file: "out.html" },
    pdf:  { label: "PDF",       kind: "iframe", file: "out.pdf"  },
    png:  { label: "PNG stack", kind: "stack" },
};

function renderBody(body, style, format, manifest) {
    body.innerHTML = "";
    const spec = FORMATS[format];
    if (spec.kind === "iframe") {
        const f = document.createElement("iframe");
        f.src = `styles/${style}/${spec.file}`;
        f.loading = "lazy";
        body.append(f);
        return;
    }
    const stack = document.createElement("div");
    stack.className = "png-stack";
    const n = manifest.pages[style] || 0;
    for (let i = 1; i <= n; i++) {
        const img = document.createElement("img");
        img.src = `styles/${style}/out-${i}.png`;
        img.loading = "lazy";
        stack.append(img);
    }
    body.append(stack);
}

function makeCardHead(style) {
    const head = document.createElement("div");
    head.className = "card-head";
    head.innerHTML =
        `<span class="name">${style}</span>` +
        `<span class="links">` +
            `<a href="styles/${style}/out.html">html</a>` +
            `<a href="styles/${style}/out.pdf">pdf</a>` +
        `</span>`;
    return head;
}

function makeCard(style, format, manifest) {
    const card = document.createElement("article");
    card.className = "card";
    card.append(makeCardHead(style));
    const body = document.createElement("div");
    body.className = "card-body";
    renderBody(body, style, format, manifest);
    card.append(body);
    return card;
}

function makeFormatToggle(value, onChange) {
    const group = document.createElement("div");
    group.className = "btn-group";
    const buttons = ["html", "pdf"].map(f => {
        const btn = document.createElement("button");
        btn.type = "button";
        btn.textContent = FORMATS[f].label;
        btn.classList.toggle("active", f === value);
        btn.addEventListener("click", () => {
            for (const b of buttons) b.classList.toggle("active", b === btn);
            onChange(f);
        });
        group.append(btn);
        return btn;
    });
    return group;
}

function makeSelect(options, value, onChange) {
    const sel = document.createElement("select");
    for (const v of options) {
        const opt = document.createElement("option");
        opt.value = v; opt.textContent = v;
        if (v === value) opt.selected = true;
        sel.append(opt);
    }
    sel.addEventListener("change", () => onChange(sel.value));
    return sel;
}

function mountScroll(stage, formatSlot, manifest) {
    formatSlot.innerHTML = "";
    const container = document.createElement("div");
    container.className = "mode-scroll";
    stage.append(container);
    container.append(makeComparePane(manifest.styles[0], "html", manifest));
}

function mountGrid(stage, formatSlot, manifest) {
    const state = { format: "html" };
    formatSlot.innerHTML = "";
    formatSlot.append(
        Object.assign(document.createElement("span"), { textContent: "Format" }),
        makeFormatToggle(state.format, f => { state.format = f; paint(); }),
    );

    const container = document.createElement("div");
    container.className = "mode-grid";
    stage.append(container);

    function paint() {
        container.innerHTML = "";
        for (const s of manifest.styles) container.append(makeCard(s, state.format, manifest));
    }
    paint();
}

function mountCompare(stage, formatSlot, manifest) {
    formatSlot.innerHTML = "";
    const wrap = document.createElement("div");
    wrap.className = "mode-compare";
    stage.append(wrap);
    wrap.append(
        makeComparePane(manifest.styles[0], "pdf", manifest),
        makeComparePane(manifest.styles[1] || manifest.styles[0], "pdf", manifest),
    );
}

function makeComparePane(style, format, manifest) {
    const state = { style, format };
    const card = document.createElement("article");
    card.className = "card";
    const head = document.createElement("div");
    head.className = "card-head";
    const sel = makeSelect(manifest.styles, state.style, v => { state.style = v; redraw(); });
    const tog = makeFormatToggle(state.format, v => { state.format = v; redraw(); });
    head.append(sel, tog);
    const body = document.createElement("div");
    body.className = "card-body";
    card.append(head, body);
    function redraw() { renderBody(body, state.style, state.format, manifest); }
    redraw();
    return card;
}

const MODES = { scroll: mountScroll, compare: mountCompare, grid: mountGrid };

export function mountViewer(stage, formatSlot, manifest) {
    function render(mode) {
        stage.innerHTML = "";
        MODES[mode](stage, formatSlot, manifest);
    }
    document.querySelectorAll(".tabs button").forEach(btn => {
        btn.addEventListener("click", () => {
            document.querySelectorAll(".tabs button").forEach(b =>
                b.classList.toggle("active", b === btn));
            render(btn.dataset.mode);
        });
    });
    render("scroll");
}
