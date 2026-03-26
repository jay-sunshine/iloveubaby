from pathlib import Path
import re


PROJECT_FILE = Path(__file__).resolve().parents[2] / "project.godot"
LOVE_SCENE = 'run/main_scene="res://scenes/tree_test_love_app.tscn"'


def main() -> None:
    text = PROJECT_FILE.read_text(encoding="utf-8")
    updated_text, count = re.subn(r'run/main_scene="[^"]*"', LOVE_SCENE, text, count=1)
    if count != 1:
        raise RuntimeError("Could not locate run/main_scene in project.godot")
    PROJECT_FILE.write_text(updated_text, encoding="utf-8")
    print(f"Prepared web export entry scene in {PROJECT_FILE}")


if __name__ == "__main__":
    main()
