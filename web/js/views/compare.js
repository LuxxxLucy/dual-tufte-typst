import { renderBody, makeSelect, makeFormatToggle, makePane } from "./_panes.js";

export function mount(root, manifest) {
    const wrap = document.createElement("div");
    wrap.className = "compare";
    wrap.append(
        makeSidePane("left",  manifest.styles[0],                       "html", manifest),
        makeSidePane("right", manifest.styles[1] || manifest.styles[0], "pdf",  manifest),
    );
    root.append(wrap);
}

function makeSidePane(side, initialStyle, initialFormat, manifest) {
    const state = { style: initialStyle, format: initialFormat };
    const styleOpts = manifest.styles.map(s => [s, s]);

    const sideLabel = Object.assign(document.createElement("span"),
        { className: "side-label", textContent: side });
    const styleSel  = makeSelect(styleOpts, state.style, v => { state.style = v; redraw(); });
    const formatTog = makeFormatToggle(state.format, v => { state.format = v; redraw(); });

    const { pane, body } = makePane([sideLabel, styleSel, formatTog]);
    function redraw() { renderBody(body, state.style, state.format, manifest); }
    redraw();
    return pane;
}
