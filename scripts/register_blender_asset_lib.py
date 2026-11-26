import os
import sys
import bpy

LIB_NAME = "知末风自建素材库"

# Accept path via `-- <path>` or env var BLENDER_ASSET_LIB_PATH
lib_path = os.environ.get("BLENDER_ASSET_LIB_PATH", "")
if "--" in sys.argv:
    idx = sys.argv.index("--")
    if idx + 1 < len(sys.argv):
        lib_path = sys.argv[idx + 1]

if not lib_path:
    raise SystemExit("Usage: blender -b --python register_blender_asset_lib.py -- <LIB_PATH>")

lib_path = os.path.abspath(lib_path)
fp = bpy.context.preferences.filepaths
existing = next(
    (
        lib
        for lib in fp.asset_libraries
        if lib.path.rstrip("\\/") == lib_path.rstrip("\\/") or lib.name == LIB_NAME
    ),
    None,
)
if existing is None:
    bpy.ops.preferences.asset_library_add(directory=lib_path)
    existing = fp.asset_libraries[-1]

existing.name = LIB_NAME
existing.path = lib_path
bpy.ops.wm.save_userpref()

print(f"REGISTERED BLENDER ASSET LIBRARY: {existing.name} -> {existing.path}")
