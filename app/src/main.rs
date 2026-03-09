use eframe::egui;
use std::path::PathBuf;
use std::process::Command;
use std::sync::{Arc, Mutex};
use std::thread;

// ── Compile result sent from background thread ────────────────────────────────

#[derive(Clone)]
enum CompileResult {
    Pages(Vec<PathBuf>),   // PNG paths produced (PDF mode)
    Html(PathBuf),         // HTML file produced
    Error(String),
}

// ── Shared state written by background thread, read by UI ─────────────────────

#[derive(Default)]
struct Shared {
    result: Option<CompileResult>,
    compiling: bool,
}

// ── Persisted state ───────────────────────────────────────────────────────────

fn state_file() -> PathBuf {
    dirs_next().join(".dual-typst-editor")
}

fn dirs_next() -> PathBuf {
    std::env::var("HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|_| std::env::temp_dir())
}

fn save_state(path: &PathBuf) {
    let _ = std::fs::write(state_file(), path.to_string_lossy().as_bytes());
}

fn load_state() -> Option<PathBuf> {
    let p = PathBuf::from(std::fs::read_to_string(state_file()).ok()?.trim().to_string());
    if p.exists() { Some(p) } else { None }
}

// ── Application ───────────────────────────────────────────────────────────────

struct App {
    // Editor
    source: String,
    file_path: Option<PathBuf>,
    modified: bool,

    // Output mode
    html_mode: bool,

    // Compile state
    shared: Arc<Mutex<Shared>>,
    status: String,

    // Loaded page textures (PDF mode)
    page_textures: Vec<egui::TextureHandle>,
    page_paths: Vec<PathBuf>, // paths currently loaded as textures

    // Temp dir for rendered PNGs
    tmp_dir: PathBuf,

    // Trigger one compile on the first frame after restoring a file
    startup_compile: bool,
}

impl App {
    fn new() -> Self {
        let tmp_dir = std::env::temp_dir().join("dual-typst-preview");
        let _ = std::fs::create_dir_all(&tmp_dir);

        // Verify typst is available
        let status = match Command::new("typst").arg("--version").output() {
            Ok(out) => {
                let v = String::from_utf8_lossy(&out.stdout);
                format!("Ready  ({})", v.trim())
            }
            Err(_) => "ERROR: 'typst' not found in PATH".into(),
        };

        // Restore last file
        let (source, file_path, startup_compile) = if let Some(path) = load_state() {
            match std::fs::read_to_string(&path) {
                Ok(text) => (text, Some(path), true),
                Err(_) => (String::new(), None, false),
            }
        } else {
            (String::new(), None, false)
        };

        Self {
            source,
            file_path,
            modified: false,
            html_mode: false,
            shared: Arc::new(Mutex::new(Shared::default())),
            status,
            page_textures: Vec::new(),
            page_paths: Vec::new(),
            tmp_dir,
            startup_compile,
        }
    }

    fn title(&self) -> String {
        let name = self
            .file_path
            .as_ref()
            .and_then(|p| p.file_name())
            .map(|n| n.to_string_lossy().into_owned())
            .unwrap_or_else(|| "Untitled".into());
        if self.modified {
            format!("{}  •  dual-typst editor", name)
        } else {
            format!("{}  —  dual-typst editor", name)
        }
    }

    // ── File operations ────────────────────────────────────────────────────────

    fn open_file(&mut self) {
        if let Some(path) = rfd::FileDialog::new()
            .add_filter("Typst", &["typ"])
            .pick_file()
        {
            match std::fs::read_to_string(&path) {
                Ok(text) => {
                    self.source = text;
                    save_state(&path);
                    self.file_path = Some(path);
                    self.modified = false;
                    self.status = "Opened.".into();
                }
                Err(e) => self.status = format!("Open error: {e}"),
            }
        }
    }

    fn save(&mut self) -> bool {
        let path = match &self.file_path {
            Some(p) => p.clone(),
            None => match rfd::FileDialog::new()
                .add_filter("Typst", &["typ"])
                .save_file()
            {
                Some(p) => {
                    self.file_path = Some(p.clone());
                    p
                }
                None => return false,
            },
        };
        match std::fs::write(&path, &self.source) {
            Ok(_) => {
                save_state(&path);
                self.modified = false;
                true
            }
            Err(e) => {
                self.status = format!("Save error: {e}");
                false
            }
        }
    }

    // ── Compile ────────────────────────────────────────────────────────────────

    fn compile(&mut self) {
        let path = match &self.file_path {
            Some(p) => p.clone(),
            None => {
                self.status = "Save file first.".into();
                return;
            }
        };

        {
            let mut s = self.shared.lock().unwrap();
            if s.compiling {
                return;
            }
            s.compiling = true;
            s.result = None;
        }

        self.status = "Compiling…".into();

        let shared = Arc::clone(&self.shared);
        let tmp_dir = self.tmp_dir.clone();
        let html_mode = self.html_mode;

        thread::spawn(move || {
            let result = if html_mode {
                compile_html(&path, &tmp_dir)
            } else {
                compile_png(&path, &tmp_dir)
            };

            let mut s = shared.lock().unwrap();
            s.result = Some(result);
            s.compiling = false;
        });
    }

    // ── Load textures from compiled PNG paths ──────────────────────────────────

    fn load_textures(&mut self, paths: Vec<PathBuf>, ctx: &egui::Context) {
        self.page_textures.clear();
        self.page_paths = paths.clone();

        for path in &paths {
            match image::open(path) {
                Ok(img) => {
                    let img = img.to_rgba8();
                    let (w, h) = img.dimensions();
                    let color_image = egui::ColorImage::from_rgba_unmultiplied(
                        [w as usize, h as usize],
                        img.as_raw(),
                    );
                    let tex = ctx.load_texture(
                        path.to_string_lossy(),
                        color_image,
                        egui::TextureOptions::LINEAR,
                    );
                    self.page_textures.push(tex);
                }
                Err(e) => eprintln!("Failed to load {}: {e}", path.display()),
            }
        }
    }
}

// ── Compile helpers ───────────────────────────────────────────────────────────

/// Walk up from `source` to find a directory containing `typst.toml`.
/// Falls back to the source file's own directory.
fn find_root(source: &PathBuf) -> PathBuf {
    let mut dir = source.parent().unwrap_or(source.as_path()).to_path_buf();
    loop {
        if dir.join("typst.toml").exists() {
            return dir;
        }
        match dir.parent() {
            Some(p) => dir = p.to_path_buf(),
            None => break,
        }
    }
    source.parent().unwrap_or(source.as_path()).to_path_buf()
}

fn compile_png(source: &PathBuf, tmp_dir: &PathBuf) -> CompileResult {
    // Clear old PNGs
    if let Ok(entries) = std::fs::read_dir(tmp_dir) {
        for e in entries.flatten() {
            let p = e.path();
            if p.extension().map(|x| x == "png").unwrap_or(false) {
                let _ = std::fs::remove_file(p);
            }
        }
    }

    // typst compile source.typ /tmp/dual-typst-preview/{p}.png
    // The {p} is typst's page substitution syntax
    let out_pattern = tmp_dir.join("{p}.png");
    let root = find_root(source);
    let out = Command::new("typst")
        .arg("compile")
        .arg("--root").arg(&root)
        .arg(source)
        .arg(&out_pattern)
        .output();

    match out {
        Err(e) => CompileResult::Error(format!("Failed to spawn typst: {e}")),
        Ok(o) if !o.status.success() => {
            CompileResult::Error(String::from_utf8_lossy(&o.stderr).into_owned())
        }
        Ok(_) => {
            // Collect produced PNGs sorted by page number
            let mut pages: Vec<PathBuf> = std::fs::read_dir(tmp_dir)
                .into_iter()
                .flatten()
                .flatten()
                .map(|e| e.path())
                .filter(|p| p.extension().map(|x| x == "png").unwrap_or(false))
                .collect();
            pages.sort();
            CompileResult::Pages(pages)
        }
    }
}

fn compile_html(source: &PathBuf, tmp_dir: &PathBuf) -> CompileResult {
    let out_path = tmp_dir.join("output.html");
    let root = find_root(source);
    let o = Command::new("typst")
        .arg("compile")
        .arg("--root").arg(&root)
        .arg("--input")
        .arg("target=html")
        .arg("--features")
        .arg("html")
        .arg(source)
        .arg(&out_path)
        .output();

    match o {
        Err(e) => CompileResult::Error(format!("Failed to spawn typst: {e}")),
        Ok(o) if !o.status.success() => {
            CompileResult::Error(String::from_utf8_lossy(&o.stderr).into_owned())
        }
        Ok(_) => CompileResult::Html(out_path),
    }
}

// ── eframe App impl ───────────────────────────────────────────────────────────

impl eframe::App for App {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        // ── Update window title ────────────────────────────────────────────────
        ctx.send_viewport_cmd(egui::ViewportCommand::Title(self.title()));

        // ── Auto-compile on startup if a file was restored ─────────────────────
        if self.startup_compile {
            self.startup_compile = false;
            self.compile();
        }

        // ── Poll background thread ─────────────────────────────────────────────
        let result = {
            let mut s = self.shared.lock().unwrap();
            s.result.take()
        };

        if let Some(res) = result {
            match res {
                CompileResult::Pages(paths) => {
                    self.status = format!("OK  ({} page{})", paths.len(), if paths.len() == 1 { "" } else { "s" });
                    self.load_textures(paths, ctx);
                }
                CompileResult::Html(path) => {
                    self.status = "HTML compiled — opening in browser…".into();
                    if let Err(e) = open::that(&path) {
                        self.status = format!("Open browser error: {e}");
                    }
                }
                CompileResult::Error(msg) => {
                    // Show first line in status, rest on stderr
                    let first = msg.lines().next().unwrap_or("compile error").to_string();
                    self.status = format!("Error: {first}");
                    eprintln!("{msg}");
                }
            }
        }

        // ── Keyboard shortcuts ─────────────────────────────────────────────────
        let ctrl_s = ctx.input(|i| {
            i.key_pressed(egui::Key::S) && i.modifiers.command
        });
        if ctrl_s {
            if self.save() {
                self.compile();
            }
        }

        // ── Menubar ────────────────────────────────────────────────────────────
        egui::TopBottomPanel::top("menu").show(ctx, |ui| {
            egui::menu::bar(ui, |ui| {
                ui.menu_button("File", |ui| {
                    if ui.button("Open…   ⌘O").clicked() {
                        self.open_file();
                        ui.close_menu();
                    }
                    if ui.button("Save      ⌘S").clicked() {
                        if self.save() { self.compile(); }
                        ui.close_menu();
                    }
                    if ui.button("Save As…").clicked() {
                        let old = self.file_path.take();
                        if !self.save() {
                            self.file_path = old;
                        } else {
                            self.compile();
                        }
                        ui.close_menu();
                    }
                });

                // Ctrl+O
                if ctx.input(|i| i.key_pressed(egui::Key::O) && i.modifiers.command) {
                    self.open_file();
                }
            });
        });

        // ── Bottom toolbar ─────────────────────────────────────────────────────
        egui::TopBottomPanel::bottom("toolbar").show(ctx, |ui| {
            ui.horizontal(|ui| {
                ui.label("Output:");
                let pdf_sel = !self.html_mode;
                if ui.selectable_label(pdf_sel, "PDF/PNG").clicked() {
                    self.html_mode = false;
                }
                if ui.selectable_label(self.html_mode, "HTML").clicked() {
                    self.html_mode = true;
                }
                ui.separator();

                // Compiling spinner
                if self.shared.lock().unwrap().compiling {
                    ui.spinner();
                }
                ui.label(&self.status);
            });
        });

        // ── Left panel: source editor ──────────────────────────────────────────
        egui::SidePanel::left("editor")
            .resizable(true)
            .default_width(500.0)
            .show(ctx, |ui| {
                ui.set_min_width(200.0);

                let font_id = egui::FontId::monospace(13.0);
                egui::ScrollArea::vertical()
                    .auto_shrink([false, false])
                    .show(ui, |ui| {
                        ui.horizontal_top(|ui| {
                            // Line numbers column
                            let line_count = self.source.lines().count().max(1);
                            let line_nums = (1..=line_count)
                                .map(|n| format!("{:>4}", n))
                                .collect::<Vec<_>>()
                                .join("\n");
                            ui.add(
                                egui::Label::new(
                                    egui::RichText::new(line_nums)
                                        .font(font_id.clone())
                                        .color(ui.visuals().weak_text_color()),
                                )
                                .selectable(false),
                            );
                            ui.separator();

                            // Editor
                            let avail = ui.available_size();
                            let resp = ui.add_sized(
                                egui::vec2(avail.x, avail.y.max(2000.0)),
                                egui::TextEdit::multiline(&mut self.source)
                                    .font(font_id)
                                    .desired_width(f32::INFINITY)
                                    .lock_focus(true),
                            );
                            if resp.changed() {
                                self.modified = true;
                            }
                        });
                    });
            });

        // ── Central panel: preview ─────────────────────────────────────────────
        egui::CentralPanel::default().show(ctx, |ui| {
            if self.page_textures.is_empty() {
                ui.centered_and_justified(|ui| {
                    #[cfg(target_os = "macos")]
                    ui.label("Press ⌘S to compile and preview.");
                    #[cfg(not(target_os = "macos"))]
                    ui.label("Press Ctrl+S to compile and preview.");
                });
            } else {
                egui::ScrollArea::vertical()
                    .auto_shrink([false, false])
                    .show(ui, |ui| {
                        ui.vertical_centered(|ui| {
                            for tex in &self.page_textures {
                                let size = tex.size_vec2();
                                // Scale to fit available width
                                let avail_w = ui.available_width().min(size.x);
                                let scale = avail_w / size.x;
                                let display_size = egui::vec2(size.x * scale, size.y * scale);
                                ui.image((tex.id(), display_size));
                                ui.add_space(8.0);
                            }
                        });
                    });
            }
        });
    }
}

// ── Entry point ───────────────────────────────────────────────────────────────

fn main() -> eframe::Result<()> {
    let options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_title("dual-typst editor")
            .with_inner_size([1200.0, 800.0]),
        ..Default::default()
    };

    eframe::run_native(
        "dual-typst-editor",
        options,
        Box::new(|_cc| Ok(Box::new(App::new()))),
    )
}
