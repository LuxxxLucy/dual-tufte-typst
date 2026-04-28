const VIEW_MOUNTERS = {
    showcase: () => import("./views/showcase.js"),
    editor:   () => import("./views/editor.js"),
    compare:  () => import("./views/compare.js"),
    all:      () => import("./views/all.js"),
};
const DEFAULT_VIEW = "showcase";

async function loadManifest() {
    const r = await fetch("manifest.json", { cache: "no-cache" });
    if (!r.ok) throw new Error(`manifest.json: ${r.status}`);
    return r.json();
}

function readHashView() {
    const h = (location.hash || "").replace(/^#/, "");
    return VIEW_MOUNTERS[h] ? h : DEFAULT_VIEW;
}

function setActiveTab(name) {
    document.querySelectorAll(".tabs a").forEach(a => {
        a.classList.toggle("active", a.dataset.view === name);
    });
}

async function mountView(name, manifest) {
    setActiveTab(name);
    const root = document.getElementById("view");
    root.innerHTML = "";
    try {
        const mod = await VIEW_MOUNTERS[name]();
        mod.mount(root, manifest);
    } catch (e) {
        root.innerHTML = `<div class="view-error">Failed to load view "${name}": ${e.message}</div>`;
        console.error(e);
    }
}

const manifest = await loadManifest();
await mountView(readHashView(), manifest);

window.addEventListener("hashchange", () => mountView(readHashView(), manifest));
