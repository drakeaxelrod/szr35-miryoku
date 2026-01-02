# SZR35 Miryoku

SZR35 split keyboard with Miryoku layout, layer overlay, and RGB layer indication.

## Quick Start

```bash
# Enter the development shell
nix develop

# Run the terminal trainer with auto layer detection
trainer-hid

# Run the GUI overlay with auto layer detection
overlay

# Run the terminal trainer in manual mode (press 0-7 to view layers)
trainer

# Build firmware (requires Docker)
build

# Flash firmware (keyboard must be in DFU mode)
flash
```

## Miryoku Layout

This uses the standard [Miryoku](https://github.com/manna-harbour/miryoku) layout for split_3x5_3:

| Layer | Thumb Key | Active Hand | Color |
|-------|-----------|-------------|-------|
| 0 - BASE | - | Both | Finger colors |
| 1 - NAV | Space | Right | Cyan |
| 2 - MOUSE | Tab | Right | Green |
| 3 - MEDIA | Escape | Right | Magenta |
| 4 - NUM | Backspace | Left | Yellow |
| 5 - SYM | Enter | Left | Red |
| 6 - FUN | Delete | Left | Blue |
| 7 - BUTTON | Z / / | Both | Orange |

## Project Structure

```
szr35-miryoku/
├── firmware/
│   └── szrkbd_szr35_vial.bin     # Compiled firmware (ready to flash)
├── layouts/
│   └── miryoku-kbd-layout.vil    # Miryoku layout for Vial (split_3x5_3)
├── overlay/
│   ├── miryoku_overlay.py        # GUI layer overlay (PyQt6)
│   └── miryoku_trainer.py        # Terminal layer trainer (Rich)
├── qmk/
│   └── szrkbd/szr35/             # QMK keyboard definition
│       ├── keyboard.json         # Keyboard config (matrix, RGB, split)
│       └── keymaps/vial/
│           ├── keymap.c          # Miryoku keymap + layer broadcast + RGB
│           ├── rules.mk          # Build features (RAW_ENABLE, etc.)
│           └── vial.json         # Vial layout definition
├── build.sh                      # Docker build script
├── flake.nix                     # Nix flake for dependencies
└── README.md
```

## Features

- **Layer Broadcast**: Firmware sends current layer over Raw HID to overlay/trainer
- **RGB Layer Indication**: LEDs change color based on active layer
- **Hot Reload**: Trainer/overlay reload layout file when modified
- **Direct HID Access**: Works on NixOS without hidapi (uses /dev/hidraw directly)

## HID Permissions

If the overlay/trainer can't access the keyboard:

```bash
sudo chmod 666 /dev/hidraw*
```

Or add a udev rule for permanent access:

```bash
# /etc/udev/rules.d/99-szr35.rules
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3601", ATTRS{idProduct}=="45d4", MODE="0666"
```

## Entering DFU Mode

To flash firmware, you need to enter DFU mode using the boot pads:

1. **Locate the boot pads**: Look for the white square with two dots. It's near the thumb cluster, slightly to the side (NOT the one opposite the USB port).
2. **Short the pads**: Use tweezers, a paperclip, or tin foil to bridge the two pads.
3. **While keeping them shorted**, plug in the USB cable.
4. **Release** after the keyboard is plugged in.
5. Run `flash` command.

Each half must be flashed separately.

## Loading Miryoku Layout

The Miryoku layout is stored in the VIL file and loaded via Vial:

1. Open Vial application
2. Load `layouts/miryoku-kbd-layout.vil`
3. Layout is saved to keyboard EEPROM

The keymap.c provides the base firmware with layer broadcast and RGB support. The actual key mappings come from the VIL file loaded via Vial.

## Building Firmware

Requirements:
- Docker installed and running
- `vial-qmk` with SZR35 keyboard at `/home/draxel/Downloads/vial-qmk-szr35`

```bash
# Build using Docker
./build.sh

# Or in nix develop shell
build
```

The build script:
1. Copies `qmk/szrkbd/szr35/keymaps/vial/keymap.c` to vial-qmk
2. Runs `make szrkbd/szr35:vial` in Docker
3. Copies compiled `.bin` to `firmware/`

### Making it Fully Self-Contained

To make this repo fully self-contained, clone vial-qmk as a submodule:

```bash
git submodule add https://github.com/vial-kb/vial-qmk.git vial-qmk
cp -r qmk/szrkbd vial-qmk/keyboards/
# Update build.sh VIAL_QMK path
```

## Firmware Features

The keymap.c includes:
- **9 Miryoku layers**: BASE (Colemak-DH), NAV, MOUSE, MEDIA, NUM, SYM, FUN, BUTTON, + transparent
- **Home row mods**: GUI/Alt/Ctrl/Shift on home row for each hand
- **Raw HID layer broadcast**: Sends layer changes to overlay/trainer
- **RGB per-finger colors**: On base layer, each finger has a unique color
- **RGB layer colors**: Different color per layer when not on base
