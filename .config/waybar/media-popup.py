#!/usr/bin/env python3
"""
Media Popup para Waybar
Dropdown anclado al top de la pantalla, estilo Catppuccin Mocha
Dependencias: python-gobject, gtk-layer-shell, playerctl
"""

import gi
import subprocess
import threading
import os
import urllib.request
import tempfile
import sys

gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")

from gi.repository import Gtk, GLib, Gdk, GdkPixbuf, GtkLayerShell

# ── Catppuccin Mocha ──────────────────────────────────────────────
CSS = b"""
* {
    font-family: "JetBrainsMono Nerd Font", monospace;
}

window {
    background-color: rgba(30, 30, 46, 0.95);
    border-radius: 0 0 16px 16px;
    border: 1px solid rgba(203, 166, 247, 0.3);
    border-top: none;
}

#popup-box {
    padding: 16px;
    border-radius: 0 0 16px 16px;
}

#cover {
    border-radius: 10px;
    margin-right: 14px;
}

#title {
    font-size: 15px;
    font-weight: bold;
    color: #cdd6f4;
    margin-bottom: 2px;
}

#artist {
    font-size: 12px;
    color: #a6adc8;
    margin-bottom: 10px;
}

#player-label {
    font-size: 10px;
    color: #6c7086;
    margin-bottom: 8px;
}

button {
    background: rgba(49, 50, 68, 0.8);
    color: #cdd6f4;
    border-radius: 999px;
    border: none;
    padding: 6px 14px;
    font-size: 16px;
    transition: all 0.15s ease;
    min-width: 36px;
}

button:hover {
    background: rgba(203, 166, 247, 0.25);
    color: #cba6f7;
}

#btn-play {
    background: rgba(203, 166, 247, 0.2);
    color: #cba6f7;
    padding: 6px 18px;
    font-size: 18px;
}

#btn-play:hover {
    background: rgba(203, 166, 247, 0.4);
}

#volume-scale trough {
    background: rgba(49, 50, 68, 0.8);
    border-radius: 999px;
    min-height: 4px;
}

#volume-scale highlight {
    background: #cba6f7;
    border-radius: 999px;
}

#volume-scale slider {
    background: #cba6f7;
    border-radius: 999px;
    min-width: 12px;
    min-height: 12px;
    margin: -4px 0;
    border: none;
    box-shadow: none;
}

#player-switcher {
    background: rgba(49, 50, 68, 0.5);
    border-radius: 999px;
    padding: 2px;
    margin-top: 8px;
}

#player-switcher button {
    font-size: 11px;
    padding: 3px 10px;
    background: transparent;
    color: #6c7086;
}

#player-switcher button.active-player {
    background: rgba(203, 166, 247, 0.3);
    color: #cba6f7;
}

separator {
    background: rgba(255,255,255,0.07);
    min-height: 1px;
    margin: 8px 0;
}
"""

def run(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, text=True).strip()
    except:
        return ""

def get_players():
    out = run("playerctl -l 2>/dev/null")
    return [p for p in out.splitlines() if p] if out else []

def get_meta(player=None):
    p = f"-p {player}" if player else ""
    return {
        "title":    run(f"playerctl {p} metadata title 2>/dev/null"),
        "artist":   run(f"playerctl {p} metadata artist 2>/dev/null"),
        "art_url":  run(f"playerctl {p} metadata mpris:artUrl 2>/dev/null"),
        "status":   run(f"playerctl {p} status 2>/dev/null"),
        "volume":   run(f"playerctl {p} volume 2>/dev/null"),
        "player":   player or "default",
    }

def fetch_cover(url):
    try:
        if url.startswith("file://"):
            path = url[7:]
            return GdkPixbuf.Pixbuf.new_from_file_at_scale(path, 80, 80, True)
        elif url.startswith("http"):
            with urllib.request.urlopen(url, timeout=3) as r:
                data = r.read()
            tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".jpg")
            tmp.write(data)
            tmp.close()
            pb = GdkPixbuf.Pixbuf.new_from_file_at_scale(tmp.name, 80, 80, True)
            os.unlink(tmp.name)
            return pb
    except:
        pass
    return None


class MediaPopup(Gtk.Window):
    def __init__(self, margin_left=82):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)
        self.current_player = None
        self.volume_lock = False

        # ── Layer Shell ───────────────────────────────────────────
        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.LEFT, True)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, 50)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.LEFT, margin_left)
        GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.ON_DEMAND)
        GtkLayerShell.set_exclusive_zone(self, -1)

        self.set_default_size(320, -1)

        # ── CSS ───────────────────────────────────────────────────
        provider = Gtk.CssProvider()
        provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        # ── Layout ────────────────────────────────────────────────
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        main_box.set_name("popup-box")
        self.add(main_box)

        # Fila superior: cover + info
        top_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        main_box.pack_start(top_row, False, False, 0)

        self.cover_img = Gtk.Image()
        self.cover_img.set_name("cover")
        self.cover_img.set_size_request(80, 80)
        top_row.pack_start(self.cover_img, False, False, 0)

        info_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        info_box.set_valign(Gtk.Align.CENTER)
        top_row.pack_start(info_box, True, True, 0)

        self.player_label = Gtk.Label(label="")
        self.player_label.set_name("player-label")
        self.player_label.set_halign(Gtk.Align.START)
        info_box.pack_start(self.player_label, False, False, 0)

        self.title_label = Gtk.Label(label="Sin reproducción")
        self.title_label.set_name("title")
        self.title_label.set_halign(Gtk.Align.START)
        self.title_label.set_ellipsize(3)
        self.title_label.set_max_width_chars(22)
        info_box.pack_start(self.title_label, False, False, 0)

        self.artist_label = Gtk.Label(label="")
        self.artist_label.set_name("artist")
        self.artist_label.set_halign(Gtk.Align.START)
        self.artist_label.set_ellipsize(3)
        self.artist_label.set_max_width_chars(22)
        info_box.pack_start(self.artist_label, False, False, 0)

        # Separador
        main_box.pack_start(Gtk.Separator(), False, False, 0)

        # Botones de control
        controls = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        controls.set_halign(Gtk.Align.CENTER)
        main_box.pack_start(controls, False, False, 4)

        btn_prev = Gtk.Button(label="󰒮")
        btn_prev.connect("clicked", lambda _: self.control("previous"))
        controls.pack_start(btn_prev, False, False, 0)

        self.btn_play = Gtk.Button(label="󰐌")
        self.btn_play.set_name("btn-play")
        self.btn_play.connect("clicked", lambda _: self.control("play-pause"))
        controls.pack_start(self.btn_play, False, False, 0)

        btn_next = Gtk.Button(label="󰒭")
        btn_next.connect("clicked", lambda _: self.control("next"))
        controls.pack_start(btn_next, False, False, 0)

        # Volumen
        vol_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        vol_row.set_margin_start(4)
        vol_row.set_margin_end(4)
        main_box.pack_start(vol_row, False, False, 2)

        vol_icon = Gtk.Label(label="󰕾")
        vol_icon.set_name("title")
        vol_row.pack_start(vol_icon, False, False, 0)

        self.vol_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 1, 0.05)
        self.vol_scale.set_name("volume-scale")
        self.vol_scale.set_draw_value(False)
        self.vol_scale.set_hexpand(True)
        self.vol_scale.connect("value-changed", self.on_volume_changed)
        vol_row.pack_start(self.vol_scale, True, True, 0)

        # Selector de players
        players = get_players()
        if len(players) > 1:
            main_box.pack_start(Gtk.Separator(), False, False, 0)
            self.switcher = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
            self.switcher.set_name("player-switcher")
            self.switcher.set_halign(Gtk.Align.CENTER)
            main_box.pack_start(self.switcher, False, False, 0)
            self.player_buttons = {}
            for p in players:
                name = p.split(".")[-1].split("%")[0]
                btn = Gtk.Button(label=name)
                btn.connect("clicked", self.switch_player, p)
                self.switcher.pack_start(btn, False, False, 0)
                self.player_buttons[p] = btn

        # ── Cerrar con Escape o clic fuera ────────────────────────
        self.connect("key-press-event", self.on_key)
        self.connect("focus-out-event", lambda *_: self.destroy())

        # ── Cargar metadata ───────────────────────────────────────
        players = get_players()
        self.current_player = players[0] if players else None
        self.refresh()

        # Auto-refresh cada 2s
        GLib.timeout_add(2000, self.refresh)

    def refresh(self):
        meta = get_meta(self.current_player)
        GLib.idle_add(self.update_ui, meta)
        return True

    def update_ui(self, meta):
        self.title_label.set_text(meta["title"] or "Sin reproducción")
        self.artist_label.set_text(meta["artist"] or "")
        self.player_label.set_text(f"  {meta['player'].split('.')[0]}" if meta["player"] != "default" else "")

        # Botón play/pause
        self.btn_play.set_label("󰏤" if meta["status"] == "Playing" else "󰐌")

        # Volumen
        try:
            vol = float(meta["volume"])
            self.volume_lock = True
            self.vol_scale.set_value(vol)
            self.volume_lock = False
        except:
            pass

        # Portada en hilo separado
        art_url = meta.get("art_url", "")
        if art_url:
            threading.Thread(target=self.load_cover, args=(art_url,), daemon=True).start()
        else:
            self.cover_img.clear()

        # Resaltar player activo
        if hasattr(self, "player_buttons"):
            for p, btn in self.player_buttons.items():
                ctx = btn.get_style_context()
                if p == self.current_player:
                    ctx.add_class("active-player")
                else:
                    ctx.remove_class("active-player")

    def load_cover(self, url):
        pb = fetch_cover(url)
        if pb:
            GLib.idle_add(self.cover_img.set_from_pixbuf, pb)
        else:
            GLib.idle_add(self.cover_img.clear)

    def control(self, cmd):
        p = f"-p {self.current_player}" if self.current_player else ""
        subprocess.Popen(f"playerctl {p} {cmd}", shell=True)
        GLib.timeout_add(300, self.refresh)

    def on_volume_changed(self, scale):
        if self.volume_lock:
            return
        vol = scale.get_value()
        p = f"-p {self.current_player}" if self.current_player else ""
        subprocess.Popen(
            f"playerctl {p} volume {vol:.2f} 2>/dev/null",
            shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )

    def switch_player(self, btn, player):
        self.current_player = player
        self.refresh()

    def on_key(self, widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.destroy()


if __name__ == "__main__":
    margin = int(sys.argv[1]) if len(sys.argv) > 1 else 82
    current_pid = os.getpid()
    pids = run("pgrep -f media-popup.py").splitlines()
    other_pids = [p for p in pids if p.strip() and int(p.strip()) != current_pid]

    if other_pids:
        for p in other_pids:
            subprocess.Popen(f"kill {p.strip()}", shell=True)
    else:
        win = MediaPopup(margin_left=margin)
        win.connect("destroy", Gtk.main_quit)
        win.show_all()
        Gtk.main()
