# MiniBot.si pocket (#1) - OFFLINE

Read-only PowerShell script that builds a self-contained static HTML pocket plus a JSON snapshot from local files only (same pattern as `tools/local_reader.ps1`). No network, no external scripts or fonts (CSP `default-src 'none'`). It shows the next roadmap step, the last local git commit, and gate status (M5, M5b, SI messaging). It shows `unknown` when a value can't be found.

`powershell -ExecutionPolicy Bypass -File minibot_pocket.ps1 -Roots <path-to-minibot-repo> -OutDir out`

`-OutDir` must be inside the `pockets/` folder. Generated `minibot_pocket.json` / `.html` are not committed.