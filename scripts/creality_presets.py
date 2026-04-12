#!/usr/bin/env python3
"""Extract Creality defaults and create user preset stubs.

This script targets Creality Print profile trees in:
~/Library/Application Support/Creality/Creality Print/<version>

It performs two tasks:
1) Pull effective defaults for machine + linked default process/filament.
2) Create new User preset JSON/.info files in user/default/{machine,process,filament}.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
from pathlib import Path
from typing import Dict, List, Any


CREALITY_REL_ROOT = Path("Library/Application Support/Creality/Creality Print")


def load_json(path: Path) -> Dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def save_json(path: Path, data: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=True) + "\n", encoding="utf-8")


def find_profile_file(base_dir: Path, profile_name: str) -> Path:
    for p in sorted(base_dir.glob("*.json")):
        try:
            data = load_json(p)
        except json.JSONDecodeError:
            continue
        if data.get("name") == profile_name:
            return p
    raise FileNotFoundError(f"Profile named '{profile_name}' not found in {base_dir}")


def load_profile_chain(profile_file: Path, base_dir: Path) -> List[Dict[str, Any]]:
    chain: List[Dict[str, Any]] = []
    seen = set()
    current = profile_file

    while True:
        if current in seen:
            raise RuntimeError(f"Cycle detected in inheritance chain at {current}")
        seen.add(current)

        data = load_json(current)
        data["_file"] = str(current)
        chain.append(data)

        parent_name = data.get("inherits")
        if not parent_name:
            break

        try:
            current = find_profile_file(base_dir, parent_name)
        except FileNotFoundError:
            break

    return chain


def effective_value(chain: List[Dict[str, Any]], key: str) -> Any:
    # Chain is child -> base. First non-null/non-empty value is effective.
    for profile in chain:
        if key in profile and profile[key] is not None:
            return profile[key]
    return None


def build_defaults_snapshot(
    machine_chain: List[Dict[str, Any]],
    process_chain: List[Dict[str, Any]],
    filament_chain: List[Dict[str, Any]],
    version_dir: str,
) -> Dict[str, Any]:
    machine = machine_chain[0]
    process = process_chain[0]
    filament = filament_chain[0]

    mkeys = [
        "printable_area",
        "printable_height",
        "nozzle_diameter",
        "min_layer_height",
        "max_layer_height",
        "machine_max_speed_x",
        "machine_max_speed_y",
        "machine_max_speed_z",
        "machine_max_speed_e",
        "machine_max_acceleration_x",
        "machine_max_acceleration_y",
        "machine_max_acceleration_z",
        "machine_max_acceleration_e",
        "machine_max_jerk_x",
        "machine_max_jerk_y",
        "machine_max_jerk_z",
        "machine_max_jerk_e",
        "retraction_length",
        "retraction_speed",
        "deretraction_speed",
        "retraction_minimum_travel",
        "z_hop",
        "z_hop_types",
        "wipe",
        "wipe_distance",
        "retract_before_wipe",
    ]

    pkeys = [
        "layer_height",
        "initial_layer_print_height",
        "line_width",
        "wall_loops",
        "top_shell_layers",
        "bottom_shell_layers",
        "sparse_infill_density",
        "sparse_infill_pattern",
        "outer_wall_speed",
        "inner_wall_speed",
        "top_surface_speed",
        "initial_layer_speed",
        "travel_speed",
        "sparse_infill_speed",
        "outer_wall_acceleration",
        "inner_wall_acceleration",
        "bridge_speed",
        "bridge_flow",
        "enable_support",
        "support_type",
        "brim_type",
        "brim_width",
        "seam_position",
        "ironing_type",
    ]

    fkeys = [
        "filament_type",
        "nozzle_temperature",
        "nozzle_temperature_initial_layer",
        "filament_max_volumetric_speed",
        "fan_min_speed",
        "fan_max_speed",
        "cool_plate_temp",
        "cool_plate_temp_initial_layer",
        "eng_plate_temp",
        "eng_plate_temp_initial_layer",
        "hot_plate_temp",
        "hot_plate_temp_initial_layer",
        "textured_plate_temp",
        "textured_plate_temp_initial_layer",
    ]

    return {
        "source": {
            "vendor": "Creality Print",
            "version_dir": version_dir,
            "captured_on": dt.date.today().isoformat(),
            "machine_profile": machine["name"],
            "default_print_profile": process["name"],
            "default_filament_profile": filament["name"],
            "chains": {
                "machine": [p["name"] for p in machine_chain],
                "process": [p["name"] for p in process_chain],
                "filament": [p["name"] for p in filament_chain],
            },
        },
        "machine": {k: effective_value(machine_chain, k) for k in mkeys},
        "process": {k: effective_value(process_chain, k) for k in pkeys},
        "filament": {k: effective_value(filament_chain, k) for k in fkeys},
    }


def sanitize_name(name: str) -> str:
    # Keep filenames readable and compatible with Creality's own naming style.
    return name.replace("/", "-").strip()


def write_info_file(info_path: Path, base_id: str) -> None:
    content = (
        "sync_info = create\n"
        "user_id = \n"
        "setting_id = \n"
        f"base_id = {base_id}\n"
        "updated_time = 0\n"
    )
    info_path.write_text(content, encoding="utf-8")


def create_user_preset(
    source_profile: Dict[str, Any],
    target_dir: Path,
    preset_name: str,
    profile_type: str,
    overrides: Dict[str, str],
    is_custom_defined: bool,
    process_version_fallback: str,
    dry_run: bool,
) -> Dict[str, str]:
    base_id = source_profile.get("setting_id", "")

    payload: Dict[str, Any] = {
        "base_id": base_id,
        "from": "User",
        "inherits": source_profile["name"],
        "is_custom_defined": "1" if is_custom_defined else "0",
        "name": preset_name,
    }

    if profile_type == "process":
        payload["print_settings_id"] = preset_name
        raw_version = source_profile.get("version", "")
        payload["version"] = raw_version if raw_version else process_version_fallback
    elif profile_type == "filament":
        payload["filament_settings_id"] = preset_name
        if "filament_id" in source_profile:
            payload["filament_id"] = source_profile["filament_id"]
    elif profile_type == "machine":
        payload["printer_settings_id"] = preset_name
    else:
        raise ValueError(f"Unsupported profile type: {profile_type}")

    # Include explicit keys so the preset is a true user override.
    payload.update(overrides)

    file_stem = sanitize_name(preset_name)
    json_path = target_dir / f"{file_stem}.json"
    info_path = target_dir / f"{file_stem}.info"

    if dry_run:
        return {
            "json": str(json_path),
            "info": str(info_path),
            "status": "dry-run",
        }

    target_dir.mkdir(parents=True, exist_ok=True)
    save_json(json_path, payload)
    write_info_file(info_path, str(base_id))

    return {
        "json": str(json_path),
        "info": str(info_path),
        "status": "created",
    }


def update_active_presets(
    conf_path: Path,
    user_root: Path,
    machine_name: str | None,
    process_name: str | None,
    filament_name: str | None,
    dry_run: bool,
) -> Dict[str, Any]:
    conf = load_json(conf_path)

    app = conf.setdefault("app", {})
    app["sync_user_preset"] = True
    app["preset_folder"] = str(user_root)

    presets = conf.setdefault("presets", {})
    if machine_name:
        presets["machine"] = machine_name
    if process_name:
        presets["process"] = process_name
    if filament_name:
        presets["filaments"] = [filament_name]

    orca = conf.get("orca_presets")
    if not isinstance(orca, list):
        orca = []
    if not orca:
        orca.append(
            {
                "curr_bed_type": "4",
                "filament": filament_name or "Default Filament",
                "filament_colors": "#56DF3D",
                "flush_volumes_matrix": "0.000000",
                "flush_volumes_vector": "140.000000|140.000000",
                "machine": machine_name or "Default Printer",
                "process": process_name or "Default Setting",
            }
        )

    if machine_name:
        orca[0]["machine"] = machine_name
    if process_name:
        orca[0]["process"] = process_name
    if filament_name:
        orca[0]["filament"] = filament_name

    conf["orca_presets"] = orca

    if not dry_run:
        save_json(conf_path, conf)

    return {
        "conf": str(conf_path),
        "selected": {
            "machine": machine_name,
            "process": process_name,
            "filament": filament_name,
        },
        "status": "dry-run" if dry_run else "updated",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Extract Creality defaults and create User presets.")
    parser.add_argument(
        "--creality-version-dir",
        default="7.0",
        help="Creality Print profile version directory (default: 7.0).",
    )
    parser.add_argument(
        "--machine-name",
        default="Creality Ender-3 V3 KE 0.4 nozzle",
        help="Exact machine profile name.",
    )
    parser.add_argument(
        "--process-name",
        default="",
        help="Exact process profile name. If omitted, machine default_print_profile is used.",
    )
    parser.add_argument(
        "--filament-name",
        default="",
        help="Exact filament profile name. If omitted, first machine default_filament_profile is used.",
    )
    parser.add_argument(
        "--preset-suffix",
        default="User Preset",
        help="Suffix appended to generated preset names.",
    )
    parser.add_argument(
        "--snapshot-out",
        default="",
        help="Optional output path for extracted defaults snapshot JSON.",
    )
    parser.add_argument(
        "--create-machine",
        action="store_true",
        help="Create machine user preset file.",
    )
    parser.add_argument(
        "--create-process",
        action="store_true",
        help="Create process user preset file.",
    )
    parser.add_argument(
        "--create-filament",
        action="store_true",
        help="Create filament user preset file.",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Actually write files. Without this, script runs in dry-run mode.",
    )
    parser.add_argument(
        "--process-version-fallback",
        default="26.3.30.17",
        help="Fallback process preset version when source profile has no version.",
    )
    parser.add_argument(
        "--custom-defined",
        action="store_true",
        help="Mark generated presets as custom-defined.",
    )
    parser.add_argument(
        "--process-override",
        action="append",
        default=[],
        help="Process override as key=value. Can be passed multiple times.",
    )
    parser.add_argument(
        "--filament-override",
        action="append",
        default=[],
        help="Filament override as key=value. Can be passed multiple times.",
    )
    parser.add_argument(
        "--machine-override",
        action="append",
        default=[],
        help="Machine override as key=value. Can be passed multiple times.",
    )
    parser.add_argument(
        "--select-created",
        action="store_true",
        help="Update Creality.conf so created presets are selected immediately.",
    )

    args = parser.parse_args()

    def parse_overrides(items: List[str]) -> Dict[str, str]:
        out: Dict[str, str] = {}
        for item in items:
            if "=" not in item:
                raise ValueError(f"Invalid override '{item}'. Use key=value")
            k, v = item.split("=", 1)
            key = k.strip()
            if not key:
                raise ValueError(f"Invalid override '{item}'. Empty key")
            out[key] = v.strip()
        return out

    process_overrides = parse_overrides(args.process_override)
    filament_overrides = parse_overrides(args.filament_override)
    machine_overrides = parse_overrides(args.machine_override)

    root = Path.home() / CREALITY_REL_ROOT / args.creality_version_dir
    system_root = root / "system" / "Creality"
    user_root = root / "user" / "default"

    machine_dir = system_root / "machine"
    process_dir = system_root / "process"
    filament_dir = system_root / "filament"

    machine_file = find_profile_file(machine_dir, args.machine_name)
    machine_profile = load_json(machine_file)

    process_name = args.process_name or machine_profile.get("default_print_profile")
    if not process_name:
        raise RuntimeError("Could not determine process profile. Provide --process-name.")

    default_filaments = machine_profile.get("default_filament_profile") or []
    filament_name = args.filament_name or (default_filaments[0] if default_filaments else "")
    if not filament_name:
        raise RuntimeError("Could not determine filament profile. Provide --filament-name.")

    process_file = find_profile_file(process_dir, process_name)
    filament_file = find_profile_file(filament_dir, filament_name)

    machine_chain = load_profile_chain(machine_file, machine_dir)
    process_chain = load_profile_chain(process_file, process_dir)
    filament_chain = load_profile_chain(filament_file, filament_dir)

    snapshot = build_defaults_snapshot(
        machine_chain=machine_chain,
        process_chain=process_chain,
        filament_chain=filament_chain,
        version_dir=args.creality_version_dir,
    )

    if args.snapshot_out:
        out_path = Path(args.snapshot_out).expanduser().resolve()
        save_json(out_path, snapshot)

    stamp = dt.datetime.now().strftime("%Y%m%d-%H%M")
    suffix = f"{args.preset_suffix} {stamp}".strip()

    create_all = not (args.create_machine or args.create_process or args.create_filament)

    results: Dict[str, Any] = {
        "creality_root": str(root),
        "dry_run": not args.apply,
        "machine": machine_profile["name"],
        "process": process_name,
        "filament": filament_name,
        "created": {},
        "snapshot_out": args.snapshot_out or None,
    }

    selected_machine: str | None = None
    selected_process: str | None = None
    selected_filament: str | None = None

    if create_all or args.create_machine:
        preset_name = f"{machine_profile['name']} - {suffix}"
        selected_machine = preset_name
        results["created"]["machine"] = create_user_preset(
            source_profile=machine_profile,
            target_dir=user_root / "machine",
            preset_name=preset_name,
            profile_type="machine",
            overrides=machine_overrides,
            is_custom_defined=args.custom_defined,
            process_version_fallback=args.process_version_fallback,
            dry_run=not args.apply,
        )

    if create_all or args.create_process:
        process_profile = process_chain[0]
        preset_name = f"{process_profile['name']} - {suffix}"
        selected_process = preset_name
        results["created"]["process"] = create_user_preset(
            source_profile=process_profile,
            target_dir=user_root / "process",
            preset_name=preset_name,
            profile_type="process",
            overrides=process_overrides,
            is_custom_defined=args.custom_defined,
            process_version_fallback=args.process_version_fallback,
            dry_run=not args.apply,
        )

    if create_all or args.create_filament:
        filament_profile = filament_chain[0]
        preset_name = f"{filament_profile['name']} - {suffix}"
        selected_filament = preset_name
        results["created"]["filament"] = create_user_preset(
            source_profile=filament_profile,
            target_dir=user_root / "filament",
            preset_name=preset_name,
            profile_type="filament",
            overrides=filament_overrides,
            is_custom_defined=args.custom_defined,
            process_version_fallback=args.process_version_fallback,
            dry_run=not args.apply,
        )

    if args.select_created:
        if selected_machine is None:
            selected_machine = machine_profile["name"]
        if selected_process is None:
            selected_process = process_name
        if selected_filament is None:
            selected_filament = filament_name

        results["selection"] = update_active_presets(
            conf_path=root / "Creality.conf",
            user_root=user_root,
            machine_name=selected_machine,
            process_name=selected_process,
            filament_name=selected_filament,
            dry_run=not args.apply,
        )

    print(json.dumps(results, indent=2, ensure_ascii=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
