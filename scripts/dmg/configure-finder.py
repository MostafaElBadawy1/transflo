#!/usr/bin/env python3
"""Write Finder layout metadata directly, without changing the user's Finder preferences."""
from pathlib import Path
import sys

from ds_store import DSStore
from mac_alias import Alias

volume = Path(sys.argv[1])
style = sys.argv[2] if len(sys.argv) > 2 else "adaptive"
if style not in ("adaptive", "branded"):
    raise SystemExit("Unknown installer style")
branded = style == "branded"
with DSStore.open(str(volume / ".DS_Store"), "w+") as store:
    store["."]["bwsp"] = {
        "ShowStatusBar": False,
        "ShowTabView": False,
        "ShowToolbar": False,
        "ShowPathbar": False,
        "ShowSidebar": False,
        "SidebarWidth": 0,
        "WindowBounds": "{{180, 160}, {640, 350}}" if branded else "{{180, 160}, {640, 240}}",
        "ContainerShowSidebar": False,
    }
    store["."]["icvp"] = {
        "viewOptionsVersion": 1,
        "backgroundType": 0,
        "iconSize": 96.0,
        "textSize": 13.0,
        "gridOffsetX": 0.0,
        "gridOffsetY": 0.0,
        "gridSpacing": 100.0,
        "scrollPositionX": 0.0,
        "scrollPositionY": 0.0,
        "labelOnBottom": True,
        "showIconPreview": False,
        "showItemInfo": False,
        "arrangeBy": "none",
    }
    if branded:
        options = store["."]["icvp"]
        options.update({
            "backgroundType": 2,
            "backgroundColorRed": 0.96,
            "backgroundColorGreen": 0.97,
            "backgroundColorBlue": 0.965,
            "backgroundImageAlias": Alias.for_file(str(volume / ".background" / "installer.png")).to_bytes(),
        })
        store["."]["icvp"] = options
    store["."]["vSrn"] = ("long", 1)
    store["."]["icvl"] = ("type", b"icnv")
    store["Transflo.app"]["Iloc"] = (170, 175 if branded else 100)
    store["Applications"]["Iloc"] = (470, 175 if branded else 100)
