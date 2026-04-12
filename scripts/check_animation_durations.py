#!/usr/bin/env python3
"""Check animation duration rules in lib/ Dart files.

Rules:
 - Animation durations should be between 300 ms and 500 ms inclusive.
 - Micro-snaps (<=150 ms) are allowed only if annotated with "// micro-snap" on the same line.
 - Lines containing 'timeout' or files containing 'service' are exempt from the >500ms rule (network timeouts).
 - lumi_animations.dart definitions are exempt.

Usage: python3 scripts/check_animation_durations.py
Exit: 0 if no violations, 1 otherwise
"""
import re
import sys
from pathlib import Path

ms_pattern = re.compile(r"Duration\(milliseconds:\s*(\d+)\)")
sec_pattern = re.compile(r"Duration\(seconds:\s*(\d+)\)")

repo_root = Path(__file__).resolve().parents[1]
lib_dir = repo_root / 'lib'

violations = []

for path in lib_dir.rglob('*.dart'):
    rel = path.relative_to(repo_root)
    text = path.read_text(encoding='utf-8')
    lines = text.splitlines()
    for i, line in enumerate(lines, start=1):
        # Skip definitions in lumi_animations.dart
        if path.name == 'lumi_animations.dart':
            continue
        # check ms patterns
        for m in ms_pattern.finditer(line):
            val = int(m.group(1))
            is_micro_annot = 'micro-snap' in line
            is_timeout = 'timeout' in line.lower() or 'ping' in path.name.lower() or 'service' in path.name.lower()
            if val <= 150:
                if not is_micro_annot:
                    violations.append((rel.as_posix(), i, val, '<=150 ms but missing // micro-snap annotation'))
            elif val < 300:
                violations.append((rel.as_posix(), i, val, 'animation duration < 300 ms (not allowed)'))
            elif val > 500:
                if not is_timeout:
                    violations.append((rel.as_posix(), i, val, '> 500 ms (animation too long)'))
        # check seconds patterns
        for m in sec_pattern.finditer(line):
            val_s = int(m.group(1))
            val = val_s * 1000
            is_timeout = 'timeout' in line.lower() or 'ping' in path.name.lower() or 'service' in path.name.lower()
            if val > 500 and not is_timeout:
                violations.append((rel.as_posix(), i, val, f'Duration({val_s}s) -> {val}ms > 500 ms (animation too long)'))

if violations:
    print('Found animation duration violations:')
    for file, line, val, msg in violations:
        print(f" - {file}:{line}: {val} ms -> {msg}")
    sys.exit(1)
else:
    print('No animation duration violations found.')
    sys.exit(0)
