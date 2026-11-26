---
name: archviz-bootstrap
description: >-
  Bootstrap and verify the Archviz Studio environment on a new Windows machine:
  installs uv, gflow-cli, optional AutoCAD/SketchUp/Blender MCP servers,
  registers the bundled Znzmo Blender material & lighting library, configures
  gflow .env defaults, and guides the user through the two one-time browser steps.
---

# Archviz Studio — New Machine Environment Bootstrap

Use this skill when the user asks to initialize, install, or troubleshoot the `archviz-studio` plugin environment on a Windows computer.

## Step 1: Run the Bundled Installer Script
Locate `scripts/setup_archviz_env.ps1` inside this plugin's directory (typically `~/.gemini/config/plugins/archviz-studio/scripts/setup_archviz_env.ps1`).
Run it in PowerShell 7:
```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.gemini\config\plugins\archviz-studio\scripts\setup_archviz_env.ps1"
```
- Pass `-WithAutoCAD`, `-WithSketchUp`, `-WithBlender`, or `-AllOptional` if the user has those 3D/CAD apps installed and wants live MCP control.
- The script automatically:
  1. Verifies Google Chrome is installed (stop and ask user to install Chrome if missing).
  2. Installs `uv` (if missing) and `gflow-cli` (`uv tool install gflow-cli`).
  3. Deploys the bundled 19 MB `assets/MyBlenderLibrary` to `D:\3DAssets\MyBlenderLibrary` (or `%USERPROFILE%\3DAssets\MyBlenderLibrary`) and auto-registers it in Blender's Asset Browser if `blender.exe` is detected.
  4. Writes `%LOCALAPPDATA%\ffroliva\gflow-cli\.env` with `GFLOW_CLI_LEASE_WAIT_SECONDS=120` and `GFLOW_CLI_LOG_LEVEL=INFO`.

## Step 2: Optional CAD / 3D MCP Configuration
- Note that `archviz-gflow` MCP is already bundled in this plugin's `mcp_config.json`.
- Only if the user installed optional AutoCAD / SketchUp / Blender MCPs, add their resolved executable paths (`(Get-Command autocad-mcp, sketchup-mcp2, mcp-for-blender).Source`) to `~/.gemini/config/mcp_config.json`, keeping SketchUp on port `9876` and Blender on port `9877`.

## Step 3: Guide the User Through 2 Mandatory One-Time Browser Steps
Explain clearly in plain Chinese:
1. **Google Flow Sign-In**: Ask the user to run `gflow auth login` in PowerShell, sign into Google Flow in the opened Chrome window, and close Chrome. Then run `gflow auth list` and `gflow doctor` to confirm `[PASS]`.
2. **Default Project & One-Time Upload Rights Dialog**:
   - Run one quick `gflow image t2i "minimalist concrete wall, soft daylight" --aspect 16:9` to create the user's default Flow project and record `GFLOW_CLI_PROJECT=<project_id>` into `%LOCALAPPDATA%\ffroliva\gflow-cli\.env`.
   - Give the user the exact PowerShell command to open Flow inside `gflow`'s isolated Chrome profile at `(100, 100)`:
     ```powershell
     & "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe" --user-data-dir="$env:LOCALAPPDATA\ffroliva\gflow-cli\profile_<profile_name>" --window-position=100,100 "https://flow.google.com/project/<project_id>"
     ```
   - Ask the user to upload any single image manually, accept **"Rights to use this image"**, and **close the Chrome window**.

## Step 4: Final Verification
Run `gflow doctor` (confirm `Overall: ok`) and report ready!
