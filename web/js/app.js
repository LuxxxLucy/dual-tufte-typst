import { mountViewer } from "./viewer.js";

async function loadManifest() {
    const r = await fetch("manifest.json", { cache: "no-cache" });
    if (!r.ok) throw new Error(`manifest.json: ${r.status}`);
    return r.json();
}

function paintStyleLinks(manifest) {
    const span = document.getElementById("style-links");
    span.innerHTML = manifest.styles
        .map(s => `<a href="styles/${s}/out.html">${s}</a>`)
        .join('<span class="sep">·</span>');
}

const manifest = await loadManifest();
paintStyleLinks(manifest);
mountViewer(document.getElementById("viewer-stage"),
            document.querySelector(".viewer-format-slot"),
            manifest);
