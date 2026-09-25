"""Copy the locally licensed Ovani clips used by the Godot demo.

The destination is gitignored because the public repository cannot redistribute
the pack's original WAV files.
"""

from pathlib import Path
import argparse
import shutil


CLIPS = {
    "Medieval/Bow Shoot.wav": "bow_shoot.wav",
    "Medieval/Arrow Hit.wav": "arrow_hit.wav",
    "Medieval/Horse Gallop Loop.wav": "horse_gallop_loop.wav",
    "Medieval/Shield Block.wav": "shield_block.wav",
    "Medieval/Loot Gold.wav": "loot_gold.wav",
    "UI & Menus/Click Bounce.wav": "click_bounce.wav",
    "Environment/Grassy Field Loop.wav": "grassy_field_loop.wav",
}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="Path to Sound FX Starter Pack Vol. 1")
    args = parser.parse_args()
    missing = [name for name in CLIPS if not (args.source / name).is_file()]
    if missing:
        parser.error("missing pack files: " + ", ".join(missing))
    destination = Path(__file__).resolve().parents[1] / "runtime/audio/sfx/ovani_starter"
    destination.mkdir(parents=True, exist_ok=True)
    for source_name, runtime_name in CLIPS.items():
        shutil.copy2(args.source / source_name, destination / runtime_name)
        print(f"{source_name} -> {destination / runtime_name}")


if __name__ == "__main__":
    main()
