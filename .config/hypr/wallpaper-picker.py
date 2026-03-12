#!/usr/bin/env python3
# ============================================================
#  wallpaper-picker.py — rinooze · GTK4
#  Catppuccin Mocha · Purple · Paginación 3 en 3
# ============================================================

import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, GdkPixbuf, GLib, Gdk
import os, subprocess, threading, json, hashlib

WALLPAPER_DIR  = os.path.expanduser("~/Pictures/Wallpapers")
HYPRPAPER_CONF = os.path.expanduser("~/.config/hypr/hyprpaper.conf")
SUPPORTED      = (".jpg", ".jpeg", ".png", ".webp", ".gif")
PAGE_SIZE      = 3
THUMB_W, THUMB_H = 600, 338

CSS = """
* { font-family: 'JetBrainsMono Nerd Font', 'Noto Mono', monospace; }
window { background-color: #1e1e2e; color: #cdd6f4; }

.header {
    background-color: #181825;
    border-bottom: 1px solid #2a2840;
    padding: 12px 16px 10px 16px;
}
.title { font-size: 14px; font-weight: bold; color: #cba6f7; letter-spacing: 3px; }
.subtitle { font-size: 9px; color: #6c7086; margin-top: 2px; }

/* Grid */
.grid-area { background-color: #1e1e2e; padding: 10px 8px; }

.card {
    background-color: #181825;
    border-radius: 10px;
    border: 2px solid #313244;
    padding: 0;
}
.card:hover  { border-color: #585b70; }
.card.active { border-color: #cba6f7; background-color: #211d33; }

picture { border-radius: 8px; }

.card-label {
    font-size: 9px; color: #a6adc8;
    padding: 2px 6px 3px 6px;
    background-color: #000000aa;
    border-radius: 0 0 8px 8px;
}
.card-label-active {
    font-size: 9px; color: #cba6f7; font-weight: bold;
    padding: 2px 6px 3px 6px;
    background-color: #000000cc;
    border-radius: 0 0 8px 8px;
}

/* Barra de paginación */
.pagination {
    background-color: #181825;
    border-top: 1px solid #2a2840;
    padding: 8px 16px;
}
.page-info { font-size: 10px; color: #6c7086; }

.btn-page {
    background-color: #313244;
    color: #a6adc8;
    border-radius: 8px;
    padding: 5px 16px;
    font-size: 11px;
    border: none;
    min-width: 0;
}
.btn-page:hover { background-color: #45475a; color: #cdd6f4; }
.btn-page:disabled { background-color: #1e1e2e; color: #45475a; }

/* Statusbar */
.statusbar {
    background-color: #13111e;
    padding: 4px 14px;
    font-size: 9px; color: #6c7086;
    border-top: 1px solid #2a2840;
}

/* Dialog */
.dialog-outer {
    background-color: #1e1e2e;
    border: 2px solid #cba6f755;
    border-radius: 14px;
}
.dialog-box { padding: 22px; }
.dialog-title { font-size: 13px; font-weight: bold; color: #cdd6f4; }
.dialog-sub   { font-size: 10px; color: #6c7086; margin-top: 2px; }
.btn-confirm {
    background-color: #cba6f7; color: #1e1e2e; font-weight: bold;
    border-radius: 8px; padding: 7px 20px; font-size: 11px; border: none;
}
.btn-confirm:hover { background-color: #d0b4fa; }
.btn-cancel {
    background-color: #313244; color: #a6adc8;
    border-radius: 8px; padding: 7px 20px; font-size: 11px; border: none;
}
.btn-cancel:hover { background-color: #45475a; }
"""

class WallpaperPicker(Gtk.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app, title="Wallpaper Picker")
        self.set_default_size(1020, 420)
        self.set_size_request(600, 340)

        self._files          = []
        self._page           = 0
        self._selected_btn   = None
        self._selected_path  = None

        self._apply_css()
        self._build_ui()
        GLib.idle_add(self._scan_files)

    def _apply_css(self):
        p = Gtk.CssProvider()
        p.load_from_data(CSS.encode())
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(), p,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

    def _build_ui(self):
        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.set_child(root)

        # Header
        hdr = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        hdr.add_css_class("header")
        t = Gtk.Label(label="WALLPAPER PICKER")
        t.add_css_class("title"); t.set_halign(Gtk.Align.START)
        s = Gtk.Label(label=f"  {WALLPAPER_DIR}")
        s.add_css_class("subtitle"); s.set_halign(Gtk.Align.START)
        hdr.append(t); hdr.append(s)
        root.append(hdr)

        # Grid 3 columnas fijas
        self._grid = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self._grid.add_css_class("grid-area")
        self._grid.set_vexpand(True)
        self._grid.set_hexpand(True)
        self._grid.set_homogeneous(True)
        self._grid.set_margin_start(8)
        self._grid.set_margin_end(8)
        self._grid.set_margin_top(8)
        self._grid.set_margin_bottom(8)
        root.append(self._grid)

        # Paginación
        pag = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        pag.add_css_class("pagination")
        pag.set_spacing(10)

        self._btn_prev = Gtk.Button(label="← Anterior")
        self._btn_prev.add_css_class("btn-page")
        self._btn_prev.connect("clicked", lambda *_: self._go(-1))

        self._page_lbl = Gtk.Label(label="")
        self._page_lbl.add_css_class("page-info")
        self._page_lbl.set_hexpand(True)
        self._page_lbl.set_halign(Gtk.Align.CENTER)

        self._btn_next = Gtk.Button(label="Siguiente →")
        self._btn_next.add_css_class("btn-page")
        self._btn_next.connect("clicked", lambda *_: self._go(+1))

        pag.append(self._btn_prev)
        pag.append(self._page_lbl)
        pag.append(self._btn_next)
        root.append(pag)

        # Statusbar
        self._status = Gtk.Label(label="Iniciando…")
        self._status.add_css_class("statusbar")
        self._status.set_halign(Gtk.Align.START)
        root.append(self._status)

    # ── Escanear archivos ─────────────────────────────────────
    def _scan_files(self):
        if not os.path.isdir(WALLPAPER_DIR):
            os.makedirs(WALLPAPER_DIR, exist_ok=True)
            self._set_status("⚠  Agrega wallpapers en ~/Pictures/Wallpapers")
            return False

        self._files = sorted([
            os.path.join(WALLPAPER_DIR, f)
            for f in os.listdir(WALLPAPER_DIR)
            if f.lower().endswith(SUPPORTED)
        ])

        if not self._files:
            self._set_status("⚠  No se encontraron imágenes")
            return False

        self._render_page()
        return False

    # ── Renderizar página actual ──────────────────────────────
    def _render_page(self):
        # Limpiar grid
        while True:
            child = self._grid.get_first_child()
            if child is None: break
            self._grid.remove(child)

        total_pages = self._total_pages()
        start = self._page * PAGE_SIZE
        page_files = self._files[start:start + PAGE_SIZE]

        for path in page_files:
            fn  = os.path.basename(path)
            btn = self._make_card(fn, path)
            # Restaurar selección visual si corresponde
            if path == self._selected_path:
                btn.add_css_class("active")
                self._selected_btn = btn
                self._lbl_style(btn, True)
            self._grid.append(btn)

        # Rellenar con espacios vacíos si la página no está completa
        for _ in range(PAGE_SIZE - len(page_files)):
            spacer = Gtk.Box()
            spacer.set_hexpand(True)
            self._grid.append(spacer)

        # Actualizar controles
        cur  = self._page + 1
        tot  = total_pages
        self._page_lbl.set_label(f"{cur} / {tot}   ·   {len(self._files)} wallpapers")
        self._btn_prev.set_sensitive(self._page > 0)
        self._btn_next.set_sensitive(self._page < total_pages - 1)
        self._set_status(
            f"✓  Mostrando {start+1}–{min(start+PAGE_SIZE, len(self._files))} de {len(self._files)}"
        )

    def _total_pages(self):
        return max(1, (len(self._files) + PAGE_SIZE - 1) // PAGE_SIZE)

    def _go(self, direction):
        new_page = self._page + direction
        if 0 <= new_page < self._total_pages():
            self._page = new_page
            self._selected_btn = None  # reset visual, path se mantiene
            self._render_page()

    # ── Card ──────────────────────────────────────────────────
    def _make_card(self, fn, path):
        btn = Gtk.Button()
        btn.add_css_class("card")
        btn.set_name(path)
        btn.connect("clicked", self._on_click, path, fn)
        btn.set_hexpand(True)
        btn.set_vexpand(True)

        overlay = Gtk.Overlay()
        overlay.set_hexpand(True)
        overlay.set_vexpand(True)

        pic = Gtk.Picture.new_for_filename(path)
        pic.set_content_fit(Gtk.ContentFit.COVER)
        pic.set_hexpand(True)
        pic.set_vexpand(True)
        pic.set_can_shrink(True)
        overlay.set_child(pic)

        name = os.path.splitext(fn)[0]
        name = (name[:30] + "…") if len(name) > 31 else name
        lbl  = Gtk.Label(label=name)
        lbl.add_css_class("card-label")
        lbl.set_halign(Gtk.Align.START)
        lbl.set_valign(Gtk.Align.END)
        overlay.add_overlay(lbl)

        btn.set_child(overlay)
        return btn

    # ── Selección ─────────────────────────────────────────────
    def _on_click(self, btn, path, fn):
        if self._selected_btn:
            self._selected_btn.remove_css_class("active")
            self._lbl_style(self._selected_btn, False)
        self._selected_btn  = btn
        self._selected_path = path
        btn.add_css_class("active")
        self._lbl_style(btn, True)
        self._show_confirm(path, fn)

    def _lbl_style(self, btn, sel):
        overlay = btn.get_child()
        if not overlay: return
        lbl = overlay.get_last_child()
        if not isinstance(lbl, Gtk.Label): return
        if sel:
            lbl.remove_css_class("card-label")
            lbl.add_css_class("card-label-active")
        else:
            lbl.remove_css_class("card-label-active")
            lbl.add_css_class("card-label")

    # ── Confirm dialog ────────────────────────────────────────
    def _show_confirm(self, path, fn):
        dlg = Gtk.Window(transient_for=self, modal=True)
        dlg.set_decorated(False); dlg.set_resizable(False)
        outer = Gtk.Box(); outer.add_css_class("dialog-outer")
        box   = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        box.add_css_class("dialog-box")
        outer.append(box); dlg.set_child(outer)

        try:
            pb  = GdkPixbuf.Pixbuf.new_from_file_at_scale(path, 480, 270, True)
            pic = Gtk.Picture.new_for_pixbuf(pb)
            pic.set_content_fit(Gtk.ContentFit.CONTAIN)
            pic.set_size_request(480, 270)
            pic.set_margin_bottom(4)
            box.append(pic)
        except: pass

        tl = Gtk.Label(label="¿Aplicar este wallpaper?")
        tl.add_css_class("dialog-title"); tl.set_halign(Gtk.Align.CENTER)
        sl = Gtk.Label(label=fn)
        sl.add_css_class("dialog-sub"); sl.set_halign(Gtk.Align.CENTER)
        box.append(tl); box.append(sl)

        btns = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        btns.set_halign(Gtk.Align.CENTER); btns.set_margin_top(8)
        bc = Gtk.Button(label="  Cancelar"); bc.add_css_class("btn-cancel")
        bc.connect("clicked", lambda *_: dlg.close())
        bo = Gtk.Button(label="✓  Aplicar"); bo.add_css_class("btn-confirm")
        bo.connect("clicked", lambda *_: (dlg.close(), self._apply(path)))
        btns.append(bc); btns.append(bo); box.append(btns)

        kc = Gtk.EventControllerKey()
        kc.connect("key-pressed",
                   lambda c, kv, *_: dlg.close() if kv == Gdk.KEY_Escape else None)
        dlg.add_controller(kc)
        dlg.present()

    # ── Apply ─────────────────────────────────────────────────
    def _apply(self, path):
        self._set_status("⏳  Aplicando…")
        def worker():
            try:
                subprocess.run(["hyprctl", "hyprpaper", "preload", path],
                               capture_output=True)
                res = subprocess.run(["hyprctl", "monitors", "-j"],
                                     capture_output=True, text=True)
                for m in json.loads(res.stdout):
                    subprocess.run(
                        ["hyprctl", "hyprpaper", "wallpaper",
                         f"{m.get('name','')},{path}"], capture_output=True)
                self._update_conf(path)
                GLib.idle_add(self._set_status,
                              f"✓  Aplicado: {os.path.basename(path)}")
            except Exception as e:
                GLib.idle_add(self._set_status, f"✗  {e}")
        threading.Thread(target=worker, daemon=True).start()

    def _update_conf(self, path):
        try:
            with open(HYPRPAPER_CONF) as f: lines = f.readlines()
            out = []; pre = wall = False
            for line in lines:
                s = line.strip()
                if s.startswith("preload") and not pre:
                    out.append(f"preload = {path}\n"); pre = True
                elif s.startswith("wallpaper") and not wall:
                    out.append(f"wallpaper = ,{path}\n"); wall = True
                else: out.append(line)
            if not pre:  out.insert(0, f"preload = {path}\n")
            if not wall: out.append(f"wallpaper = ,{path}\n")
            with open(HYPRPAPER_CONF, "w") as f: f.writelines(out)
        except Exception as e: print(f"[conf] {e}")

    def _set_status(self, msg):
        self._status.set_label(msg); return False


def main():
    app = Gtk.Application(application_id="io.rinooze.WallpaperPicker")
    app.connect("activate", lambda a: WallpaperPicker(a).present())
    app.run(None)

if __name__ == "__main__":
    main()