# Work

Product applications live here.

The repository root is the AI office: roles, workflow, org docs, templates,
skills, MCP config, FVM config, and CEO memory.

Flutter app scaffolds should not be created at the root. Create them under:

```text
work/<app-slug>/
```

Example:

```powershell
fvm flutter create --project-name minimal_timer_app work/minimal-timer-app
```

Run Flutter commands from the app workspace:

```powershell
Push-Location work/<app-slug>
fvm flutter pub get
fvm flutter analyze
fvm flutter test
Pop-Location
```
