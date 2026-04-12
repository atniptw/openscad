---
name: creality-presets
description: "Use when working with Creality Print presets, extracting slicer defaults, generating user presets, auto-selecting created presets, or debugging why presets do not appear in dropdowns. Keywords: Creality, preset, user preset, profile, default settings, auto select, process profile, filament profile, machine profile, Creality.conf."
---

# Creality Presets Workflow

This skill is for the OpenSCAD workspace at /Users/tom/Projects/openscad.

## Goal

Use repository scripts to:
- extract effective default machine, process, and filament settings,
- create new user preset files in Creality local app data,
- optionally auto-select created presets in Creality.conf,
- verify and troubleshoot visibility in the Creality UI.

## Paths

- Repo script: /Users/tom/Projects/openscad/scripts/creality_presets.py
- Repo docs: /Users/tom/Projects/openscad/README.md
- Creality profile root: /Users/tom/Library/Application Support/Creality/Creality Print/7.0
- User preset folders:
  - /Users/tom/Library/Application Support/Creality/Creality Print/7.0/user/default/process
  - /Users/tom/Library/Application Support/Creality/Creality Print/7.0/user/default/filament
  - /Users/tom/Library/Application Support/Creality/Creality Print/7.0/user/default/machine
- Active config file:
  - /Users/tom/Library/Application Support/Creality/Creality Print/7.0/Creality.conf

## Standard Commands

1. Dry run only
python3 /Users/tom/Projects/openscad/scripts/creality_presets.py --create-process --preset-suffix "Test" --process-override outer_wall_speed=180

2. Create process preset and auto-select immediately
python3 /Users/tom/Projects/openscad/scripts/creality_presets.py --apply --create-process --preset-suffix "Auto Select" --process-override outer_wall_speed=165 --select-created

3. Create all three types and snapshot defaults
python3 /Users/tom/Projects/openscad/scripts/creality_presets.py --apply --snapshot-out /Users/tom/Projects/openscad/profiles/creality/ender3-v3-ke-defaults.json --preset-suffix "User Baseline" --select-created

## Required Verification

After creation, always verify:

1. Files exist in user/default folders
- list user/default/process and confirm new .json and .info

2. Config is pointing at user presets
- in Creality.conf, confirm:
  - app.sync_user_preset is true
  - app.preset_folder is /Users/tom/Library/Application Support/Creality/Creality Print/7.0/user/default
  - presets.process equals the created process preset name
  - orca_presets[0].process equals the created process preset name

3. Process preset schema sanity
- process user preset should include:
  - base_id
  - from = User
  - inherits
  - name
  - print_settings_id
  - version (non-empty)

## Troubleshooting Playbook

If a preset does not appear in dropdowns:

1. Confirm it exists on disk in user/default/process.
2. Confirm Creality.conf points to it in presets.process and orca_presets[0].process.
3. Confirm app.sync_user_preset is true.
4. Confirm app.preset_folder points to user/default.
5. Restart Creality Print.
6. If still hidden, save a preset manually in UI and compare with generated JSON fields.

## Comparison Helpers

- Capture state:
  - /Users/tom/Projects/openscad/scripts/capture_creality_preset_state.sh
- Diff state captures:
  - /Users/tom/Projects/openscad/scripts/diff_creality_preset_state.sh

Use these helpers to discover exactly what changed when a user clicks Save in the Creality UI.

## Safety Notes

- Do not delete user presets unless explicitly asked.
- Preserve unrelated files and config keys.
- Prefer creating new timestamped presets over editing existing files.
