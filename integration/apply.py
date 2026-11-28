"""Apply pinned NVIDIA integration changes to the pinned BR baseline."""
import json
import shutil
from pathlib import Path

root = Path("br")
changes, additions = json.loads(Path("integration/overlay.json").read_text(encoding="utf-8"))
for name in additions:
    target = root / name
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(Path("nvidia") / name, target)
for name, old, new in changes:
    target = root / name
    source = target.read_text(encoding="utf-8")
    if source.count(old) != 1:
        raise ValueError(f"Expected one match in {name}: {old[:80]}")
    target.write_text(source.replace(old, new), encoding="utf-8", newline="\n")
