export const FORMATS = {
    html: { label: "HTML",      kind: "iframe", file: "out.html" },
    pdf:  { label: "PDF",       kind: "iframe", file: "out.pdf"  },
    png:  { label: "PNG stack", kind: "stack" },
};

export const formatOptions = Object.entries(FORMATS).map(([k, v]) => [k, v.label]);

export function makeSelect(options, value, onChange) {
    const sel = document.createElement("select");
    for (const [v, label] of options) {
        const opt = document.createElement("option");
        opt.value = v; opt.textContent = label;
        if (v === value) opt.selected = true;
        sel.append(opt);
    }
    sel.addEventListener("change", () => onChange(sel.value));
    return sel;
}

export function makePane(ctrlChildren) {
    const pane = document.createElement("div");
    pane.className = "pane";
    const ctrl = document.createElement("div"); ctrl.className = "ctrl";
    if (ctrlChildren) ctrl.append(...ctrlChildren);
    const body = document.createElement("div"); body.className = "body";
    pane.append(ctrl, body);
    return { pane, ctrl, body };
}

export function makeStyleLinks(style) {
    const span = document.createElement("span");
    span.className = "links";
    span.innerHTML = `<a href="styles/${style}/out.pdf">pdf</a> <a href="styles/${style}/out.html">html</a>`;
    return span;
}

export function renderBody(body, style, format, manifest) {
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
