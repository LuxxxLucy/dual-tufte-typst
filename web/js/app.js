const styles = (await (await fetch("styles.txt", { cache: "no-cache" })).text()).trim().split("\n");

document.getElementById("style-links").innerHTML = styles
    .map(s => `<a href="styles/${s}/out.html">${s}</a>`)
    .join('<span class="sep">·</span>');

function el(tag, props = {}, ...children) {
    const e = Object.assign(document.createElement(tag), props);
    e.append(...children);
    return e;
}

// A pane with a style menu, an HTML/PDF switch and the output in a frame.
function pane(style) {
    let format = "pdf";
    const frame = el("iframe", { loading: "lazy" });
    const show = () => { frame.src = `styles/${style}/out.${format}`; };

    const menu = el("select", {}, ...styles.map(s => el("option", { value: s, textContent: s, selected: s === style })));
    menu.addEventListener("change", () => { style = menu.value; show(); });

    const buttons = ["html", "pdf"].map(f => {
        const b = el("button", { type: "button", textContent: f.toUpperCase(), className: f === format ? "active" : "" });
        b.addEventListener("click", () => {
            format = f;
            for (const o of buttons) o.classList.toggle("active", o === b);
            show();
        });
        return b;
    });

    show();
    return el("article", { className: "card" },
        el("div", { className: "card-head" }, menu, el("div", { className: "btn-group" }, ...buttons)),
        el("div", { className: "card-body" }, frame));
}

document.getElementById("viewer-stage").append(pane(styles[0]), pane(styles[1] ?? styles[0]));
