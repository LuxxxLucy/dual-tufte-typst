// Editor view: in-browser typst.ts compilation. Compile is manual
// (button + Ctrl/Cmd+Enter) — debouncing while WASM warms up stacked
// in-flight requests in early prototypes.

import { makePane } from "./_panes.js";

const SNIPPET_URL    = "https://cdn.jsdelivr.net/npm/@myriaddreamin/typst.ts@0.6.1/dist/esm/contrib/snippet.mjs";
const COMPILER_WASM  = "https://cdn.jsdelivr.net/npm/@myriaddreamin/typst-ts-web-compiler@0.6.1/pkg/typst_ts_web_compiler_bg.wasm";
const RENDERER_WASM  = "https://cdn.jsdelivr.net/npm/@myriaddreamin/typst-ts-renderer@0.6.1/pkg/typst_ts_renderer_bg.wasm";

let typstReady = null;

async function initTypst(setStatus) {
    if (typstReady) return typstReady;
    typstReady = (async () => {
        setStatus("loading typst.ts (~15 MB)…");
        const { $typst } = await import(SNIPPET_URL);
        $typst.setCompilerInitOptions({ getModule: () => COMPILER_WASM });
        $typst.setRendererInitOptions({ getModule: () => RENDERER_WASM });
        setStatus("mounting source…");
        const manifest = await fetch("src/manifest.json").then(r => r.json());
        await Promise.all(manifest.files.map(async path => {
            const text = await fetch(path).then(r => r.text());
            await $typst.addSource("/" + path, text);
        }));
        setStatus("ready");
        return $typst;
    })();
    return typstReady;
}

export function mount(root) {
    const wrap = document.createElement("div");
    wrap.className = "editor";

    const compileBtn = Object.assign(document.createElement("button"),
        { textContent: "Compile", className: "compile-btn" });
    const left = makePane([
        Object.assign(document.createElement("span"),
            { textContent: "source (Ctrl/Cmd+Enter to compile)" }),
        compileBtn,
    ]);
    const ta = document.createElement("textarea");
    ta.spellcheck = false;
    left.body.append(ta);

    const right = makePane([
        Object.assign(document.createElement("span"), { textContent: "output (SVG)" }),
    ]);
    right.body.classList.add("editor-output");
    const status = document.createElement("div");
    status.className = "status";
    status.textContent = "loading source…";
    right.pane.append(status);

    wrap.append(left.pane, right.pane);
    root.append(wrap);

    const setStatus = (msg, isError = false) => {
        status.textContent = msg;
        status.classList.toggle("error", !!isError);
    };

    fetch("example.typ")
        .then(r => r.text())
        .then(t => {
            ta.value = t;
            setStatus("ready — click Compile (first compile downloads ~15 MB of WASM)");
        })
        .catch(e => setStatus("load source failed: " + e.message, true));

    async function compile() {
        setStatus("compiling…");
        try {
            const $typst = await initTypst(setStatus);
            await $typst.addSource("/main.typ", ta.value);
            const svg = await $typst.svg({ mainFilePath: "/main.typ" });
            right.body.innerHTML = svg;
            setStatus("compiled");
        } catch (e) {
            console.error(e);
            setStatus("compile failed: " + (e.message || e), true);
        }
    }

    compileBtn.addEventListener("click", compile);
    ta.addEventListener("keydown", e => {
        if ((e.metaKey || e.ctrlKey) && e.key === "Enter") {
            e.preventDefault();
            compile();
        }
    });
}
