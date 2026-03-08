#!/usr/bin/env python3
# ============================================================
#  wallpaper-picker.py — rinooze
#  Catppuccin Mocha wallpaper switcher for hyprpaper
#  Carga lazy de thumbnails para apertura instantánea
# ============================================================

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GdkPixbuf, GLib, Gdk
import os
import subprocess
import threading
import json

WALLPAPER_DIR = os.path.expanduser("~/Pictures/Wallpapers")
HYPRPAPER_CONF = os.path.expanduser("~/.config/hypr/hyprpaper.conf")
SUPPORTED_EXTENSIONS = (".jpg", ".jpeg", ".png", ".webp")
THUMB_W, THUMB_H = 220, 138

CSS = """
* { font-family: 'JetBrainsMono Nerd Font', monospace; }
window { background-color: #1e1e2e; color: #cdd6f4; }
#header { background-color: #181825; border-bottom: 1px solid #313244; padding: 16px 24px; }
#title { font-size: 18px; font-weight: bold; color: #cba6f7; letter-spacing: 2px; }
#subtitle { font-size: 11px; color: #6c7086; margin-top: 2px; }
#scrolled { background-color: #1e1e2e; }
#grid { background-color: #1e1e2e; padding: 24px; }
.wallpaper-item { background-color: #181825; border-radius: 12px; border: 2px solid #313244; margin: 8px; }
.wallpaper-item:hover { border-color: #cba6f7; background-color: #24273a; }
.wallpaper-item.selected { border-color: #cba6f7; background-color: #2a2a3e; }
.wallpaper-name { font-size: 11px; color: #bac2de; padding: 6px 8px; }
#confirm-dialog { background-color: #1e1e2e; border: 1px solid #313244; padding: 24px; }
#confirm-title { font-size: 15px; font-weight: bold; color: #cdd6f4; margin-bottom: 8px; }
#confirm-subtitle { font-size: 12px; color: #6c7086; margin-bottom: 20px; }
button { border-radius: 8px; padding: 8px 20px; font-size: 13px; border: none; }
#btn-confirm { background-color: #cba6f7; color: #1e1e2e; font-weight: bold; }
#btn-confirm:hover { background-color: #d0b4fa; }
#btn-cancel { background-color: #313244; color: #cdd6f4; }
#btn-cancel:hover { background-color: #45475a; }
#statusbar { background-color: #181825; border-top: 1px solid #313244; padding: 8px 24px; font-size: 11px; color: #6c7086; }
.loading-placeholder { background-color: #313244; border-radius: 8px; }
scrollbar { background-color: #1e1e2e; border: none; }
scrollbar slider { background-color: #313244; border-radius: 4px; min-width: 6px; min-height: 6px; }
scrollbar slider:hover { background-color: #cba6f7; }
"""

class WallpaperPicker(Gtk.Window):
    def __init__(self):
        super().__init__(title="Wallpaper Picker")
        self.set_wmclass("wallpaper-picker", "wallpaper-picker")
        self.set_default_size(1000, 620)
        self.set_resizable(True)
        self.selected_path = None
        self.selected_button = None
        self._pending_files = []

        css_provider = Gtk.CssProvider()
        css_provider.load_from_data(CSS.encode())
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        self._build_ui()
        self._scan_and_build_placeholders()

    def _build_ui(self):
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.add(main_box)

        header = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        header.set_name("header")
        title = Gtk.Label(label="WALLPAPER PICKER")
        title.set_name("title")
        title.set_halign(Gtk.Align.START)
        subtitle = Gtk.Label(label=f"📁 {WALLPAPER_DIR}")
        subtitle.set_name("subtitle")
        subtitle.set_halign(Gtk.Align.START)
        header.pack_start(title, False, False, 0)
        header.pack_start(subtitle, False, False, 0)
        main_box.pack_start(header, False, False, 0)

        self.scrolled = Gtk.ScrolledWindow()
        self.scrolled.set_name("scrolled")
        self.scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.NEVER)
        self.scrolled.set_vexpand(True)

        self.grid = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        self.grid.set_name("grid")
        self.scrolled.add(self.grid)
        main_box.pack_start(self.scrolled, True, True, 0)

        self.statusbar = Gtk.Label(label="Cargando wallpapers...")
        self.statusbar.set_name("statusbar")
        self.statusbar.set_halign(Gtk.Align.START)
        main_box.pack_start(self.statusbar, False, False, 0)

    def _scan_and_build_placeholders(self):
        """Abre la ventana inmediatamente con placeholders, luego carga thumbs en background."""
        if not os.path.exists(WALLPAPER_DIR):
            os.makedirs(WALLPAPER_DIR)
            self.statusbar.set_text("⚠ Carpeta creada — agrega wallpapers en ~/Pictures/Wallpapers")
            return

        files = sorted([
            f for f in os.listdir(WALLPAPER_DIR)
            if f.lower().endswith(SUPPORTED_EXTENSIONS)
        ])

        if not files:
            self.statusbar.set_text("⚠ No se encontraron imágenes en ~/Pictures/Wallpapers")
            return

        self._pending_files = list(files)
        self._buttons = {}

        # Crear placeholders instantáneamente (sin leer imágenes)
        for filename in files:
            path = os.path.join(WALLPAPER_DIR, filename)
            btn, img_widget = self._add_placeholder_card(path, filename)
            self._buttons[filename] = (btn, img_widget, path)

        self.grid.show_all()
        self.statusbar.set_text(f"⏳ Cargando {len(files)} wallpapers...")

        # Cargar thumbnails en background
        threading.Thread(target=self._load_thumbs_background, daemon=True).start()

    def _add_placeholder_card(self, path, filename):
        """Crea una tarjeta con placeholder gris, sin leer la imagen."""
        btn = Gtk.Button()
        btn.set_relief(Gtk.ReliefStyle.NONE)
        btn.get_style_context().add_class("wallpaper-item")

        inner = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)

        # Placeholder gris del tamaño del thumbnail
        placeholder = Gtk.DrawingArea()
        placeholder.set_size_request(THUMB_W, THUMB_H)
        placeholder.get_style_context().add_class("loading-placeholder")
        placeholder.set_margin_top(10)
        placeholder.set_margin_start(10)
        placeholder.set_margin_end(10)

        name = os.path.splitext(filename)[0]
        if len(name) > 22:
            name = name[:20] + "…"
        label = Gtk.Label(label=name)
        label.set_name("wallpaper-name")
        label.set_margin_bottom(8)

        inner.pack_start(placeholder, False, False, 0)
        inner.pack_start(label, False, False, 0)
        btn.add(inner)
        btn.connect("clicked", self._on_wallpaper_clicked, path, filename)

        self.grid.pack_start(btn, False, False, 0)
        return btn, placeholder

    def _load_thumbs_background(self):
        """Carga thumbnails uno por uno en background y actualiza la UI."""
        loaded = 0
        total = len(self._pending_files)

        for filename in self._pending_files:
            btn, placeholder, path = self._buttons[filename]
            try:
                pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(path, THUMB_W, THUMB_H, True)
                # Programar actualización en el hilo principal de GTK
                GLib.idle_add(self._replace_placeholder, btn, placeholder, pixbuf, path, filename)
            except Exception:
                pass
            loaded += 1
            GLib.idle_add(
                self.statusbar.set_text,
                f"⏳ Cargando miniaturas... {loaded}/{total}"
            )

        GLib.idle_add(
            self.statusbar.set_text,
            f"✓ {total} wallpapers listos — clic para seleccionar"
        )

    def _replace_placeholder(self, btn, placeholder, pixbuf, path, filename):
        """Reemplaza el placeholder con la imagen real (corre en hilo GTK)."""
        inner = btn.get_child()
        if inner is None:
            return False

        children = inner.get_children()
        if children:
            inner.remove(children[0])  # Quitar placeholder

        img = Gtk.Image.new_from_pixbuf(pixbuf)
        img.set_margin_top(10)
        img.set_margin_start(10)
        img.set_margin_end(10)
        inner.pack_start(img, False, False, 0)
        inner.reorder_child(img, 0)
        img.show()
        return False  # No repetir el idle_add

    def _on_wallpaper_clicked(self, btn, path, filename):
        if self.selected_button:
            self.selected_button.get_style_context().remove_class("selected")
        self.selected_button = btn
        btn.get_style_context().add_class("selected")
        self.selected_path = path
        self._show_confirm_dialog(path, filename)

    def _show_confirm_dialog(self, path, filename):
        dialog = Gtk.Dialog(transient_for=self, modal=True)
        dialog.set_decorated(False)
        dialog.set_resizable(False)

        area = dialog.get_content_area()
        area.set_spacing(0)

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        box.set_name("confirm-dialog")
        box.set_margin_top(8)
        box.set_margin_bottom(8)
        box.set_margin_start(8)
        box.set_margin_end(8)

        try:
            pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(path, 400, 220, True)
            preview = Gtk.Image.new_from_pixbuf(pixbuf)
            preview.set_margin_bottom(16)
            box.pack_start(preview, False, False, 0)
        except Exception:
            pass

        title = Gtk.Label(label="¿Aplicar este wallpaper?")
        title.set_name("confirm-title")
        title.set_halign(Gtk.Align.CENTER)

        name_label = Gtk.Label(label=filename)
        name_label.set_name("confirm-subtitle")
        name_label.set_halign(Gtk.Align.CENTER)

        box.pack_start(title, False, False, 0)
        box.pack_start(name_label, False, False, 0)

        btn_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        btn_box.set_halign(Gtk.Align.CENTER)
        btn_box.set_margin_top(8)

        btn_cancel = Gtk.Button(label="Cancelar")
        btn_cancel.set_name("btn-cancel")
        btn_cancel.connect("clicked", lambda w: dialog.response(Gtk.ResponseType.CANCEL))

        btn_ok = Gtk.Button(label="✓ Sí, aplicar")
        btn_ok.set_name("btn-confirm")
        btn_ok.connect("clicked", lambda w: dialog.response(Gtk.ResponseType.OK))

        btn_box.pack_start(btn_cancel, False, False, 0)
        btn_box.pack_start(btn_ok, False, False, 0)
        box.pack_start(btn_box, False, False, 0)

        area.pack_start(box, True, True, 0)
        dialog.show_all()

        response = dialog.run()
        dialog.destroy()

        if response == Gtk.ResponseType.OK:
            self._apply_wallpaper(path)

    def _apply_wallpaper(self, path):
        self.statusbar.set_text("⏳ Aplicando wallpaper...")

        def apply():
            try:
                subprocess.run(["hyprctl", "hyprpaper", "preload", path], capture_output=True)
                monitors_result = subprocess.run(
                    ["hyprctl", "monitors", "-j"], capture_output=True, text=True
                )
                monitors = json.loads(monitors_result.stdout)
                for monitor in monitors:
                    name = monitor.get("name", "")
                    subprocess.run(
                        ["hyprctl", "hyprpaper", "wallpaper", f"{name},{path}"],
                        capture_output=True
                    )
                self._update_conf(path)
                GLib.idle_add(
                    self.statusbar.set_text,
                    f"✓ Wallpaper aplicado: {os.path.basename(path)}"
                )
            except Exception as e:
                GLib.idle_add(self.statusbar.set_text, f"✗ Error: {e}")

        threading.Thread(target=apply, daemon=True).start()

    def _update_conf(self, path):
        try:
            with open(HYPRPAPER_CONF, "r") as f:
                lines = f.readlines()

            new_lines = []
            preload_written = False
            wallpaper_written = False

            for line in lines:
                if line.strip().startswith("preload"):
                    if not preload_written:
                        new_lines.append(f"preload = {path}\n")
                        preload_written = True
                elif line.strip().startswith("wallpaper"):
                    if not wallpaper_written:
                        new_lines.append(f"wallpaper = ,{path}\n")
                        wallpaper_written = True
                else:
                    new_lines.append(line)

            if not preload_written:
                new_lines.insert(0, f"preload = {path}\n")
            if not wallpaper_written:
                new_lines.append(f"wallpaper = ,{path}\n")

            with open(HYPRPAPER_CONF, "w") as f:
                f.writelines(new_lines)
        except Exception as e:
            print(f"Error actualizando conf: {e}")


def main():
    win = WallpaperPicker()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()

if __name__ == "__main__":
    main()
