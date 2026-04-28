import { renderBody, makeStyleLinks } from "./_panes.js";

export function mount(root, manifest) {
    const wrap = document.createElement("div");
    wrap.className = "all-styles";
    for (const style of manifest.styles) wrap.append(makeRow(style, manifest));
    root.append(wrap);
}

function makeRow(style, manifest) {
    const det = document.createElement("details");
    det.open = true;

    const summary = document.createElement("summary");
    summary.append(
        Object.assign(document.createElement("span"), { textContent: style }),
        makeStyleLinks(style),
    );
    det.append(summary);

    const panes = document.createElement("div");
    panes.className = "panes";
    const left = document.createElement("div");
    const right = document.createElement("div");
    renderBody(left,  style, "png",  manifest);
    renderBody(right, style, "html", manifest);
    panes.append(left, right);
    det.append(panes);
    return det;
}
