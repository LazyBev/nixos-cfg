#!/usr/bin/env python3
"""keyclack - play creamy mechanical-keyboard sounds on every keypress.

Reads raw keyboard events straight from /dev/input (evdev), so it works on
any Wayland compositor (niri included) instead of requiring X11. Needs read
access to /dev/input, i.e. membership in the "input" group.
"""

import argparse
import asyncio
import glob
import os
import random
import subprocess
import sys

from evdev import InputDevice, ecodes

DEFAULT_SAMPLE_DIR = os.path.expanduser("~/.local/share/keyclack")

# nk-cream profile: alphanumeric keys pick randomly among six base samples,
# special keys get their own recorded sample.
LETTER_SAMPLES = ["a.wav", "b.wav", "c.wav", "d.wav", "e.wav", "f.wav"]
SPECIAL_SAMPLES = {
    "KEY_SPACE": "space.wav",
    "KEY_ENTER": "enter.wav",
    "KEY_BACKSPACE": "backspace.wav",
    "KEY_TAB": "tab.wav",
    "KEY_LEFTSHIFT": "shift.wav",
    "KEY_RIGHTSHIFT": "shift.wav",
    "KEY_CAPSLOCK": "caps_lock.wav",
}

# keys only a real keyboard reports; used to tell keyboards apart from
# mice, touchpads, gamepads, etc.
KEYBOARD_KEYS = (ecodes.KEY_A, ecodes.KEY_ENTER, ecodes.KEY_SPACE)

MAX_VOLUME = 1.0


def keyboard_devices():
    """Yield InputDevice objects for devices that look like keyboards."""
    for path in sorted(glob.glob("/dev/input/event*")):
        try:
            dev = InputDevice(path)
            keys = set(dev.capabilities().get(ecodes.EV_KEY, []))
            if any(key in keys for key in KEYBOARD_KEYS):
                yield dev
            else:
                dev.close()
        except (OSError, PermissionError):
            continue


def play_sound(sample, volume, sample_dir):
    subprocess.Popen(
        ["pw-play", "--volume", f"{volume:.2f}", os.path.join(sample_dir, sample)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


async def watch(dev, sample_dir, volume_min, volume_max):
    try:
        async for event in dev.async_read_loop():
            if event.type != ecodes.EV_KEY or event.value != 1:
                continue
            name = ecodes.KEY.get(event.code, "")
            sample = SPECIAL_SAMPLES.get(name) or random.choice(LETTER_SAMPLES)
            volume = random.uniform(volume_min, volume_max)
            play_sound(sample, volume, sample_dir)
    except (OSError, RuntimeError):
        dev.close()


async def manage(sample_dir, volume_min, volume_max):
    running = {}
    while True:
        current = {dev.path: dev for dev in keyboard_devices()}
        for path in list(running):
            if path not in current:
                running[path].cancel()
                del running[path]
        for path, dev in current.items():
            if path not in running:
                running[path] = asyncio.ensure_future(
                    watch(dev, sample_dir, volume_min, volume_max)
                )
        await asyncio.sleep(3)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--samples",
        default=DEFAULT_SAMPLE_DIR,
        help=f"directory with the keyclack sample files (default: {DEFAULT_SAMPLE_DIR})",
    )
    parser.add_argument(
        "--volume",
        type=float,
        default=0.8,
        metavar="0.0-1.0",
        help="base playback volume (default: 0.8)",
    )
    parser.add_argument(
        "--volume-variation",
        type=float,
        default=0.1,
        metavar="0.0-0.5",
        help="random +/- volume jitter (default: 0.1)",
    )
    parser.add_argument(
        "--list-devices",
        action="store_true",
        help="list detected keyboard devices and exit",
    )
    args = parser.parse_args()

    if args.list_devices:
        for dev in keyboard_devices():
            print(f"{dev.path}\t{dev.name}")
            dev.close()
        return

    if not os.path.isdir(args.samples):
        sys.exit(f"keyclack: sample dir not found: {args.samples}")

    volume_min = max(0.0, args.volume - args.volume_variation)
    volume_max = min(MAX_VOLUME, args.volume + args.volume_variation)

    try:
        asyncio.run(manage(args.samples, volume_min, volume_max))
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
